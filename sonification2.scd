(

 SynthDef(\xsensNNFO,
	{|bus , amp = 0.1, variation = 1.5, freq = 50.0, spread = 0.04, modulation = 0.02, xFadeMod = 0.4, inputBus, preset = #[ 0.3,   1.1,  50.0, 3.0, 0.3 , 0.005 , 0.3,   1.1,  50.0, 3.0, 0.3 , 0.005 , 0.3,   1.1,  50.0, 3.0, 0.3 , 0.005 ] |
		var out;

		var nDancers = ~correlations.nDancers;
		var nSensors = ~correlations.nSensors;

		//var busses = ~xsensValues.values.asArray[ ~xsensValues.keys.asArray.collect({|key|key.postln;(key.split($|)[1].split($-)[1]).asInteger}).order.postln ].postln.collect({|item| (item).getValueBus });

		var busses = nDancers.collect({|i| nSensors.collect({|j|    ~xsensValues.at("dancer-"++(i+1)++"|sensor-"++(j+1)).getValueBus                          }) }).flat;

		// 12 values for each sensor -> after clump 3 -> [3,3,3,3] - euler++jerk++acceleration++angularVelocity
		var measures = busses.collect({|bus| In.kr( bus, bus.numChannels).clumps([3,3,3,3,4])}); //size [[[3] , 4], 3]

		//2 values for each param channel -> 12 params *2 values *3 sensors= 72 -> out size 2 measures,3 axes, 4 params ,3 sensors
		var fftData = In.kr(~fftNetwork.getBus,~fftNetwork.getBus.numChannels).clump(2).clump(3).clump(4);             //flop.collect({|item| Mix.kr(item)})/(~fftNetwork.getBus.numChannels/2);

		// 12 values * n combinations (one dancer = 3 -> 12 13 23)
		var corrData = In.kr(~correlations.getBusSelf,~correlations.getBusSelf.numChannels).clump(3).clump(4) ;
			//Mix.kr(In.kr(~correlations.getBusSelf,~correlations.getBusSelf.numChannels))/(~correlations.getBusSelf.numChannels);

		var energy = //3-vector, one entry for each sensor

			//for calculating amplification and energy, use total acceleration (it's linear) and total radial velocity (radial)
			measures.collect({//iterate over sensors
				|item,i|
				//get acc and radial V
				item = item.asAudioRateInput;
			(Integrator.ar( Lag.ar(item[2].collect({|item|item*item}).reduce('+').sqrt.clip(0.003,inf)-0.003,0.01),0.99).clip(0.01,inf)-0.01)+ //acceleration
			(item[3].collect({|item|item*item}).reduce('+')) //keep v*v for kinetic energy so no sqrt

			});

		var minMaxCorr;

		var lagTime;
			var nSample ;

		amp= Lag.kr(amp,0.6)*(energy.lincurve(0.0,100.0,0.0,100.0,3));

		// [freq, stddev] for each sensor
		fftData = fftData.collect({|sensor|  (sensor.collect({ |measure| measure.sum/(measure.size);   }).sum/(sensor.size));      });


		nSample= ((    1.0-((fftData.flop[1]*5.0).clip(0.0,1.0))    )*1.5).clip(0.0,1.0);

		//organize by combo [ [12,13],  [12,23] , [13,23]]
		//don't take magnetic field
		corrData=[((corrData[0][0..2])++(corrData[2][0..2])).flat,
			((corrData[0][0..2])++(corrData[1][0..2])).flat,
			((corrData[1][0..2])++(corrData[2][0..2])).flat];


		lagTime = 10000.0*(ControlDur.ir *(1.0 +( 100.0* (( 1.0 - fftData.flop[0] ))*( 1.0 - fftData.flop[1])      )     ));
		minMaxCorr = corrData.collect({|item|
			var max = -1;
			var min = 1;
			item = item[0..2];
			item.do({
				|it|
				max = Select.kr( it>max, [ max ,it]  );
				min = Select.kr( it<min, [ min ,it]  );

				//max = Select.kr( min.abs>max  ,[min,max]);

			});
			[min,max];
		});
		minMaxCorr = Lag.ar( ( minMaxCorr).asAudioRateInput
			,lagTime
		);

		preset = preset.clump(6);
		preset = preset.flop;

		amp=(((amp.clip(0.001,inf))-0.001)).clip(0.0,1.0);

		//\amp, \variation , \freq ,  \spread , \modulation, \xFadeMod
		freq= Lag.kr( preset[2].stutter(2),lagTime);
		variation = Lag.kr(preset[1].stutter(2),lagTime);
		spread = Lag.kr(preset[3].stutter(2),lagTime);
		modulation = Lag.kr(preset[4].stutter(2),lagTime);
		xFadeMod = Lag.kr(preset[5].stutter(2),lagTime);



		//((cos( (minMaxCorr.flat + 1.0)*pi).abs)*(amp.stutter(2)));
		out = (((cos( (minMaxCorr.flat + 1.0)*pi).abs*0.5+0.5)*(amp.stutter(2)))*2.0).clip(0.0,1.0)*FBNeuron.ar(
			(freq*variation).asAudioRateInput,
			freq.asAudioRateInput,
			spread.asAudioRateInput+(3.0*fftData.flop[1].asAudioRateInput),//* ((fftData[1]*10.0).asAudioRateInput)).clip(0,16),
			(modulation.asAudioRateInput)+ ( 0.3 * (1.0-(minMaxCorr.flat)))  ,//*((1.0-(corrData*10.0)).asAudioRateInput))/freq).clip(0,1),
			xFadeMod.asAudioRateInput
		);

		out=[out[1]+out[3]+out[5],out[0]+out[2]+out[4]]*(nSample.reduce('*'));
		OffsetOut.ar(~outputBus ,Sanitize.ar( Sanitize.ar(out/5.0).tanh))



}).add;



)



