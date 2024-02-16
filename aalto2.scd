
(
s.options.numWireBufs=512;
s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
s.options.memSize = 4096 * 256; // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numAudioBusChannels = 1024 * 1024;
s.options.numControlBusChannels = 16384 * 32;


//ServerOptions.devices; //all devices
//ServerOptions.inDevices; //input devices~importMD
//ServerOptions.outDevices;
Server.default.options.sampleRate=44100;
Server.default.options.device="ASIO : MOTU Audio ASIO";
Server.default.options.numInputBusChannels_(0);
Server.default.options.numOutputBusChannels_(30);
//Server.default.options;
s.boot;

)

(
//Buffers
~crumar1.free;
~crumar2.free;
~crumar3.free;
~crumar4.free;
~farfisa.free;
~pad.free;

~xSensBus1.free;
~xSensBus1 = Bus.control(s, 5);


~xSensBus2.free;
~xSensBus2 = Bus.control(s, 5);


~xSensBus3.free;
~xSensBus3 = Bus.control(s, 5);

~crumar1=Buffer.readChannel(s,"D:/Music/samps/Crumar&VL/crumar01.wav".standardizePath,channels:[0]);
~crumar2=Buffer.readChannel(s,"D:/Music/samps/Crumar&VL/crumar02.wav".standardizePath,channels:[0]);
~crumar3=Buffer.readChannel(s,"D:/Music/samps/Crumar&VL/crumar03.wav".standardizePath,channels:[0]);
~crumar4=Buffer.readChannel(s,"D:/Music/crumar.wav".standardizePath,channels:[0]);

~pad=Buffer.readChannel(s,"C:/Users/Aleksandar/Music/synth_pad.wav".standardizePath,channels:[0]);


~farfisa=Buffer.readChannel(s,"D:/Music/samps/Farfisa/farfisaComposite.wav".standardizePath,channels:[0]);

)


(

~com0.free;
~com0 = Bus.control(s,6);
~comPrev = [0,0,0];
OSCFunc.new({|msg, time, addr, recvPort|
	//var data=(msg[1 .. (msg.size-1)]);
	var diff=msg[2..4]-~comPrev;
	~comPrev=msg[2..4];
	//msg.postln;
	//diff.postln;
	~com0.setn( (msg[2..4]++diff));


},"/COM0", recvPort:7001); // path matching


~var0.free;
~var0 = Bus.control(s,18);
~var0prev=0!9;
OSCFunc.new({|msg, time, addr, recvPort|
	//var data=(msg[1 .. (msg.size-1)]);
	var diff =  msg[2..10] - ~var0prev;

	~var0prev=msg[2..10];
	~var0.setn( (msg[2..10]++[diff]).flat);


},"/VAR0", recvPort:7001); // path matching




~xSensAcc = [0,0,0];
~xSensAngles = [[0,0,0],[0,0,0],[0,0,0]];
~xSensTrig=[0,0,0];

OSCFunc.new({|msg, time, addr, recvPort|
	//var data=(msg[1 .. (msg.size-1)]);
	//var diff=msg[1..3]-~xsensPrev;
	//~xsensPrev=msg[1..3];
	//5 4 3 3
	//acc
	//gyro
	//mag
	//euler
	var acc=msg[5];
	var nSens=msg[1]-11;
	~xSensAngles[nSens] = msg[14..16];

	~xSensTrig[nSens]=abs( acc - ~xSensAcc[nSens]) ;

	~xSensAcc[nSens] = acc;

	//nSens.post;
	//" ".post;
	//~xSensTrig[nSens].postln;

	switch(nSens,

		0,{~xSensBus1.setn( ([~xSensAngles[nSens]]++[~xSensTrig[nSens]]++ [~xSensAcc[nSens]]).flat  );},
		1,{~xSensBus2.setn( ([~xSensAngles[nSens]]++[~xSensTrig[nSens]]++ [~xSensAcc[nSens]]).flat );},
		2,{~xSensBus3.setn( ([~xSensAngles[nSens]]++[~xSensTrig[nSens]]++ [~xSensAcc[nSens]]).flat);}

	);




	//if(msg[1]==11, {


	/*
	"acc ".post;
	msg[2..6].postln;

	"gyro ".post;
	msg[7..10].postln;

	"mag ".post;
	msg[11..13].postln;

	"euler ".post;
	msg[14..16].postln;
		*/
		//});
	//~com0.setn( (msg[1..3]++diff));


},"/xsens", recvPort:50003); // path matching










{
	var inputs = ~xSensBus1.kr();
	var trig = inputs[3];
	var angles = (inputs[0..2]/180.0).linlin(-1.0,1.0,0.0,1.0);
	var env = Integrator.kr(trig /400.0 ,0.995).clip(0,1);

	//var ccpos = (~com0.kr()[3..5]);


	var camPos1 = (~com0.kr()[0..2]);
	var diffCam =HPZ1.kr( camPos1 );

	var camVar1 = (~var0.kr()[0..8]);

	var camThreshMovVar =camVar1.collect({|item,i|  item.abs}).reduce('+')  ;//diffCamVar.collect({|item,i| ( (item)*(item))}).reduce('+').sqrt;
	var diffCamVar =HPZ1.kr( (camThreshMovVar) );

	var camEnvVar = ((Integrator.kr(diffCamVar*100.0  ,0.99) -0.2 )).clip(0,1).poll;

	var camThreshMov =   ( ( (diffCam[0])*(diffCam[0]))  + ((diffCam[1])*(diffCam[1]))+ ((diffCam[2])*(diffCam[2]))).sqrt ;


	var camEnv = ((camEnvVar)+((Integrator.kr(camThreshMov*5  ,0.99)-0.1).clip(0,1)))/2;

	var gyroOut=env*WarpP.ar(1,~pad,K2A.ar(angles[0].clip(0,1)),K2A.ar((angles[1].clip(0,1)*3)+0.5),(0.3*env*(K2A.ar(angles[2].clip(0,1)))+0.001) ,prob:Lag.ar(K2A.ar(env),0.03)  );

	var posOut=camEnv*WarpP.ar(1,~pad,K2A.ar(camPos1[0].linlin(-5.0,5.0,0.0,1.0).wrap(0.0,1.0)),K2A.ar((camPos1[2].linlin(-5.0,5.0,0.0,1.0).wrap(0,1)*0.1)+0.25),(0.3*camEnv*(K2A.ar(camPos1[2].linlin(-5.0,5.0,0.0,1.0).wrap(0,1)))+0.001) ,prob:Lag.ar((K2A.ar(camEnv)*10.0).clip(0.0,1.0),0.03),windowRandRatio:K2A.ar(0.02)  );





	var out=Sanitize.ar(PMWave.ar( Sanitize.ar( (3*posOut) + gyroOut), K2A.ar(1.0),   K2A.ar(camPos1[2].linlin(-5.0,5.0,0.0,1.0).clip(0.01,0.99) +0.5  ), K2A.ar(0.1), K2A.ar(0.0001),K2A.ar(0.1),K2A.ar(0.1),K2A.ar(1.0) ));

	[out,out,out,out]*0.02;




}.play;



)



