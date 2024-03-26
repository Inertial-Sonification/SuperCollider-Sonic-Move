(

SynthDef(\Mixing,
	{
		var sound = In.ar(~outputBus,12) ;//* [0,0,1,1, 0,0,0,0, 0,0,0,0 ,0,0,0,0];
		var ampOthers= Amplitude.ar(  Mix.ar(sound[0..5]),1.5,1.0 );
			sound[8]=(sound[8]) * (1.0-(10.0* (ampOthers>( -18.dbamp))*ampOthers     ).clip(0.0,1.0));
			sound[9]=(sound[9]) * (1.0-(10.0* (ampOthers>( -18.dbamp))*ampOthers     ).clip(0.0,1.0));

		//sound = ((1.0-(Amplitude.ar(sound[4..5]).clip(0.0,1.0))).dup ++ (1!8)).poll*sound;
		sound = sound.clump(2).flop.collect(_.sum) / 6.0;


		OffsetOut.ar(28, sound  );
	}
).add;





)




(
~output.free;
~output= Synth.tail(~pGroup,\Mixing);




)








