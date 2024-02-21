
~sample.plot
"C:/Users/korugaa1/Downloads/0300_oka_ice_w_max_24-02-12.ogg"
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg"
"C:/Users/korugaa1/Downloads/forest.wav"

~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/0300_oka_ice_w_max_24-02-12.ogg".standardizePath, channels:[0]);
~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg".standardizePath, channels:[0]);
~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/forest.wav".standardizePath, channels:[0]);

(
~sample.do(_.free);

~samples=
[
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg",
"C:/Users/korugaa1/Downloads/dronelog24022013lankawirain02.ogg",
"C:/Users/korugaa1/Downloads/PaliMeursault-SurPlaceEybens.mp3",
"C:/Users/korugaa1/Downloads/PaliMeursault-SurPlacePort.mp3",
"C:/Users/korugaa1/Downloads/04 Das große melismatische Ehre - Wie (nach den Vesperstichiren) [Lydisch].flac"
];

~sample = ~samples.collect({ |item|  Buffer.readChannel(s,item.standardizePath,channels:[0])   });



//~sample.free;
//~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg".standardizePath, channels:[0]);


 SynthDef(\xsensGrain,
	{|bus = 28, amp = 0.1 |
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
			(Integrator.ar( item[2].collect({|item|item*item}).reduce('+').sqrt,0.997).clip(0.3,inf)-0.3)+ //acceleration
			(item[3].collect({|item|item*item}).reduce('+')) //keep v*v for kinetic energy so no sqrt

			});

		var minMaxCorr;

		var lagTime;


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


		//(minMaxCorr*((amp*100.0).clip(0,1))).poll;



		//amp.poll;

		//\amp, \variation , \freq ,  \spread , \modulation, \xFadeMod
		//freq= Lag.kr( preset[2].stutter(2),lagTime);
		//variation = Lag.kr(preset[1].stutter(2),lagTime);
		//spread = Lag.kr(preset[3].stutter(2),lagTime);
		//modulation = Lag.kr(preset[4].stutter(2),lagTime);
		//xFadeMod = Lag.kr(preset[5].stutter(2),lagTime);



		out = (((cos( (minMaxCorr.flat + 1.0)*pi).abs+0.3)*(amp.stutter(2))*2.0).flat).collect({
			|item,i|

			var ptr=  ((   ((measures[i/2][0]).mod(2pi)/2pi)*((measures[i/2][0]).mod(2pi)/2pi)).sum.sqrt).wrap(0.0,1.0);
			var fftIn = fftData[i/2] ;
			var wSize =  ((1.0-(fftIn[0]*fftIn[1]*20.0))).clip(0.001,1.0); //higher frequency smaller window
			var prob  =  Lag.ar((amp[i/2]*4.0).asAudioRateInput,0.2).clip(0.001,1.0);
			var wRand = (fftIn[1]*0.1).clip(0.0,1.0);
			var freqScale = 1.0.asAudioRateInput;
			var nSample = ((    1.0-((fftIn[1]*5.0).clip(0.0,1.0))    )*1.5*5).clip(0.0,5.0).poll;
			var sound =(item.clip(0.0,1.0))* SelectX.ar(nSample , ~sample.collect({|sample| WarpP.ar(1, sample, ptr.asAudioRateInput, freqScale, wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput) }));

			((1.5-(nSample/5.0))*2*sound) + ((nSample/5.0+0.6)*Sanitize.ar(PMWave.ar( Sanitize.ar(sound.tanh), ((0.8+(nSample/25.0)).clip(0.0,0.9999)).asAudioRateInput,(1.0-(0.1 +(0.9 * fftIn[0]))).clip(0.001,0.99).asAudioRateInput, 0.1.asAudioRateInput, 0.00001.asAudioRateInput, 0.1.asAudioRateInput, 0.2.asAudioRateInput,1.0.asAudioRateInput).tanh));

		});

		out=[out[0]+out[2]+out[4],out[1]+out[3]+out[5]];

		OffsetOut.ar(bus ,Sanitize.ar( Sanitize.ar(out).tanh))



}).add;



)


(
~grainSynth.free;



~grainSynth=Synth.new(\xsensGrain);
)


~fftNetwork.getFFTStatsDancerAllSensors(1)[0].size
~fftNetwork.getBus



