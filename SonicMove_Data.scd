

//FROM CAMERAS
// format of message is [/address,  key , 3 coords  , 9 coords, ... ]

(
~cameraValues = Dictionary.new();


OSCFunc.new({|msg, time, addr, recvPort|

	var data=(msg[1 .. (msg.size-1)]).clump(13);
	var tempKeys = [];
	var noUpdate;

	data.do({|item,i|

		var key = (item[0]).asInteger;
		var position = item[1..3];
		var covariance = (item[4 .. (item.size-1)]).clump(3);

		tempKeys = tempKeys.add(key);


		if( ~cameraValues.includesKey(key),
			{
				//key exists -> calculate speeds and store
				~cameraValues.at(key).update(position, covariance);

			},
			{
				//key doesn't exist - set speed to 0 and add position/key
				var elem = SonicMovePositionData.new(position, covariance);
				~cameraValues.put(key, elem);


		}

		);


		//eliminate dropped keys
		noUpdate = difference(~cameraValues.keys, tempKeys.asSet);


		noUpdate.do({|item| ~cameraValues.removeAt(item) });





	});

},"/depthCamera", recvPort:7001); // path matching


w = Window("posData",Rect(128, 64, 500, 500)).front;
w.view.background_(Color.white);
w.view.decorator = FlowLayout(w.view.bounds);


w.drawFunc = {
    Pen.translate(0, 0);

	Pen.color = Color.new255(50,50,50);

	Pen.addRect(Rect(0,0,500,500));


	Pen.perform(\fill);


	~cameraValues.keysValuesDo { |key, value|
	Pen.use{
			var pos = value.position;

			Pen.color = Color.new255((key.asInteger*100.0)%255,0,128);

			Pen.translate(250, 500);


		Pen.addArc( ((pos[0])*100.0)@((pos[2])*100.0), 10, 0, 2pi);
		Pen.perform(\fill);
	}
	};



};

	{ while { w.isClosed.not } { w.refresh; 0.04.wait; } }.fork(AppClock);



)

// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//XSENS