(
~nnSynth.free;


~transport.stop

)

(
~transport.stop;

~nnSynth=Synth.new(\xsensNNFO,target:~pGroup);

~histos = Dictionary.new();

~transport ={
	var tempIter =0;
	var nDancers = ~correlations.nDancers;
	var nSensors = ~correlations.nSensors;

	var data = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]];

	inf.do({
		//get quadrant for each sensor -> histo - > push corresponding preset
		if(~xSensIter!=tempIter,
		{
			// there's new data
			~xsensValues.keys.do({|key, i|

					var nDancer = (key.split($|)[0].split($-)[1]).asInteger;
					var nSensor = (key.split($|)[1].split($-)[1]).asInteger;

					//~xsensValues.at(key).quadrant;

					if(  ~histos.at(key)==nil,{  ~histos.put(key,[~xsensValues.at(key).quadrant] )  },
						{

							var val=0;

							~histos.put(key,~histos.at(key).add(~xsensValues.at(key).quadrant));
								if(~histos.at(key).size>32,{
								~histos.put(key,~histos.at(key)[(~histos.at(key).size-32)..(~histos.at(key).size-1)]);

								});

							val=~histos.at(key).histo(1000,0,1000).maxIndex;

							if(val>0,{
								data[nSensor-1]= ~presets[(val+6)%(~presets.size)];
							~nnSynth.set(\preset, data.flat);
								~nnSynth.set(\amp, -20.dbamp);

							},{~nnSynth.set(\amp, -80.dbamp)});

					  }  );



			});


			tempIter = ~xSensIter;
		});





		0.001.sleep;

	});


}.fork;


