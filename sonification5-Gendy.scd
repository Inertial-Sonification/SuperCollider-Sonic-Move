"a"++"b"




(

SynthDef(\gendyXsens,{

	|distA=1,distD=1,ad=0.9,dd=0.9,amp=0.09,dur=0.02,k=12  |

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
		(Integrator.ar( item[2].collect({|item|(item*item)}).reduce('+').sqrt,0.99).clip(0.3,inf)-0.3)+ //acceleration
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

		amp=(((amp.clip(0.1,inf))-0.11)/50.0).clip(0.0,1.0).flat;

		out = (((cos( (minMaxCorr.flat + 1.0)*pi).abs+0.3)*(amp.stutter(2))*2.0).flat).collect({
			|item,i|


			var ptr=  ((   ((measures[i/2][0]).mod(2pi)/2pi)*((measures[i/2][0]).mod(2pi)/2pi)).sum.sqrt).wrap(0.0,1.0);
			var fftIn = fftData[i/2] ;
			//jerk trigger
			var trig =Trig.ar((((measures[i/2][1])*(measures[i/2][1])).sum.sqrt > 0.5).asAudioRateInput,0.2);
			//var env = EnvGen.ar(Env.perc(0.001,1.9), trig);
			//var env1 = EnvGen.ar(Env.perc(0.001,1.0), trig);
			var nSample = ((    1.0-((fftIn[1]*5.0).clip(0.0,1.0))    )*1.5).clip(0.0,1.0);

		var freq = (30.0+(  (( ((Lag.kr(fftIn[0],0.5)*5.0)).clip(0.0,1.0).lincurve(0.0,1.0,0.0,1.0,4)*(item)*((i+1)*100.0*(minMaxCorr[i/2][i%2])))+0.0001).asAudioRateInput)).clip(30.0,10000.0);

		// //////////////////synthesis
		    var r1 ={LFNoise1.ar(fftIn[1]*10.0)}!5;
			var r2 ={LFNoise1.ar(fftIn[1]*10.0)}!5;
			var min = Select.ar(r1 >= r2,[ r1 , r2  ]  ).linlin(-1.0,1.0,0.001,1.0);
			var max = Select.ar(r1 >= r2,[ r2 , r1  ]  ).linlin(-1.0,1.0,0.001,1.0);
		var masks = LFNoise1.ar((fftIn[0] + nSample)*100.0).linlin(-1.0,1.0,min,max);
			var wSize =  ((1.0-(fftIn[0]*fftIn[1]*20.0))).clip(0.0,1.0); //higher frequency smaller window



		var sound =((amp[i/2]).clip(0.0,1.0))*wSize* Gendy3.ar(distA,distD,(ad* (masks[0])),dd*(masks[1]),freq+(masks[2]*freq),amp[i/2]*(masks[3]),dur*(masks[4]),12,k.clip(1,12));
			sound=(sound) + (    Slew.ar(item.clip(0.0,1.0),1000.0,0.8)   *2.5*Sanitize.ar(PMWave.ar( Sanitize.ar(sound.tanh), ((0.97+((2pi*nSample).sin.abs*0.03)).clip(0.0,0.9999)).asAudioRateInput,((0.95 +(0.048 * fftIn[0]))).clip(0.001,0.99).asAudioRateInput, 0.1.asAudioRateInput, 0.00001.asAudioRateInput, 0.1.asAudioRateInput, 0.2.asAudioRateInput,1.0.asAudioRateInput).tanh));
		sound=Sanitize.ar((2* sound).tanh);


		});



	out=( 0.dbamp)*[out[0]+out[2]+out[4],out[1]+out[3]+out[5]];

	OffsetOut.ar(~outputBus.index+8, ( 6.dbamp)*( Sanitize.ar(LeakDC.ar( out))))
}).add




)

(
~gendy.free;


~gendy=Synth.new(\gendyXsens,target:~pGroup)
)
































a = SynthDescLib.global; // the global library of SynthDescs
x = a.synthDescs.at(\default); // get the default SynthDesc
x.controls.do { |ctl| [\name, ctl.name, \defaultValue, ctl.defaultValue].postln };"";


 x=SynthDescLib.global.synthDescs.at(~gendy.defName);
x.controlNames
([x.controlNames] ++ [[1,2,0.9,0.9,30.0,0.9,0.01,4]++(([0.20.rand,0.1.rand,0.1.rand]))  ]).flop.do({|item| item.postln; ~gendy.set(item[0],item[1])} )



