(

 SynthDef(\xsensNNFO,
	{|bus = 28, amp = 0.1, variation = 1.5, freq = 50.0, spread = 0.04, modulation = 0.02, xFadeMod = 0.4, inputBus |
		var out;

		var nDancers = ~correlations.nDancers;
		var nSensors = ~correlations.nSensors;

		//var busses = ~xsensValues.values.asArray[ ~xsensValues.keys.asArray.collect({|key|key.postln;(key.split($|)[1].split($-)[1]).asInteger}).order.postln ].postln.collect({|item| (item).getValueBus });

		var busses = nDancers.collect({|i| nSensors.collect({|j|    ~xsensValues.at("dancer-"++(i+1)++"|sensor-"++(j+1)).getValueBus                          }) }).flat;

		// 12 values for each sensor -> after clump 3 -> [3,3,3,3] - euler++jerk++acceleration++angularVelocity
		var measures = busses.collect({|bus| In.kr( bus, bus.numChannels).clump(3)}); //size [[[3] , 4], 3]

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
				Integrator.ar( item[2].collect({|item|item*item}).reduce('+').sqrt,0.99)+ //acceleration
				item[3].collect({|item|item*item}).reduce('+') //keep v*v for kinetic energy so no sqrt


			});

		var minMaxCorr;
		amp=(energy.clip(0.3,inf)-0.3) *amp;
amp=amp/20.0;


		// [freq, stddev] for each sensor
		fftData = fftData.collect({|sensor|  (sensor.collect({ |measure| measure.sum/(measure.size);   }).sum/(sensor.size));      });




		//organize by combo [ [12,13],  [12,23] , [13,23]]

		corrData=[(corrData[0]++corrData[2]).flat,
			(corrData[0]++corrData[1]).flat,
			(corrData[1]++corrData[2]).flat];


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
			,ControlDur.ir *(1.0 +( 50.0* (( 1.0 - fftData.flop[0] ))*( 1.0 - fftData.flop[1])      )     ) );



		out = FBNeuron.ar(
			(freq*variation).asAudioRateInput,
			freq.asAudioRateInput,
			spread.asAudioRateInput+(3.0*fftData.flop[1].asAudioRateInput),//* ((fftData[1]*10.0).asAudioRateInput)).clip(0,16),
			(modulation.asAudioRateInput)+ ( 0.3 * (1.0-(minMaxCorr.flat)))  ,//*((1.0-(corrData*10.0)).asAudioRateInput))/freq).clip(0,1),
			xFadeMod.asAudioRateInput
		);

		out=[out[0]+out[2]+out[4],out[1]+out[3]+out[5]];

		OffsetOut.ar(bus ,Sanitize.ar( Sanitize.ar(out).tanh.poll))



}).add;



)


a=Synth.new(\xsensNNFO)
a.setn(\bus, 28, \amp, 1.0, \variation , 1.0, \freq , 100.0, \spread ,1.7, \modulation,0.001 , \xFadeMod,1.0)

a.free

~transport.stop
(
~transport ={
	var tempIter =0;
	var nDancers = ~correlations.nDancers;
	var nSensors = ~correlations.nSensors;

	var data = [0];

	inf.do({
		//get quadrant for each sensor -> histo - > push corresponding preset
		if((~xSensIter!=tempIter,
		{
			// there's new data
			~xsensValues.keys.do({|key, i|

					var nDancer = (key.split($|)[0].split($-)[1]).asInteger;
					var nSensor = (key.split($|)[1].split($-)[1]).asInteger;


			});


			tempIter = ~xSensIter;
		});



		);

		0.001.sleep;

	});


}.fork;
)

//cloud swarm
a.setn(  \amp, 0.1, \variation , 0.5, \freq , 50.0, \spread ,3.0, \modulation,0.8 , \xFadeMod,0.5)



// chaotic/gendy
a.setn(  \amp, 0.1, \variation , 1.0, \freq , 500.0, \spread ,3.0, \modulation,0.8 , \xFadeMod,0.5)


// near disonant
a.setn(  \amp, 0.1, \variation , 1.0, \freq , 500.0, \spread ,3.0, \modulation,0.1 , \xFadeMod,0.5)


// near disonant
a.setn(  \amp, 0.1, \variation , 1.0, \freq , 300.0, \spread ,3.0, \modulation,0.1 , \xFadeMod,0.5)