~presets = [
//cloud swarm
  [    0.1,   1.5,  50.0, 3.0, 0.8 , 0.5 ] ,



// chaotic/gendy
  [    0.1,   1.0,  500.0, 3.0, 0.8 , 0.5 ] ,


// near disonant
  [    0.1,   1.0,  500.0, 3.0, 0.1 , 0.5 ] ,


// near disonant
  [    0.1,   1.0,  300.0, 3.0, 0.1 , 0.5 ] ,



// near small variation
  [    0.1,   1.1,  300.0, 3.0, 0.1 , 0.5 ] ,



// xenakis
  [    0.1,   1.1,  300.0, 3.0, 0.3 , 0.5 ] ,



// deep
  [    0.3,   1.1,  50.0, 3.0, 0.3 , 0.005 ] ,



// metallic stutter
  [   0.3,   1.1,  50.0, 3.0, 0.001 , 0.8 ] ,


// metallic hold
  [    0.3,   1.1,  50.0, 12.0, 0.0009 , 0.98 ] ,



// metallic variation
  [    0.2,   1.1,  50.0, 12.0, 0.0009 , 0.5 ] ,


// distorted horn
   [    0.2,   4.9,  50.0, 8.0, 0.09 , 0.00899 ] ,



// noise
   [    0.1,   7.9,  500.0, 1.2, 0.9 , 0.00899 ] ,


// noise2
   [    0.1,   7.9,  500.0, 1.2, 0.009 , 0.00899 ] ,




// noise3-moments
   [    0.1,   7.9,  500.0, 1.2, 0.009 , 0.899 ] ,



// noise4-moments
   [    0.1,   17.9,  500.0, 2.4, 0.1 , 0.7 ] ,


// noise5-almost white
   [    0.1,   270.9,  500.0, 4.4, 0.9 , 0.7 ] ,


// suspended
   [    0.1,   1.09,  1000.0, 1.2, 0.09 , 0.7 ] ,




// suspended low
   [    0.2,   1.01,  60.0, 1.9, 0.009 , 0.12 ] ,



//highpitch - add reverb
   [    0.04,   1.4,  6000.0, 1.1, 0.009 , 0.12 ] ,



//radio
   [    0.04,   1.1,  10000.0, 5.0, 0.09 , 0.32 ] ,


//broad noise
   [    0.04,   6.0,  10000.0, 5.0, 0.09 , 0.32 ] ,




//highpitch - uncomfortable
   [    0.04,   1.9,  10000.0, 1.01, 0.02 , 0.02 ] ,



//inside a star
   [    0.14,   1.9,  40.0, 1.01, 0.02 , 0.02 ] ,



//slowly not pleasant
   [    0.04,   2.3,  400.0, 8.0, 0.1 , 0.2 ] ,



//ghouls
   [    0.04,   10.3,  400.0, 1.7, 0.00003 , 0.2 ] ,




//violins
   [    0.04,   1.3,  400.0, 1.7, 0.03 , 0.7 ] ,


//violins2
   [    0.04,   1.3,  400.0, 2.7, 0.024 , 0.8 ]

]
)





~nnSynth.set(\preset, ~presets[3].flat);

~presets.size






