(
~com0.free;
~com0 = Bus.control(s,6);
~comPrev = [0,0,0];
OSCFunc.new({|msg, time, addr, recvPort|
	//var data=(msg[1 .. (msg.size-1)]);
	var diff=msg[2..4]-~comPrev;
	~comPrev=msg[2..4];
	//msg.postln;
	(msg[2..4]++diff).postln;
	~com0.setn( (msg[2..4]++diff));


},"/COM0", recvPort:7001); // path matching


~var0.free;
~var0 = Bus.control(s,18);
~var0prev=0!9;
OSCFunc.new({|msg, time, addr, recvPort|
	//var data=(msg[1 .. (msg.size-1)]);
	var diff =  msg[2..10] - ~var0prev;
//msg.postln;
	//diff.postln;
	~var0prev=msg[2..10];
	~var0.setn( (msg[2..10]++[diff]).flat);


},"/VAR0", recvPort:7001); // path matching


)

(
~com1 = Bus.control(s,6);
~comPrev1 = [0,0,0];
OSCFunc.new({|msg, time, addr, recvPort|
	//var data=(msg[1 .. (msg.size-1)]);
	var diff=msg[2..4]-~comPrev1;
	~comPrev1=msg[2..4];
msg.postln;
	diff.postln;
	~com1.setn( (msg[2..4]++diff));


},"/COM1", recvPort:7001); // path matching



~var1 = Bus.control(s,18);
~var1prev=0!9;
OSCFunc.new({|msg, time, addr, recvPort|
	//var data=(msg[1 .. (msg.size-1)]);
	var diff =  msg[2..10] - ~var1prev;
	~var1prev=msg[2..10];
	~var1.setn( (msg[2..10]++[diff]).flat  );


},"/VAR1", recvPort:7001); // path matching


)















(

{
	var out=Mix.ar(
		0.01*[SinOsc.ar(250+(~com0.kr[0]*100.0)),SinOsc.ar(200+(~com0.kr[1]*100.0)),SinOsc.ar(100+(~com0.kr[2]*100.0))]
	);
	[0,0,out,out];

}.play


)

(

{
	var out=Mix.ar(
		0.01*[SinOsc.ar(350+(Lag.kr(~var0.kr[0],0.03)*10000.0)),SinOsc.ar(300+(Lag.kr(~var0.kr[1],0.03)*10000.0)),SinOsc.ar(400+(Lag.kr(~var0.kr[2],0.03)*10000.0)),
			SinOsc.ar(350+(Lag.kr(~var0.kr[3],0.03)*10000.0)),SinOsc.ar(300+(Lag.kr(~var0.kr[4],0.03)*10000.0)),SinOsc.ar(400+(Lag.kr(~var0.kr[5],0.03)*10000.0)),
			SinOsc.ar(350+(Lag.kr(~var0.kr[6],0.03)*10000.0)),SinOsc.ar(300+(Lag.kr(~var0.kr[7])*10000.0)),SinOsc.ar(400+(Lag.kr(~var0.kr[8],0.03)*10000.0))
		]
	);
	[0,0,out,out];

}.play


)














