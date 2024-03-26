
~sample.plot
["C:/Users/korugaa1/Downloads/0300_oka_ice_w_max_24-02-12.ogg"].flatten(0)
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg"
"C:/Users/korugaa1/Downloads/forest.wav"

~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/0300_oka_ice_w_max_24-02-12.ogg".standardizePath, channels:[0]);
~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg".standardizePath, channels:[0]);
~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/forest.wav".standardizePath, channels:[0]);



~samples=
[
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg",
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg",
"C:/Users/korugaa1/Downloads/dronelog24022013lankawirain02.ogg",
"C:/Users/korugaa1/Downloads/dronelog24022013lankawirain02.ogg",
"C:/Users/korugaa1/Downloads/PaliMeursault-SurPlaceEybens.mp3",
//"C:/Users/korugaa1/Downloads/372817__samulis__cello-section-vibrato-sustain-c2-susvib_c1_v1_1.wav",
//"C:/Users/korugaa1/Downloads/372817__samulis__cello-section-vibrato-sustain-c2-susvib_c1_v1_1.wav",
//"C:/Users/korugaa1/Downloads/372817__samulis__cello-section-vibrato-sustain-c2-susvib_c1_v1_1.wav"
//"C:/Users/korugaa1/Downloads/218941__sluri6__piano-improv-gm.wav",
//"C:/Users/korugaa1/Downloads/218941__sluri6__piano-improv-gm.wav",
//"C:/Users/korugaa1/Downloads/218941__sluri6__piano-improv-gm.wav"

//"C:/Users/korugaa1/Downloads/0006-converted.mp3",
//"C:/Users/korugaa1/Downloads/0006-converted.mp3",
//"C:/Users/korugaa1/Downloads/0006-converted.mp3"


//"C:/Users/korugaa1/Downloads/168050__zigzagzen__bending-galve.wav",//2
//"C:/Users/korugaa1/Downloads/168050__zigzagzen__bending-galve.wav",//2
//"C:/Users/korugaa1/Downloads/168050__zigzagzen__bending-galve.wav",//2


//"C:/Users/korugaa1/Downloads/193712__earwicker23__metal-farm-gate-in-wales-bent-metal.mp3",//2
//"C:/Users/korugaa1/Downloads/193712__earwicker23__metal-farm-gate-in-wales-bent-metal.mp3",//2
//"C:/Users/korugaa1/Downloads/193712__earwicker23__metal-farm-gate-in-wales-bent-metal.mp3",//2




//"C:/Users/korugaa1/Downloads/716507__klankbeeld__marina-lage-zwaluwe-nl-1.wav",//hanna
//"C:/Users/korugaa1/Downloads/716507__klankbeeld__marina-lage-zwaluwe-nl-1.wav",//hanna
//"C:/Users/korugaa1/Downloads/716507__klankbeeld__marina-lage-zwaluwe-nl-1.wav",//hanna

"C:/Users/korugaa1/Downloads/85960__b0bd0bbs__big_steel_disk1.wav",//c
"C:/Users/korugaa1/Downloads/85960__b0bd0bbs__big_steel_disk1.wav",//c
"C:/Users/korugaa1/Downloads/85960__b0bd0bbs__big_steel_disk1.wav",//c


//"C:/Users/korugaa1/Downloads/245394__klankbeeld__scrap-metal-processing-industry-long-140801_0325.flac",
//"C:/Users/korugaa1/Downloads/245394__klankbeeld__scrap-metal-processing-industry-long-140801_0325.flac",
//"C:/Users/korugaa1/Downloads/245394__klankbeeld__scrap-metal-processing-industry-long-140801_0325.flac",

	/**/

//"C:/Users/korugaa1/Downloads/PaliMeursault-SurPlacePort.mp3",
//"C:/Users/korugaa1/Downloads/04 Das große melismatische Ehre - Wie (nach den Vesperstichiren) [Lydisch].flac"
];












~samples.postcs


[1,2,3]++[4,5,6]

(
~grainSynth.free;

~grainSynth=Synth.new(\xsensGrain,target:~pGroup);
)