// near small variation
a.setn(  \amp, 0.1, \variation , 0.1, \freq , 300.0, \spread ,3.0, \modulation,0.1 , \xFadeMod,0.5)



// xenakis
a.setn(  \amp, 0.1, \variation , 0.1, \freq , 300.0, \spread ,3.0, \modulation,0.3 , \xFadeMod,0.5)



// deep
a.setn(  \amp, 0.3, \variation , 0.1, \freq , 50.0, \spread ,3.0, \modulation,0.3 , \xFadeMod,0.005)



// metallic stutter
a.setn(  \amp, 0.3, \variation , 0.1, \freq , 50.0, \spread ,3.0, \modulation,0.001 , \xFadeMod,0.8)


// metallic hold
a.setn(  \amp, 0.3, \variation , 0.1, \freq , 50.0, \spread ,12.0, \modulation,0.0009 , \xFadeMod,0.98)



// metallic variation
a.setn(  \amp, 0.2, \variation , 1.1, \freq , 50.0, \spread ,12.0, \modulation,0.0009 , \xFadeMod,0.5)


// distorted horn
a.setn(  \amp, 0.2, \variation , 4.9, \freq , 50.0, \spread ,8.0, \modulation,0.09 , \xFadeMod,0.00899)



// noise
a.setn(  \amp, 0.1, \variation , 7.9, \freq , 500.0, \spread ,1.2, \modulation,0.9 , \xFadeMod,0.00899)


// noise2
a.setn(  \amp, 0.1, \variation , 7.9, \freq , 500.0, \spread ,1.2, \modulation,0.009 , \xFadeMod,0.00899)




// noise3-moments
a.setn(  \amp, 0.1, \variation , 7.9, \freq , 500.0, \spread ,1.2, \modulation,0.009 , \xFadeMod,0.899)



// noise4-moments
a.setn(  \amp, 0.1, \variation , 17.9, \freq , 500.0, \spread ,2.4, \modulation,0.1 , \xFadeMod,0.7)


// noise5-almost white
a.setn(  \amp, 0.1, \variation , 270.9, \freq , 500.0, \spread ,4.4, \modulation,0.9 , \xFadeMod,0.7)


// suspended
a.setn(  \amp, 0.1, \variation , 0.09, \freq , 1000.0, \spread ,1.2, \modulation,0.09 , \xFadeMod,0.7)




// suspended low
a.setn(  \amp, 0.2, \variation , 1.01, \freq , 60.0, \spread ,1.9, \modulation,0.009 , \xFadeMod,0.12)



//highpitch - add reverb
a.setn(  \amp, 0.04, \variation , 1.4, \freq , 6000.0, \spread ,1.1, \modulation,0.009 , \xFadeMod,0.12)



//radio
a.setn(  \amp, 0.04, \variation , 1.1, \freq , 10000.0, \spread ,5.0, \modulation,0.09 , \xFadeMod,0.32)


//broad noise
a.setn(  \amp, 0.04, \variation , 6.0, \freq , 10000.0, \spread ,5.0, \modulation,0.09 , \xFadeMod,0.32)




//highpitch - uncomfortable
a.setn(  \amp, 0.04, \variation , 1.9, \freq , 10000.0, \spread ,1.01, \modulation,0.02 , \xFadeMod,0.02)



//inside a star
a.setn(  \amp, 0.14, \variation , 1.9, \freq , 40.0, \spread ,1.01, \modulation,0.02 , \xFadeMod,0.02)



//slowly not pleasant
a.setn(  \amp, 0.04, \variation , 2.3, \freq , 400.0, \spread ,8.0, \modulation,0.1 , \xFadeMod,0.2)



//ghouls
a.setn(  \amp, 0.04, \variation , 10.3, \freq , 400.0, \spread ,1.7, \modulation,0.00003 , \xFadeMod,0.2)




//violins
a.setn(  \amp, 0.04, \variation , 1.3, \freq , 400.0, \spread ,1.7, \modulation,0.03 , \xFadeMod,0.7)


//violins2
a.setn(  \amp, 0.04, \variation , 1.3, \freq , 400.0, \spread ,2.7, \modulation,0.024 , \xFadeMod,0.8)









~xsensValues.values[~xsensValues.keys.collect({|key|(key.split($|)[1].split($-)[1]).asInteger.postln}).asArray-1].do({|item| (item).getValueBus })


values.do({|item|item.getValueBus().postln})































































































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