(
~presets = [
//cloud swarm
{a.setn(  \amp, 0.1, \variation , 0.5, \freq , 50.0, \spread ,3.0, \modulation,0.8 , \xFadeMod,0.5)},



// chaotic/gendy
{a.setn(  \amp, 0.1, \variation , 1.0, \freq , 500.0, \spread ,3.0, \modulation,0.8 , \xFadeMod,0.5)},


// near disonant
{a.setn(  \amp, 0.1, \variation , 1.0, \freq , 500.0, \spread ,3.0, \modulation,0.1 , \xFadeMod,0.5)},


// near disonant
{a.setn(  \amp, 0.1, \variation , 1.0, \freq , 300.0, \spread ,3.0, \modulation,0.1 , \xFadeMod,0.5)},



// near small variation
{a.setn(  \amp, 0.1, \variation , 0.1, \freq , 300.0, \spread ,3.0, \modulation,0.1 , \xFadeMod,0.5)},



// xenakis
{a.setn(  \amp, 0.1, \variation , 0.1, \freq , 300.0, \spread ,3.0, \modulation,0.3 , \xFadeMod,0.5)},



// deep
{a.setn(  \amp, 0.3, \variation , 0.1, \freq , 50.0, \spread ,3.0, \modulation,0.3 , \xFadeMod,0.005)},



// metallic stutter
{a.setn(  \amp, 0.3, \variation , 0.1, \freq , 50.0, \spread ,3.0, \modulation,0.001 , \xFadeMod,0.8)},


// metallic hold
{a.setn(  \amp, 0.3, \variation , 0.1, \freq , 50.0, \spread ,12.0, \modulation,0.0009 , \xFadeMod,0.98)},



// metallic variation
{a.setn(  \amp, 0.2, \variation , 1.1, \freq , 50.0, \spread ,12.0, \modulation,0.0009 , \xFadeMod,0.5)},


// distorted horn
{a.setn(  \amp, 0.2, \variation , 4.9, \freq , 50.0, \spread ,8.0, \modulation,0.09 , \xFadeMod,0.00899)},



// noise
{a.setn(  \amp, 0.1, \variation , 7.9, \freq , 500.0, \spread ,1.2, \modulation,0.9 , \xFadeMod,0.00899)},


// noise2
{a.setn(  \amp, 0.1, \variation , 7.9, \freq , 500.0, \spread ,1.2, \modulation,0.009 , \xFadeMod,0.00899)},




// noise3-moments
{a.setn(  \amp, 0.1, \variation , 7.9, \freq , 500.0, \spread ,1.2, \modulation,0.009 , \xFadeMod,0.899)},



// noise4-moments
{a.setn(  \amp, 0.1, \variation , 17.9, \freq , 500.0, \spread ,2.4, \modulation,0.1 , \xFadeMod,0.7)},


// noise5-almost white
{a.setn(  \amp, 0.1, \variation , 270.9, \freq , 500.0, \spread ,4.4, \modulation,0.9 , \xFadeMod,0.7)},


// suspended
{a.setn(  \amp, 0.1, \variation , 0.09, \freq , 1000.0, \spread ,1.2, \modulation,0.09 , \xFadeMod,0.7)},




// suspended low
{a.setn(  \amp, 0.2, \variation , 1.01, \freq , 60.0, \spread ,1.9, \modulation,0.009 , \xFadeMod,0.12)},



//highpitch - add reverb
{a.setn(  \amp, 0.04, \variation , 1.4, \freq , 6000.0, \spread ,1.1, \modulation,0.009 , \xFadeMod,0.12)},



//radio
{a.setn(  \amp, 0.04, \variation , 1.1, \freq , 10000.0, \spread ,5.0, \modulation,0.09 , \xFadeMod,0.32)},


//broad noise
{a.setn(  \amp, 0.04, \variation , 6.0, \freq , 10000.0, \spread ,5.0, \modulation,0.09 , \xFadeMod,0.32)},




//highpitch - uncomfortable
{a.setn(  \amp, 0.04, \variation , 1.9, \freq , 10000.0, \spread ,1.01, \modulation,0.02 , \xFadeMod,0.02)},



//inside a star
{a.setn(  \amp, 0.14, \variation , 1.9, \freq , 40.0, \spread ,1.01, \modulation,0.02 , \xFadeMod,0.02)},



//slowly not pleasant
{a.setn(  \amp, 0.04, \variation , 2.3, \freq , 400.0, \spread ,8.0, \modulation,0.1 , \xFadeMod,0.2)},



//ghouls
{a.setn(  \amp, 0.04, \variation , 10.3, \freq , 400.0, \spread ,1.7, \modulation,0.00003 , \xFadeMod,0.2)},




//violins
{a.setn(  \amp, 0.04, \variation , 1.3, \freq , 400.0, \spread ,1.7, \modulation,0.03 , \xFadeMod,0.7)},


//violins2
{a.setn(  \amp, 0.04, \variation , 1.3, \freq , 400.0, \spread ,2.7, \modulation,0.024 , \xFadeMod,0.8)}

]
)






~xsensValues.values[~xsensValues.keys.collect({|key|(key.split($|)[1].split($-)[1]).asInteger.postln}).asArray-1].do({|item| (item).getValueBus })


values.do({|item|item.getValueBus().postln})




































































10.lincurve(0.0,100.0,0.0,100.0,2)


























~paramDict = Dictionary.new()

[\bus , \amp , \variation , \freq , \spread , \modulation , \xFadeMod].do({
	|item,i|
	~paramDict.put(item,Bus.control(s, 1))
	//init defaults here


});



~mapSynthControls= {
	|synthToMap|

~paramDict.keys.do({|key,i|

		synthToMap.map(key,~paramDict.at(key))

})
}


~mapSynthControls.value(a)

[\bus , \amp , \variation , \freq , \spread , \modulation , \xFadeMod].do({
	|item,i|
	~paramDict.at(item).set([28,0.1,1.5,100.0,0.04,0.02,0.4][i])

})





[28,0.1,1.5,100.0,0.04,0.02,0.4].do({|item,i| m[i].set(item)} );


m.do({
	|item,i|
	a.map( [\bus , \amp , \variation , \freq , \spread , \modulation , \xFadeMod][i], item)

})






~paramDict.at(\modulation).set(0.9)

~paramDict.at(\freq).set(500)




a=Synth.new(\xsensNNFO)


m.do(_.free)






