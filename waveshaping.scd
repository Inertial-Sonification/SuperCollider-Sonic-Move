
~waveform = Signal.chebyFill(513, {{1.0.rand2}!rrand(1,20)}.value  )
~waveBuf.sendCollection(~waveform.asWavetableNoWrap);





~waveBuf = Buffer.alloc(s,1024, 1);

(




~shaper= {
	|add=0.0, mult=1.0,freq=100.0|
	var sig= 0.1* Shaper.ar(~waveBuf,SinOsc.ar(freq,0.0,mult,add).wrap(-1.0,1.0));
	OffsetOut.ar(~outputBus.index+6, sig.dup);
}.play




)

~shaper.free
~shaper.set(\mult, 123.234325,\add, 0.7)

{{1.0.rand}!rrand(1,20)}.value




















(


SynthDef(\xsensShaper,
	{|bus , amp = 0.1 |
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
			(Integrator.ar( item[2].collect({|item|item*item}).reduce('+').sqrt,0.997).clip(0.3,inf)-0.3)+ //acceleration
			(item[3].collect({|item|item*item}).reduce('+')) //keep v*v for kinetic energy so no sqrt

			});

		var minMaxCorr;

		var lagTime, motion;


		amp=amp*energy;

		// [freq, stddev] for each sensor
		fftData = fftData.collect({|sensor|  (sensor.collect({ |measure| measure.sum/(measure.size);   }).sum/(sensor.size));      });




		//organize by combo [ [12,13],  [12,23] , [13,23]]

		corrData=[(corrData[0]++corrData[2]).flat,
			(corrData[0]++corrData[1]).flat,
			(corrData[1]++corrData[2]).flat];

		corrData = Lag.kr(corrData , 1.0);


		lagTime = (ControlDur.ir *(1.0 +( 100.0* (( 1.0 - fftData.flop[0] ))*( 1.0 - fftData.flop[1])      )     ));
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

		//preset = preset.clump(6);
		//preset = preset.flop;

		amp=(((amp.clip(0.1,inf))-0.1)/50.0).clip(0.0,1.0).flat;


		//(minMaxCorr*((amp*100.0).clip(0,1)));


		//\amp, \variation , \freq ,  \spread , \modulation, \xFadeMod
		//freq= Lag.kr( preset[2].stutter(2),lagTime);
		//variation = Lag.kr(preset[1].stutter(2),lagTime);
		//spread = Lag.kr(preset[3].stutter(2),lagTime);
		//modulation = Lag.kr(preset[4].stutter(2),lagTime);
		//xFadeMod = Lag.kr(preset[5].stutter(2),lagTime);
		motion =  ((((1.0-(( (fftData.flop[1]) *9.0).clip(0.0,1.0)))).clip(0.0,1.0)));
		out = (((cos( (minMaxCorr.flat + 1.0)*pi).abs+0.3)*(amp.stutter(2))*2.0).flat).collect({
			|item,i|

			var sound =(Slew.ar((item*10.0).clip(0.0,1.0),0.937,0.939))*Lag.ar(Lag.ar(motion[i/2].asAudioRateInput,0.8)>0.4,1.7)*
			(Shaper.ar(~waveBuf,SinOsc.ar(30.0+(10.0*(item*i)),0.0,(item*i)+((((measures[i/2][4][1])/4.0)+((measures[i/2][4][0])))*10.0),item+i+((measures[i/2][4][2]))).wrap(-1.0,1.0))
		    +Shaper.ar(~waveBuf,SinOsc.ar(30.0+(10.0*(item*i)),0.0,(item*i)+((((measures[i/2][4][1]))+((measures[i/2][4][0])))),item+i+((measures[i/2][4][2]))).wrap(-1.0,1.0)));


		//	sound=((1.5-(nSample))*0.1*sound) + ((nSample+0.3)*(item.clip(0.0,1.0))*4.0*Sanitize.ar(PMWave.ar( Sanitize.ar(sound.tanh), ((0.2+((2pi*nSample).sin.abs*0.8)).clip(0.0,0.9999)).asAudioRateInput,((0.1 +(0.9 * fftIn[0]))).clip(0.001,0.99).asAudioRateInput, 0.1.asAudioRateInput, 0.00001.asAudioRateInput, 0.1.asAudioRateInput, 0.2.asAudioRateInput,1.0.asAudioRateInput).tanh));
			Sanitize.ar(sound.tanh);

		});

		out=( -12.dbamp)*[out[0]+out[2]+out[4],out[1]+out[3]+out[5]];


		OffsetOut.ar(~outputBus.index+6 ,Sanitize.ar( Sanitize.ar(out).tanh))



}).add;
)





(
~xsensShaper.free;


~xsensShaper=Synth.new(\xsensShaper,target:~pGroup);
)