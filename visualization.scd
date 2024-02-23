(
~window  = ~correlations.nDancers.collect({|nDancer|Window("Xsens dancer-"++(nDancer+1),Rect(0, 0, 500, 500),scroll:true).front;});

~correlations.nDancers.do({
		|nDancer|

var textsVals = {StaticText(~window[nDancer], Rect(0 , 0 , 200, 20))}!(~correlations.nSensors * 4);

var textsCorrs = {StaticText(~window[nDancer], Rect(0 , 0 , 200, 20))}!(~correlations.getCombosSelf().size * 4);

//var textsCorrsOthers = {StaticText(~window[nDancer], Rect(0 , 0 , 200, 20))}!(~correlations.getCombosOthers().size * 4);


var textsFFTs = {StaticText(~window[nDancer], Rect(0 , 0 , 200, 20))}!(~correlations.nSensors * 3);


~window[nDancer].view.background_(Color.white);
~window[nDancer].view.decorator = FlowLayout(~window[nDancer].view.bounds);




//dictionary of text elements



~window[nDancer].drawFunc = {
	var start;
    Pen.moveTo(0@0);

	Pen.color = Color.new255(100,100,100);

	Pen.addRect(Rect(0,0,5000,5000));
	Pen.perform(\fill);

// ///////////////////////////////////////////////////////////////////////
	//Draw direct data
	//total of 6 labels

	~xsensValues.keys.do({|key, i|

	//var nDancer = (key.split($|)[0].split($-)[1]).asInteger;
	var nSensor = (key.split($|)[1].split($-)[1]).asInteger;

	var val =~xsensValues.at(key);
	var angles = val.euler;
	var speeds = val.angularVelocity;
	var acceleration = val.acceleration;
	var radius = 40;
	var quaternion = val.quaternion;

			//if((~xsensValues.at("dancer-1|sensor-1").quadrant )>0,{  ["still", "sudden linear", "linear motion","sudden heavy linear","rotation","rotation with impulse","rotation and smooth acceleration","rotation and hard acceleration"][~xsensValues.at("dancer-1|sensor-1").quadrant.asInteger].postln});

	start = Point(100,10);

	angles.do({
	|angle,j|
			var angleOffsetCircle = (j%2)*pi/2;
			var angleEndCircle    = ((j%2)*(pi)) + ( ((j+1)%2)*2pi );
		Pen.use{
				var center = start + Point((radius*3*j /*+ (radius*3*3 *(nDancer-1) )*/) , (radius*3*nSensor));
				//var text;

				Pen.moveTo(0@0);

		//~window[nDancer]Text[0].string=4.rand.asString;

				Pen.color = Color.new255(200,255,0,128);


				Pen.addArc( center , radius , angleOffsetCircle, angleEndCircle);
				Pen.perform(\stroke);



				Pen.addAnnularWedge(center, radius/2, ((radius*0.75)+ (radius * abs(acceleration[j]) *3.0)).clip( -2.0 * radius,2* radius), angle/*(( (((j%2)-0.5 )*2)* (((j+1)%2).clip(0.5,1.0)) *angle)+1)*pi*/, ((2pi/36) +(speeds[j]/4.0)).clip( -2pi/2,2pi/2));

				Pen.perform(\fill);

				//add quaternion visuzlization after last angle

				if(j==2,
						{
							var center = start + Point((radius*3*(j+1) /*+ (radius*3*3 *(nDancer-1) )*/) , (radius*3*nSensor));

							Pen.addArc( center , radius , 0, 2pi);
							Pen.perform(\stroke);

							Pen.addArc(center + Point(quaternion[1]*50,quaternion[2]*50 ), 5.0*(quaternion[3]+2.0),0,2pi );

							Pen.color = Color.new255(190,120, (50 + ((quaternion[0]+1.0)*100)).clip(0.0,255.0) ,210);

							Pen.perform(\fill);
							textsVals[ /*((nDancer-1)*6) + */ ((nSensor-1)*3) + 3].bounds = Rect(center.x- radius , center.y - (radius*1.5) , 200, 20);
							textsVals[/*((nDancer-1)*6) + */  ((nSensor-1)*3) + 3].string = ("sensor-"++nSensor++"|"++"quaternion");
				textsVals[/*((nDancer-1)*6) + */  ((nSensor-1)*3) + 3].align = \left;
						}

					);





				textsVals[ /*((nDancer-1)*6) + */ ((nSensor-1)*3) + j].bounds = Rect(center.x- radius , center.y - (radius*1.5) , 200, 20);
				textsVals[/*((nDancer-1)*6) + */  ((nSensor-1)*3) + j].string = ("sensor-"++nSensor++"|"++["roll","pitch","yaw"][j]);
				textsVals[/*((nDancer-1)*6) + */  ((nSensor-1)*3) + j].align = \left;
	}
		});
	});
// ///////////////////////////////////////////////////////////////////////
//draw correlations SELF
		Pen.moveTo(0@0);


		~correlations.getCombosSelf.do({
		|combo, i|

		var rectDim = Point(40,40);
		start=Point(100,100);

		start = start.translate(Point(40*2*6,50));
			//combo is all data for current combination //4*3 values //ORI ACC GYR MAG
			~correlations.getDataSelf(nDancer,combo).do({
				|data, j|
				//data is 3 values each

				data.do({
					|type, ii|
				//single correlation level
					//type = ( -1)*sign(type)* log10( (abs(type)*1e2)+1 )/2.0;
					//type = ( -1)*sign(type)* ( ((abs(type)).exp)-1.0 )/1.71828;
					type = ( -1)*sign(type)* ( abs(type).clip(0.0,1.0).lincurve(0.0,1.0,0.0,1.0,1.8) );

					//if((i==0) && (j==0) && (ii==0),{type.postln} );

					Pen.use{
						var startPoint = start;
						startPoint=startPoint.translate(Point( /*(rectDim.x * 12 * i) +*/ (j*3*rectDim.x) + (ii * 40) ,i * 120));
						Pen.color = Color.new255(50+(100*i),50+( j*50 ),50+( ii*50 ),128);

						//Pen.moveTo(start);
						//Pen.translate( (rectDim.x * 12 * i) + (j*3*rectDim.x) + (ii * 40) ,0);


						Pen.addRect(Rect(startPoint.x,startPoint.y,rectDim.x, type*rectDim.y) );

						Pen.perform(\fill);


						textsCorrs[ /*((nDancer-1)*6) + */ (i * 4 )+ j].bounds = Rect(startPoint.x - 82, startPoint.y - 140  , 200, 200);
						textsCorrs[/*((nDancer-1)*6) + */  (i * 4 )+ j].string = ("correlation-"++combo++"\n"++["orientation","acceleration","gyroscope","compass"][j] ++"\n\n\n"++"|");
						textsCorrs[/*((nDancer-1)*6) + */  (i * 4 )+ j].align = \left;


					};

				})



			});



		});


// ///////////////////////////////////////////////////////////////////////
//draw correlations OTHERS

	Pen.moveTo(0@0);
	~correlations.nSensors.do({
		|nSensor|

		var rectDim = Point(40,40);
		start=Point(100,100);
		start = start.translate(Point(40*2*6,(~correlations.getCombosSelf.size*100) + 50));
		~correlations.getCombosOthers.do({
		|combo, i|
			//combo is all data for current combination //4*3 values //ORI ACC GYR MAG
			~correlations.getDataOthers(nSensor,combo).do({
				|data, j|
				//data is 3 values each

				data.do({
					|type, ii|
				//single correlation level
					type =( -1)*sign(type)* log10(abs(type)*1e5)/5.0;

					//if((i==0) && (j==0) && (ii==0),{type.postln} );

					Pen.use{
						var startPoint = start;
						startPoint=startPoint.translate(Point( /*(rectDim.x * 12 * i) +*/ (j*3*rectDim.x) + (ii * 40) ,i * 100));
						Pen.color = Color.new255(50+(100*i),50+( j*50 ),50+( ii*50 ),128);

						//Pen.moveTo(start);
						//Pen.translate( (rectDim.x * 12 * i) + (j*3*rectDim.x) + (ii * 40) ,0);


						Pen.addRect(Rect(startPoint.x,startPoint.y,rectDim.x, type*rectDim.y) );

						Pen.perform(\fill);



					};

				})



			});



		});
	});


// ///////////////////////////////////////////////////////////////////////
//draw FFTS
	Pen.moveTo(0@0);



		start = Point(10,10+(~correlations.nSensors * ~correlations.nDancers * 200));


		~fftNetwork.getFFTDancerAllSensors(nDancer).do({
		|sensorData, nSensor|
			var rescale=[1,2,0.07,1];//1,2,0.07,1

			sensorData.do({
			|dataType, nDatum|
				var startN = start + Point( (nDancer * 400)+(300*(nDatum%3)) , (nSensor*10*12));

				Pen.color = Color.new255( (50 + (nSensor *50)).clip(0,255)*0.4,(50+(nDatum* 10)).clip(0,255),(25+(nDatum* 10)).clip(0,255),255);

				dataType.doAdjacentPairs({
					|a,b,i|
					//Pen.addRect(Rect(start.x,start.y,100,100));
					//(nDatum/3).asInteger.postln;
					Pen.line( [i*16, (i.clip(0,1))*(a*( -10.0)*(rescale[(nDatum/3).asInteger])).clip(-100,100)].asPoint +startN, [(i+1*16),(b*( -10.0*(rescale[(nDatum/3).asInteger]))).clip(-100,100)].asPoint +startN);
					Pen.stroke;



				textsFFTs[  (nSensor*3) + (nDatum%3).asInteger].bounds = Rect(startN.x , startN.y , 200, 20);
				textsFFTs[  (nSensor*3) + (nDatum%3).asInteger].string = ("sensor-"++(nSensor+1)++" FFT|"++["x","y","z"][(nDatum%3).asInteger]);
				textsFFTs[  (nSensor*3) + (nDatum%3).asInteger].align = \left;
				});



				Pen.color = Color.new255( ((50 + (nSensor *50)).clip(0,255)*0.4),(50+(nDatum* 10)).clip(0,255),(25+(nDatum* 10)).clip(0,255),255);

				Pen.line(  startN + [272.0 * ~fftNetwork.getFFTStatsSensor(nSensor, nSensor)[nDatum][1], 10 ].asPoint, startN + [272.0 * ~fftNetwork.getFFTStatsSensor(nSensor, nSensor)[nDatum][1], -80 ].asPoint )  ;

				Pen.stroke;






			});

		});






};

	{ while { ~window[nDancer].isClosed.not } { ~window[nDancer].refresh; 0.04.wait; } }.fork(AppClock);





})


)





~fftNetwork.getFFTStatsSensor(0,0)


~window[0].states




















// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//log10(1e5)

~xsensValues.at("dancer-1|sensor-1").scaleQuadrant_([5.0,10.0,10.0])
~xsensValues.at("dancer-1|sensor-1").acceleration
~fftNetwork.getFFTDancerAllSensors(1)[0].size



MethodOverride.printAll

