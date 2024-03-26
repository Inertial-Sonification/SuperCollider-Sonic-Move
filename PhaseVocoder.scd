

(
a=
{
	|vel = 1.0, offset=0.0|
	var trig = LFPulse.kr(  0.5*(SampleRate.ir / 1024) );
	var trig1 = LFPulse.kr( 0.5*(SampleRate.ir / 1024) , 0.5);
	var e1=EnvGen.ar(Env.sine(1024.0/SampleRate.ir ), trig),
	    e2=EnvGen.ar(Env.sine(1024.0/SampleRate.ir ), trig1);
	//var pc = PulseCount.kr(trig+trig1)%2;
	var mag=LocalBuf(3,513),ph=LocalBuf(3,513);
	var mag1=LocalBuf(3,513),ph1=LocalBuf(3,513);
	var resynth=LocalBuf(1536);
	var resynth1=LocalBuf(1536);


	var trig2 = LFPulse.kr(  0.5*(SampleRate.ir / 1024) ,0.25);
	var trig21 = LFPulse.kr( 0.5*(SampleRate.ir / 1024) , 0.75);
	var e21=EnvGen.ar(Env.sine(1024.0/SampleRate.ir ), trig2),
	    e22=EnvGen.ar(Env.sine(1024.0/SampleRate.ir ), trig21);
	//var pc = PulseCount.kr(trig+trig1)%2;
	var mag2=LocalBuf(3,513),ph2=LocalBuf(3,513);
	var mag21=LocalBuf(3,513),ph21=LocalBuf(3,513);
	var resynth2=LocalBuf(1536);
	var resynth21=LocalBuf(1536);


	var start=(( offset+ Phasor.ar(0,vel* (SampleDur.ir*(BufDur.ir(~destination.bufnum).reciprocal)), 0.0, 1.0)).mod(1.0)*BufFrames.ir(~destination.bufnum));

	var out;

	FluidBufSTFT.kr(~destination,start,trig:trig,magnitude:mag,phase:ph,numFrames:1024);
	FluidBufSTFT.kr(~destination,start,trig:trig1,magnitude:mag1,phase:ph1,numFrames:1024);

	FluidBufSTFT.kr(~destination,start,trig:trig2,magnitude:mag2,phase:ph2,numFrames:1024);
	FluidBufSTFT.kr(~destination,start,trig:trig21,magnitude:mag21,phase:ph21,numFrames:1024);

	FluidBufSTFT.kr(magnitude:mag,phase:ph,inverse:1,resynth:resynth,trig:trig);
	FluidBufSTFT.kr(magnitude:mag1,phase:ph1,inverse:1,resynth:resynth1,trig:trig1);

	FluidBufSTFT.kr(magnitude:mag2,phase:ph2,inverse:1,resynth:resynth2,trig:trig2);
	FluidBufSTFT.kr(magnitude:mag21,phase:ph21,inverse:1,resynth:resynth21,trig:trig21);


	out=(e2*PlayBuf.ar(1,resynth,loop:0,trigger:trig1))+(e1*(PlayBuf.ar(1,resynth1,loop:0,trigger:trig)));
	out=out+(e22*PlayBuf.ar(1,resynth2,loop:0,trigger:trig21))+(e21*(PlayBuf.ar(1,resynth21,loop:0,trigger:trig2)));


	Out.ar(28,0.05*(out.dup.tanh));
}.play


)


a.free

a.set(\vel,0.61, \offset, 1.0.rand)