(
s.freeAll;
~xsensValues = Dictionary.new();

~receiveSensor.free;
~receiveCorrelationSelf.free;
~receiveCorrelationOthers.free;
~receiveNDancers.free;
~receiveNSensors.free;
~receiveFFT.free;
~receiveFFTStats.free;
~bodyGestureNumber = Dictionary.new();
~maxGestures= 0;
//measures OSC receiver

~receiveSensor = OSCFunc.new({|msg, time, addr, recvPort|
	//0 address 1 n 2 acc1            3  acc2             4 acc3			5 accTot		  6 T 7 gyro1           8 gyro2             9 gyro3          10 tot gyro          11 mag           12 mag            13 mag            14 euler1         15   euler2        16 euler 3     17 quaternion  x 4

	//sensor number
	var nDancer = (msg[1]/10).asInteger;
	var nSensor =  msg[1] - (nDancer * 10);
	var key = "dancer-"++nDancer++"|"++"sensor-"++nSensor;
	//(msg.size-17).postln;


	if( ~xsensValues.includesKey(key),
	{
			var totalGesture=0;
				//key exists -> calculate speeds and store
			~xsensValues.at(key).update( msg[2..4], msg[5], msg[6], msg[7..9], msg[10], msg[11..13], msg[14..16] , msg[17..20]  );


			//Code for assembling whole body descriptor

			~xsensValues.keysValuesDo({
				|key, value|

				var max = value.enumerateQuadrantStates();
				var sensor = (key.split($|)[1].split($-)[1]).asInteger-1;


				totalGesture = totalGesture + ((max.pow(sensor))*  value.quadrant);




			});
			~bodyGestureNumber.put(nDancer,totalGesture);


	},
	{
				//key doesn't exist - set speed to 0 and add position/key
			var elem = SonicMoveXsensData.new(msg[2..4], msg[5], msg[6], msg[7..9], msg[10], msg[11..13], msg[14..16], msg[17..20]);

			~xsensValues.put(key, elem);


	}
	);



},"/xsens", recvPort:50003); // path matching

//Self Correlations OSC receiver
//'ori_p', 'ori_r', 'ori_y', 'acc_x', 'acc_y', 'acc_z', 'gyr_x','gyr_y','gyr_z', 'mag_x', 'mag_y', 'mag_z'

~correlations = SonicMoveXsensCorrelations.new();

~receiveCorrelationSelf=OSCFunc.new({|msg, time, addr, recvPort|

	var val = msg[1 ..(msg.size-1)] ;

	//val.collect({|it|it.clump(3).collect({|item|  (item**2).reduce('+') }).sqrt}).flop.postln;
	//val.postln;
	~correlations.updateSelf(val);




},"/xsens-correlation-self", recvPort:50003); // path matching



~receiveCorrelationOthers=OSCFunc.new({|msg, time, addr, recvPort|

	var val = msg[1 ..(msg.size-1)] ;

	//val.collect({|it|it.clump(3).collect({|item|  (item**2).reduce('+') }).sqrt}).flop.postln;
	//val.postln;
	~correlations.updateOthers( val);




},"/xsens-correlation-others", recvPort:50003); // path matching




~receiveNDancers =OSCFunc.new({|msg, time, addr, recvPort|

	var val = msg[1 ..(msg.size-1)] ;
	//~fftNetwork = val.clump(17).clump(12).postln;
	~correlations.setNDancers(val[0]);




},"/xsens-nDancers", recvPort:50003); // path matching


~receiveNSensors =OSCFunc.new({|msg, time, addr, recvPort|

	var val = msg[1 ..(msg.size-1)] ;
	~correlations.setNSensors(val[0]);

	//~fftNetwork = val.clump(17).clump(12).postln;




},"/xsens-nSensors", recvPort:50003); // path matching


~fftNetwork = SonicMoveXsensFFT.new();

~receiveFFT = OSCFunc.new({|msg, time, addr, recvPort|

	var val = msg[1 ..(msg.size-1)] ;
	var nSensors = ~correlations.nSensors ?? 3;
	~fftNetwork.data = val.clump(17).clump(12).clump(nSensors);




},"/xsens-fft", recvPort:50003); // path matching


~receiveFFTStats = OSCFunc.new({|msg, time, addr, recvPort|

	var val = msg[1 ..(msg.size-1)] ;
	var nSensors = ~correlations.nSensors ?? 3;
	~fftNetwork.stats = val.clump(2).clump(12).clump(nSensors);
	~fftNetwork.updateBus();




},"/xsens-fft-stats", recvPort:50003); // path matching



)







~correlations.correlationSelf.flat.size
~correlations.getBusOthers




~fftNetwork.getBus
~fftNetwork.getFFTStatsDancerAllSensors(0).flat.size































// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//PLOT XSENS FFT - Only used if fft calculated locally, which is not the case anymore

(



~fftWin = Window("fft",Rect(128, 64, 512, 512)).front;
~fftWin.view.background_(Color.white);


~fftWin.drawFunc = {
	 //Pen.translate(256,256);
	Pen.moveTo(0@0);

	//Pen.color = Color.new255(50,50,50);

	//Pen.addRect(Rect(0,0,512,512));


	//Pen.perform(\fill);
	Pen.color = Color.new255(40,50,240);
	Pen.fillColor =Color.new255(40,50,240);


	~xsensValues.at(0).fftAngles[0].doAdjacentPairs({
		|a,b,i|
		Pen.line( [i*16,a+256].asPoint, [(i+1*16),b+256].asPoint );

		    Pen.stroke

		//Pen.perform(\fill);


	});

};

	{ while { ~fftWin.isClosed.not } { ~fftWin.refresh; 0.04.wait; } }.fork(AppClock);

)



b=a??9
b=nil
~fftNetwork[0].size