(

{
	var out=Mix.ar(
		0.01*[SinOsc.ar(350+(~com1.kr[0]*100.0)),SinOsc.ar(300+(~com1.kr[1]*100.0)),SinOsc.ar(400+(~com1.kr[2]*100.0))]
	);
	[0,0,out,out];

}.play


)







~var0.get







(
{


	var out=Mix.ar(~var0.kr.collect({
		|item,i|
		var time=0.1+Timer.kr( ((item.abs*300)>1.0)).clip(0.0,1.0);
		var trig =(((item.abs*300)>1.0)+(~com0.kr[3].abs>0.05)+ (~com0.kr[4].abs>0.05) +(~com0.kr[5].abs>0.05)).clip(0.0,1.0);
		((EnvGen.ar(Env.perc(0.001,time),trig ))+0.0)* WarpP.ar(1,~crumar1, (((~com0.kr[0]+~com0.kr[1]+~com0.kr[2])+0.5)+(i*0.3)).wrap(0.0,1.0),1.0,((item+1.2)/2).wrap(0.001,0.8),windowRandRatio:0.01,prob:(((~com0.kr[3].abs)+ (~com0.kr[4].abs) +(~com0.kr[5].abs))*4.0).clip(0.0,1.0));
	}));
		//~com0.kr[3..5].poll;
	out= PMWave.ar(Sanitize.ar( out.tanh),
		1.0.asAudioRateInput,//((~var0.kr[0]/2)+0.5).wrap(0.9,0.999).asAudioRateInput,
		((~var0.kr[4]/2)+1.5).wrap(0.5,0.999).asAudioRateInput,
		((~var0.kr[8]/2)+1.5).wrap(0.02,0.3).asAudioRateInput,
		0.00001.asAudioRateInput,
		((~var0.kr[0]/2)+1.5).wrap(0.2,0.4999).asAudioRateInput,
		((~var0.kr[3]/2)+1.5).wrap(0.2,0.4999).asAudioRateInput,
		((~var0.kr[7]/2)+1.5).wrap(0.99,1.0).asAudioRateInput

	);
	~var0.kr[7].poll;
	out=Sanitize.ar( out.tanh);
		[0,0,0.1*out,0.1*out]

		//((item.abs*100)>1.0) * SinOsc.ar(1000+ (i*200) + ( ((item.abs*100)>1.0)* item*1000.0))



}.play
)




(
{
//	(~var0.kr*100.0).poll;


	var out=Mix.ar(~var1.kr.collect({
		|item,i|
		//item.poll;
		var time=0.1+Timer.kr( ((item.abs*300)>1.0)).clip(0.0,1.0);
		var trig =(((item.abs*300)>1.0)+(~com1.kr[3].abs>0.05)+ (~com1.kr[4].abs>0.05) +(~com1.kr[5].abs>0.05)).clip(0.0,1.0);
		((EnvGen.ar(Env.perc(0.001,time),trig ))+0.0)* WarpP.ar(1,~farfisa, (((~com1.kr[0]+~com1.kr[1]+~com1.kr[2])+0.5)+(i*0.3)).wrap(0.0,1.0),2.2,((item+0.6)/2).wrap(0.03,0.1),windowRandRatio:0.01,prob:(((~com1.kr[3].abs)+ (~com1.kr[4].abs) +(~com1.kr[5].abs))*4.0).clip(0.0,1.0));
	}));
		//~com0.kr[3..5].poll;
	out= PMWave.ar(Sanitize.ar( out.tanh),
		1.0.asAudioRateInput,//((~var0.kr[0]/2)+0.5).wrap(0.9,0.999).asAudioRateInput,
		((~var1.kr[4]/2)+1.5).wrap(0.5,0.999).asAudioRateInput,
		((~var1.kr[8]/2)+1.5).wrap(0.02,0.3).asAudioRateInput,
		0.00001.asAudioRateInput,
		((~var1.kr[0]/2)+1.5).wrap(0.2,0.4999).asAudioRateInput,
		((~var1.kr[3]/2)+1.5).wrap(0.2,0.4999).asAudioRateInput,
		((~var1.kr[7]/2)+1.5).wrap(0.99,1.0).asAudioRateInput

	);
	out=Sanitize.ar( out.tanh);
		[0,0,0.4*out,0.4*out]

		//((item.abs*100)>1.0) * SinOsc.ar(1000+ (i*200) + ( ((item.abs*100)>1.0)* item*1000.0))



}.play
)



OSCFunc.trace
