
~sample.plot
"C:/Users/korugaa1/Downloads/0300_oka_ice_w_max_24-02-12.ogg"
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg"
"C:/Users/korugaa1/Downloads/forest.wav"

~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/0300_oka_ice_w_max_24-02-12.ogg".standardizePath, channels:[0]);
~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg".standardizePath, channels:[0]);
[
"C:/Users/korugaa1/Downloads/577705__mistakeless__strings-chord-4-violin.wav",
"C:/Users/korugaa1/Downloads/374618__samulis__violin-section-tremolo-f3-vlnens_trem_g2_v2.wav",
"C:/Users/korugaa1/Downloads/153586__carlos_vaquero__violin-g-4-tenuto-non-vibrato.wav"
]

~sample2 = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/PaliMeursault-SurPlaceEybens.mp3".standardizePath, channels:[0]);

(
~grainSynth.free;

~sample.do(_.free);


~samples1=[
"C:/Users/korugaa1/Downloads/577705__mistakeless__strings-chord-4-violin.wav",
"C:/Users/korugaa1/Downloads/374618__samulis__violin-section-tremolo-f3-vlnens_trem_g2_v2.wav",
"C:/Users/korugaa1/Downloads/153586__carlos_vaquero__violin-g-4-tenuto-non-vibrato.wav"
];

~samples=
[
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg",
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg",
"C:/Users/korugaa1/Downloads/dronelog24022013lankawirain02.ogg",
"C:/Users/korugaa1/Downloads/dronelog24022013lankawirain02.ogg",
"C:/Users/korugaa1/Downloads/PaliMeursault-SurPlaceEybens.mp3",
"C:/Users/korugaa1/Downloads/372817__samulis__cello-section-vibrato-sustain-c2-susvib_c1_v1_1.wav",
"C:/Users/korugaa1/Downloads/372817__samulis__cello-section-vibrato-sustain-c2-susvib_c1_v1_1.wav",
"C:/Users/korugaa1/Downloads/372817__samulis__cello-section-vibrato-sustain-c2-susvib_c1_v1_1.wav"



//"C:/Users/korugaa1/Downloads/PaliMeursault-SurPlacePort.mp3",
//"C:/Users/korugaa1/Downloads/04 Das große melismatische Ehre - Wie (nach den Vesperstichiren) [Lydisch].flac"
];

~sample = ~samples.collect({ |item|  Buffer.readChannel(s,item.standardizePath,channels:[0])   });
~sample1 = ~samples1.collect({ |item|  Buffer.readChannel(s,item.standardizePath,channels:[0])   });

~sample.do(_.normalize);
~sample1.do(_.normalize);



//~sample.free;
//~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg".standardizePath, channels:[0]);


 SynthDef(\xsensGrain,
	{|bus , amp = 0.1 |
		var out;

		var nDancers = ~correlations.nDancers;
		var nSensors = ~correlations.nSensors;

		//var busses = ~xsensValues.values.asArray[ ~xsensValues.keys.asArray.collect({|key|key.postln;(key.split($|)[1].split($-)[1]).asInteger}).order.postln ].postln.collect({|item| (item).getValueBus });

		var busses = nDancers.collect({|i| nSensors.collect({|j|    ~xsensValues.at("dancer-"++(i+1)++"|sensor-"++(j+1)).getValueBus                          }) }).flat;

		// 12 values for each sensor -> after clump 3 -> [3,3,3,3] - euler++jerk++acceleration++angularVelocity
		var measures = busses.collect({|bus| In.kr( bus, bus.numChannels).clumps([3,3,3,3,4,1])}); //size [[[3] , 4], 3]

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

		var lagTime, quadrant;


		amp=amp*energy;

		// [freq, stddev] for each sensor
		fftData = fftData.collect({|sensor|  (sensor.collect({ |measure| measure.sum/(measure.size);   }).sum/(sensor.size));      });




		//organize by combo [ [12,13],  [12,23] , [13,23]]
//don't take magnetic field
		corrData=[((corrData[0][0..2])++(corrData[2][0..2])).flat,
			((corrData[0][0..2])++(corrData[1][0..2])).flat,
			((corrData[1][0..2])++(corrData[2][0..2])).flat];
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
		quadrant=measures.collect({|item|item[5]/125.0 }).asAudioRateInput;

		out = (((cos( (minMaxCorr.flat + 1.0)*pi).abs+0.3)*(amp.stutter(2))*2.0).flat).collect({
			|item,i|

			var fftIn = fftData[i/2] ;
			var ptr=  ( (fftIn[0]*((   ((measures[i/2][0]).mod(2pi)/2pi)*((measures[i/2][0]).mod(2pi)/2pi)).sum.sqrt))  ).wrap(0.06,0.994);

			var wSize = ( (1.0-(fftIn[0]*fftIn[1]*20.0))/10.0).clip(0.01,1.0); //higher frequency smaller window
			var prob  =  1.0.asAudioRateInput;// Lag.ar((amp[i/2]*4.0).asAudioRateInput,0.2).clip(0.001,1.0);
			var wRand = (quadrant[i/2]).wrap(0.0,0.05);
			var freqScale = (1.0 +Lag.ar(( ((fftIn[0]*10.0) -1.0)/10.0).clip(0.0,4.0).asAudioRateInput, (10.0*lagTime[i/2]))      );
			var nSample = ((    1.0-((fftIn[1]*~samples.size).clip(0.0,1.0))    )*1.5*~samples.size).clip(0.0,~samples.size).lincurve(0.0,~samples.size,0.0,~samples.size,-7);
			var sound =(item.clip(0.0,1.0))* 4.0*SelectXFocus.ar(nSample , ~sample.collect({|sample| (

				(3*WarpP.ar(1, sample, ptr.asAudioRateInput, freqScale.asAudioRateInput, wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:1.0.asAudioRateInput))


				+

				(
					(nSample/~samples.size)*2*(//(WarpP.ar(1, sample, ptr.asAudioRateInput, (freqScale/2)+(0.1*measures[i/2][4][0]), wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))+
						(    (Integrator.kr( (measures[i/2][2][0]).abs,0.95 ).clip(0.1,1.0) - 0.1) *WarpP.ar(1, ~sample1[0], ptr.asAudioRateInput*0.5+0.3, (freqScale*3)+((0.0125*measures[i/2][4][1])), 4*wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))+
						(  (Integrator.kr(  (measures[i/2][2][1]).abs,0.95).clip(0.1,1.0) - 0.1)   *WarpP.ar(1, ~sample1[1], ptr.asAudioRateInput*0.5+0.3, (freqScale*0.5)+(0.0125*measures[i/2][4][2]),4* wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))+
						( ( Integrator.kr(  ( (measures[i/2][2][2] ).abs),0.95 ).clip(0.1,1.0) - 0.1) *WarpP.ar(1, ~sample1[2], ptr.asAudioRateInput*0.5+0.3, (freqScale*0.7)+(0.0125*measures[i/2][4][3]), 4*wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))    )//,2.0,Lag.ar(6*lagTime[i/2].asAudioRateInput,10.0)+0.5,1.8)
				)
				+


				((2.0)*WarpP.ar(1, sample, ptr.asAudioRateInput, Lag.ar(freqScale*0.5,lagTime[i/2]), wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))






			) }),((1.0-  ( (  ((lagTime[i/2])-0.09)*18.0).clip(0.0,1.0)  )  )).clip(0.3,inf),false);
sound


		});

		out=( -9.dbamp)*[out[0]+out[2]+out[4],out[1]+out[3]+out[5]];

		OffsetOut.ar(~outputBus.index+2 ,Sanitize.ar( Sanitize.ar(out/6.0).tanh))



}).add;



)


(
~grainSynth.free;



~grainSynth=Synth.new(\xsensGrain,target:~pGroup);
)


~fftNetwork.getFFTStatsDancerAllSensors(1)[0].size
~fftNetwork.getBus



((0 .. 100)/100).lincurve(0.0,1.0,0.0,1.0,-6).plot


~xsensValues.at("dancer-1|sensor-1").enumerateQuadrantStates
Quarks.gui