(
~grainSynth.free;

~sample.do(_.free);

~samples=
([
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg",
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg",
"C:/Users/korugaa1/Downloads/dronelog24022013lankawirain02.ogg",
"C:/Users/korugaa1/Downloads/dronelog24022013lankawirain02.ogg",
"C:/Users/korugaa1/Downloads/PaliMeursault-SurPlaceEybens.mp3",
]

	++
(([
"C:/Users/korugaa1/Downloads/269366__lwdickens__brook-winter-ice-forest-water-under-ice_2.wav", //no
"C:/Users/korugaa1/Downloads/650544__klankbeeld__walk-in-water-220903_0523.wav",//!!!! 1
"C:/Users/korugaa1/Downloads/234076__thalamus_lab__metal-drone-old-fire-extinguisher.wav",//!!!!! 2 - Good threshold for slw. too high for grains
"C:/Users/korugaa1/Downloads/439482__epicwizard__berlin-hauptbahnhof-night-ambience-loud.wav",
"C:/Users/korugaa1/Downloads/547168__ian_g__eurostar-train-leaving-london.wav",//4 no
"C:/Users/korugaa1/Downloads/553751__tatratank__drops-in-the-heating-pipes.wav",//5 !
"C:/Users/korugaa1/Downloads/494684__klankbeeld__single-cylinder-tug-500m-away-191120_0091.wav",//6
"C:/Users/korugaa1/Downloads/636265__dibko__zrkovci-left-side-of-the-bridge.wav", //7
"C:/Users/korugaa1/Downloads/369429__klankbeeld__far-rivervillage-nov-nl-161127_1055.flac",//8
"C:/Users/korugaa1/Downloads/640306__dibko__celje-freight-train.wav",//9
"C:/Users/korugaa1/Downloads/390612__klankbeeld__early-spring-city-8-am-170429_1120.wav",//10 -
"C:/Users/korugaa1/Downloads/394002__klankbeeld__view-island-walcheren-nl-02-170522_1178.flac",//11 -
"C:/Users/korugaa1/Downloads/394402__klankbeeld__ship-and-train-150811_0727.wav",//12
"C:/Users/korugaa1/Downloads/588675__klankbeeld__spring-field-ambience-nl-05-190421_1375.wav",//13 -




"C:/Users/korugaa1/Downloads/192325__be-steele__hornbdx.wav",//14 !!!!!
"C:/Users/korugaa1/Downloads/232899__jarvey33__huge-horn.aiff",
"C:/Users/korugaa1/Downloads/431429__generationmachine__psyf2horns.wav",
"C:/Users/korugaa1/Downloads/385282__mullumbimby__horn_doppler_faraway_01.wav",
	"C:/Users/korugaa1/Downloads/394556__emmithi123__reese-bass.wav",//18 !!!!!! = intersting robotic sound, too loud big movements - keeps dancer from going big
"C:/Users/korugaa1/Downloads/85096__blackie666__reese-2.wav",//19
"C:/Users/korugaa1/Downloads/236933__magnesium1__mag-reese-bass-1.aiff",//20
"C:/Users/korugaa1/Downloads/719838__autumncheney__reese_00_c.wav",//21  !!!!!!


"C:/Users/korugaa1/Downloads/372817__samulis__cello-section-vibrato-sustain-c2-susvib_c1_v1_1.wav",//22
"C:/Users/korugaa1/Downloads/218941__sluri6__piano-improv-gm.wav",//23
"C:/Users/korugaa1/Downloads/0006-converted.mp3",//24
"C:/Users/korugaa1/Downloads/168050__zigzagzen__bending-galve.wav",//25

"C:/Users/korugaa1/Downloads/SciFi812.mp3",
"C:/Users/korugaa1/Downloads/193712__earwicker23__metal-farm-gate-in-wales-bent-metal.mp3",//26

"C:/Users/korugaa1/Downloads/716507__klankbeeld__marina-lage-zwaluwe-nl-1.wav",//hanna 27 NO BIRDS -> persopn should bve bird -- not "mimetic", not representing existing things, body inhabiting -  PUT WINDY QUALITY

"C:/Users/korugaa1/Downloads/85960__b0bd0bbs__big_steel_disk1.wav",//c


"C:/Users/korugaa1/Downloads/245394__klankbeeld__scrap-metal-processing-industry-long-140801_0325.flac"

	][21])!3).flatten(0)
);



~sample = ~samples.collect({ |item|  Buffer.readChannel(s,item.standardizePath,channels:[0])   });

~sample.do(_.normalize);



//~sample.free;
//~sample = Buffer.readChannel(s,"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg".standardizePath, channels:[0]);


 SynthDef(\xsensGrain,
	{|bus , amp = 0.1 |
		var out;

		var nDancers = ~correlations.nDancers;
		var nSensors = ~correlations.nSensors;

		//var busses = ~xsensValues.values.asArray[ ~xsensValues.keys.asArray.collect({|key|key.postln;(key.split($|)[1].split($-)[1]).asInteger}).order.postln ].postln.collect({|item| (item).getValueBus });

		var busses = nDancers.collect({|i| nSensors.collect({|j|    ~xsensValues.at("dancer-"++(i+1)++"|sensor-"++(j+1)).getValueBus                          }) }).flat;

		// 12 values for each sensor -> after clump 3 -> [3,3,3,3,4,1,1] - euler++jerk++acceleration++angularVelocity++quaternion++quadrant++energy
		var measures = busses.collect({|bus| In.kr( bus, bus.numChannels).clumps([3,3,3,3,4,1,1])}); //size [[[3] , 4], 3]

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
			var en = item[6].asAudioRateInput;
			//item = item.asAudioRateInput;
			//(Integrator.ar( item[2].collect({|item|item*item}).reduce('+').sqrt,0.997).clip(0.3,inf)-0.3)+ //acceleration
			//(item[3].collect({|item|item*item}).reduce('+')) //keep v*v for kinetic energy so no sqrt

			});

		var minMaxCorr;

		var lagTime;


		amp=(amp*energy);

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


		out = (((cos( (minMaxCorr.flat + 1.0)*pi).abs+0.3)*(amp.stutter(2))*2.0).flat).collect({
			|item,i|
			var corr=minMaxCorr.flat[i];
			var fftIn = fftData[i/2] ;

			var nSample = ((    1.0-((fftIn[1]*~samples.size).clip(0.0,1.0))    )*1.5*~samples.size).clip(0.0,~samples.size).lincurve(0.0,~samples.size,0.0,~samples.size,-5);
			var nnSample = (1.0- (nSample/~samples.size));
			var ptr=  ((nnSample*( (fftIn[0]*((   ((measures[i/2][0]).mod(2pi)/2pi)*((measures[i/2][0]).mod(2pi)/2pi)).sum.sqrt)) )));

			var wSize =  ((1.0-(fftIn[0]*fftIn[1]*20.0))).clip(0.01,1.0); //higher frequency smaller window
			var prob  =  (Lag.ar((amp[i/2]*4.0).asAudioRateInput,0.2).clip(0.001,1.0));
			var wRand = ((fftIn[1]*0.1).clip(0.0,0.03));
			var freqScale = 1.0.asAudioRateInput;
			var sound = SelectXFocus.ar(nSample , ~sample.collect({|sample|
				var idx =(Phasor.ar(0, BufRateScale.kr(sample), 0, BufFrames.kr(sample))/BufFrames.kr(sample));
				var pt= ((ptr*44100.0)/BufFrames.kr(sample));
				(
					(WarpP.ar(1, sample, (idx + pt.asAudioRateInput).wrap(0.05,0.95), freqScale*(1.0+(i/12.0))*((corr/2)+1.0), wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))  +
				(WarpP.ar(1, sample,(idx + pt.asAudioRateInput).wrap(0.05,0.95), freqScale*(1.0+(i/12.0))*((corr/2)+1.0), wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))+
				(WarpP.ar(1, sample, (idx + pt.asAudioRateInput).wrap(0.05,0.95), freqScale*(1.0+(i/12.0))*((corr/2)+1.0), wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))+
				(2*WarpP.ar(1, sample, ptr.asAudioRateInput, freqScale*0.333, wSize.asAudioRateInput, windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))








				//+((1.0)*WarpP.ar(1, sample, (ptr.asAudioRateInput+(0.1*(measures[i/2][0][0]))).wrap(0.0,1.0), freqScale*(1+(0.2*(measures[i/2][0][0]))), wSize.asAudioRateInput *(1+(0.1*(measures[i/2][0][0]))) , windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))
				//+((1.0)*WarpP.ar(1, sample, (ptr.asAudioRateInput+(0.1*(measures[i/2][0][1]))).wrap(0.0,1.0), freqScale*(1+(0.2*(measures[i/2][0][1]))), wSize.asAudioRateInput*(1+(0.1*(measures[i/2][0][0]))), windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))
				//+ ((1.0)*WarpP.ar(1, sample, (ptr.asAudioRateInput+(0.1*(measures[i/2][0][2]))).wrap(0.0,1.0), freqScale*(1+(0.2*(measures[i/2][0][2]))), wSize.asAudioRateInput*(1+(0.1*(measures[i/2][0][0]))), windowRandRatio:wRand.asAudioRateInput, prob:prob.asAudioRateInput))



			) }),0.5,false);
			(sound*item)+(Sanitize.ar(PMWave.ar( Sanitize.ar((sound*item).tanh), ((0.87+((2pi*nSample).sin.abs*0.03)).clip(0.0,0.9999)).asAudioRateInput,((0.1 +(0.9 * fftIn[0]))).clip(0.001,0.99).asAudioRateInput, 0.1.asAudioRateInput, 0.00001.asAudioRateInput, 0.1.asAudioRateInput, 0.2.asAudioRateInput,1.0.asAudioRateInput).tanh))
			//(((1.5-(nSample/~samples.size)))*2*sound) + ((nSample/~samples.size+0.6)*Sanitize.ar(PMWave.ar( Sanitize.ar(sound.tanh), ((0.6+(nSample/(~samples.size*6))).clip(0.0,0.9999)).asAudioRateInput,(1.0-(0.1 +(0.9 * fftIn[0]))).clip(0.001,0.99).asAudioRateInput, 0.1.asAudioRateInput, 0.00001.asAudioRateInput, 0.1.asAudioRateInput, 0.2.asAudioRateInput,1.0.asAudioRateInput).tanh));

		});

		out=( 0.dbamp)*[out[0]+out[2]+out[4],out[1]+out[3]+out[5]];

		OffsetOut.ar(~outputBus.index+2 ,Sanitize.ar( Sanitize.ar(out).tanh))



}).add;



)


(
~grainSynth.free;



~grainSynth=Synth.new(\xsensGrain,target:~pGroup);
)

SinOsc.ar(((fftData.flop[0][i/2]).poll*30.0),0.3,(nSample/~samples.size)*corr,1.0-(nSample/~samples.size)).abs*(item.clip(0.0,1.0))*
~fftNetwork.getFFTStatsDancerAllSensors(1)[0].size
~fftNetwork.getBus



((0 .. 100)/100).lincurve(0.0,1.0,0.0,1.0,-6).plot



