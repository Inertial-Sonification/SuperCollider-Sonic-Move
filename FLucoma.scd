~sample.do(_.free);
(
~samples=
([
"C:/Users/korugaa1/Downloads/0377_ice_crackling_23-02-16.ogg",
"C:/Users/korugaa1/Downloads/dronelog24022013lankawirain02.ogg",
"C:/Users/korugaa1/Downloads/PaliMeursault-SurPlaceEybens.mp3",
]

	++
(([
"C:/Users/korugaa1/Downloads/269366__lwdickens__brook-winter-ice-forest-water-under-ice_2.wav", //no
"C:/Users/korugaa1/Downloads/650544__klankbeeld__walk-in-water-220903_0523.wav",//!!!!
"C:/Users/korugaa1/Downloads/234076__thalamus_lab__metal-drone-old-fire-extinguisher.wav",//!!!!!
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
"C:/Users/korugaa1/Downloads/394556__emmithi123__reese-bass.wav",//18 !!!!!!
"C:/Users/korugaa1/Downloads/85096__blackie666__reese-2.wav",//19
"C:/Users/korugaa1/Downloads/236933__magnesium1__mag-reese-bass-1.aiff",//20
"C:/Users/korugaa1/Downloads/719838__autumncheney__reese_00_c.wav"//21  !!!!!!





	])).flatten(0)
);
~sample = ~samples.collect({ |item|  Buffer.readChannel(s,item.standardizePath,channels:[0])   });

~sample.do(_.normalize);
)





(
~destination.free;
    ~destination = Buffer(s);

{
//samples should already be loaded
	var nSamps=0;
 ~sample.do({|sample|

		sample.numFrames.postln;
		nSamps.postln;
		FluidBufCompose.processBlocking(s,sample,startFrame:nSamps,destination:~destination,destGain:1,gain:-6.dbamp);
	nSamps=nSamps+(sample.numFrames);



});
	//~destination.normalize;
	"done".postln;
	s.sync;
}.fork;


)










(
var indices = Buffer(s);
var mfccs = Buffer(s);
var stats = Buffer(s);
var flat = Buffer(s);
var playback_info_dict = Dictionary.newFrom([
    "cols",2,
    "data",Dictionary.new;
]);

~ds_mfccs.free;
~ds_playback.free;


~ds_mfccs = FluidDataSet(s);
//FluidBufNoveltySlice.processBlocking(s,~destination,algorithm:1,indices:indices);
FluidBufOnsetSlice.processBlocking(s,~destination,indices:indices,metric:9,threshold:0.17);
indices.loadToFloatArray(action:{
    arg fa;

    // go through each slice (from one slice point to the next)
    fa.doAdjacentPairs{
        arg start, end, i;
        var num = end - start;
        var id = "slice-%".format(i);

        // add playback info for this slice to this dict
        playback_info_dict["data"][id] = [start,num];

		//FluidBufSpectralShape.processBlocking(s,~destination, start, num,features:mfccs, select:[\skewness, \kurtosis, \flatness, \crest]);

        FluidBufMFCC.processBlocking(s,~destination,start,num,startCoeff:1,features:mfccs);

        FluidBufStats.processBlocking(s,mfccs,stats:stats,select:[\mean]);

        FluidBufFlatten.processBlocking(s,stats,destination:flat);

        // add analysis info for this slice to this data set
        ~ds_mfccs.addPoint(id,flat);
    };

    ~ds_playback = FluidDataSet(s).load(playback_info_dict);
	//~normalizer = FluidNormalize(s).fitTransform(~ds_mfccs,~ds_mfccs);

	~ds_mfccs.print;
    ~ds_playback.print;
	indices.free;
	mfccs.free;
	stats.free;
	flat.free;
});



)

//~reduced = FluidDataSet(s);

//FluidUMAP(s,4,numNeighbours:15,minDist:0.1).fitTransform(~ds_mfccs,~reduced);
//FluidNormalize(s).fitTransform(~reduced,~reduced);// normalize so it's easier to plot

//~reduced.print


~tree.free

~normalizer = FluidNormalize(s, -1, 1);

					~normalizer.fitTransform(~ds_mfccs,~ds_mfccs);// normalize the mfccs

// we'll use this kdtree to find the nearest neighbour in 13 dimensions (mfccs)
~tree = FluidKDTree(s);

//~tree.numNeighbours = 20;
//~tree.radius_(10.0);

~tree.fit(~ds_mfccs);


~ds_mfccs.dump
~tree.dump

~normalizer.dump({|data| ~minMfcc = data.at("data_min"); ~maxMfcc =  data.at("data_max"); })
1.class
(
a={
	var dd=LocalBuf.newFrom([ 73.180717468262, -35.351573944092, 25.153793334961, -37.49437713623, 24.155529022217, -30.948156356812, 18.715627670288, -24.477586746216, 17.063903808594, -12.34766960144, 9.5469837188721, -14.171420097351, 6.5343041419983 ]);
	var dd1=LocalBuf.newFrom([ 73.180717468262, -35.351573944092, 25.153793334961, -37.49437713623, 24.155529022217, -30.948156356812, 18.715627670288, -24.477586746216, 17.063903808594, -12.34766960144, 9.5469837188721, -14.171420097351, 6.5343041419983 ]);
	~normalizer.kr(1,dd, dd1 ,-1,1) ;
	FluidBufToKr.kr(dd1).poll;

0

}.play;
)
a.free


(
SynthDef(\mfccTest,{

	var trig = LFPulse.kr(10); // could change how often the lookup happens...
	//var trigStart = ((PulseCount.kr(Trig.kr(trig)) > 2)*(PulseCount.kr(Trig.kr(trig)) < 4));


	var nDancers = ~correlations.nDancers;
		var nSensors = ~correlations.nSensors;

		//var busses = ~xsensValues.values.asArray[ ~xsensValues.keys.asArray.collect({|key|key.postln;(key.split($|)[1].split($-)[1]).asInteger}).order.postln ].postln.collect({|item| (item).getValueBus });

		var busses = nDancers.collect({|i| nSensors.collect({|j|    ~xsensValues.at("dancer-"++(i+1)++"|sensor-"++(j+1)).getValueBus                          }) }).flat;

	var measures = busses.collect({|bus| In.kr( bus, bus.numChannels).clumps([3,3,3,3,4,1])}); //size [[[3] , 4], 3]

var energy = //3-vector, one entry for each sensor

			//for calculating amplification and energy, use total acceleration (it's linear) and total radial velocity (radial)
			measures.collect({//iterate over sensors
				|item,i|
				//get acc and radial V
				item = item.asAudioRateInput;
			(Integrator.ar( item[2].collect({|item|item*item}).reduce('+').sqrt,0.997).clip(0.3,inf)-0.3)+ //acceleration
			(item[3].collect({|item|item*item}).reduce('+')) //keep v*v for kinetic energy so no sqrt

			});



	var mfccMeasure =  {{LocalBuf(3,13)}!nSensors}! nDancers  ;
	var buf = nDancers.collect({|i| nSensors.collect({|j|  ~xsensValues.at("dancer-"++(i+1)++"|sensor-"++(j+1)).getBuf })});
	var mfccss =  (nDancers.collect({|i| nSensors.collect({|j|      FluidBufMFCC.kr(buf[i][j],startCoeff:1,features:mfccMeasure[i][j],trig:trig)             })  }));
	var out=0;

	var mfccbuf1 =  (mfccMeasure[0][0]);	//((mfccss[0][0]).flat.clump(13))[0];
	var mfccbuf2 =  (mfccMeasure[0][0]);  //((mfccss[0][0]).flat.clump(13))[1]; //mfccs21.linlin(RunningMin.kr( mfccs21),RunningMax.kr( mfccs21),0.0,1.0);
	var mfccbuf3 =  (mfccMeasure[0][0]);  //((mfccss[0][0]).flat.clump(13))[2];//mfccs31.linlin(RunningMin.kr( mfccs31),RunningMax.kr( mfccs31),0.0,1.0);


    var mfccbuf11 = LocalBuf(13);
    var mfccbuf22 = LocalBuf(13);
    var mfccbuf33 = LocalBuf(13);

    var playbackinfo1 = LocalBuf(2);
	var playbackinfo2 = LocalBuf(2);
	var playbackinfo3 = LocalBuf(2);

    var start1, num1, start11, num11, start12, num12, sig_looked_up1;
    var start2, num2, start21, num21, start22, num22, sig_looked_up2;
    var start3, num3, start31, num31, start32, num32, sig_looked_up3;
	//var out;
	//var idx =(Phasor.ar(0, BufRateScale.kr(~destination), 0, BufFrames.kr(~destination)));///BufFrames.kr(~destination));

var t1,t2,t3;
	var pc = PulseCount.kr(trig);

	t1 = ((BufRd.kr( 13, mfccbuf1,0)+BufRd.kr( 13, mfccbuf1,1)+BufRd.kr( 13, mfccbuf1,2))/3);
	t2 = ((BufRd.kr( 13, mfccbuf2,0)+BufRd.kr( 13, mfccbuf2,1)+BufRd.kr( 13, mfccbuf2,2))/3);
	t3 = ((BufRd.kr( 13, mfccbuf3,0)+BufRd.kr( 13, mfccbuf3,1)+BufRd.kr( 13, mfccbuf3,2))/3);
	FluidKrToBuf.kr( t1.linlin(Sanitize.kr(RunningMin.kr(t1,(pc==10).asInteger)),Sanitize.kr(RunningMax.kr(t1,(pc==10).asInteger).poll),-1.0,1.0,\nil) ,mfccbuf11);
	FluidKrToBuf.kr( t2.linlin(Sanitize.kr(RunningMin.kr(t2,(pc==10).asInteger)),Sanitize.kr(RunningMax.kr(t2,(pc==10).asInteger)),-1.0,1.0,\nil) ,mfccbuf22);
	FluidKrToBuf.kr( t3.linlin(Sanitize.kr(RunningMin.kr(t3,(pc==10).asInteger)),Sanitize.kr(RunningMax.kr(t3,(pc==10).asInteger)),-1.0,1.0,\nil) ,mfccbuf33);


	//~normalizer.kr(trig, mfccbuf11, mfccbuf11, -1, 1);
	//~normalizer.kr(trig, mfccbuf22, mfccbuf22, -1, 1);
	//~normalizer.kr(trig, mfccbuf33, mfccbuf33, -1, 1);

	//FluidBufToKr.kr(mfccbuf11).poll;

    // kdtree finding the nearest neighbour in 13 dimensions
    ~tree.kr(trig,mfccbuf11,playbackinfo1,1,lookupDataSet: ~ds_playback);
    ~tree.kr(trig,mfccbuf22,playbackinfo2,1,lookupDataSet: ~ds_playback);
    ~tree.kr(trig,mfccbuf33,playbackinfo3,1,lookupDataSet: ~ds_playback);

    # start1, num1 = FluidBufToKr.kr(playbackinfo1);
    # start2, num2 = FluidBufToKr.kr(playbackinfo2);
	# start3, num3 = FluidBufToKr.kr(playbackinfo3);

    //# start3, num3 = FluidBufToKr.kr(playbackinfo3);




	//trig = [Changed.ar(start1.asAudioRateInput),Changed.ar(start2.asAudioRateInput),Changed.ar(start3.asAudioRateInput)].poll;


	(start1/(~destination.numFrames)).poll(label:"start frame");
   // num1.poll(label:"num frames");
	//(start1/(~destination.numFrames)).poll(label:1);
	//(start2/(~destination.numFrames)).poll(label:2);
	//(start3/(~destination.numFrames)).poll(label:3);

    // not using num frames for playback here, but one certainly could!
	sig_looked_up1 = PlayBuf.ar(1,~destination,BufRateScale.ir(~destination),trig,start1);
	sig_looked_up2 = PlayBuf.ar(1,~destination,BufRateScale.ir(~destination),trig,start2);
	sig_looked_up3 = PlayBuf.ar(1,~destination,BufRateScale.ir(~destination),trig,start3);


		//(start1/(~destination.numFrames)).poll(label:1);
		//(start2/(~destination.numFrames)).poll(label:2);
		//(start3/(~destination.numFrames)).poll(label:3);



	out = 0; //((sig_looked_up1)
		//+(sig_looked_up2)+sig_looked_up3)* -32.dbamp;

	Out.ar(28,out*0.01);
}).add;
)
s.sync
~testMFCC=Synth.new(\mfccTest)
~testMFCC.free
s.freeDefaultGroups
~ds_playback.print


~testBuf.setn(0,[0.501496,0.408438,0.501519,0.991538])
~tree.kNearest(~testBuf,1,{|data|data.postln;})

~testBuf.free;




~xsensValues.at("dancer-"++(i+1)++"|sensor-"++(j+1))


~tb = Buffer.alloc(s,1,1)
~ds_playback.getPoint("slice-560",~tb)
~tb.getn(0,1,{|el|el.postln})




~testBuf[0].getn(0,1,{|d|d.postln;})



(
{
~correlations.nDancers.do({
	|i|
	~correlations.nSensors.do({
		|j|
		var finished = false;
		~testBuf[j].setn(0,   (~xsensValues.at("dancer-"++(i+1)++"|sensor-"++(j+1)).quaternion+1.0)/2.0 );

		~tree.kNearest(~testBuf[j],1,{|data|data.postln; ~ds_playback.getPoint( data.asString,~idBuf[j]); j.postln; finished = true    });

		while({finished==false},{0.1.wait});
		~idBuf[j].getn(0,1,{|data|data.postln});

	}) });
}.fork
)






~ds_playback.getPoint("slice-13", ~idBuf[0])

~idBuf.do({|item| item.getn(0,1,{|data|data.postln});})

(
~testBuf = {Buffer.alloc(s,4,1)}!~correlations.nSensors;
~idBuf =  {Buffer.alloc(s,1,1)}!~correlations.nSensors;
~routineSearch = {

	inf.do({


~correlations.nDancers.collect({|i| ~correlations.nSensors.collect({|j| ~testBuf[j].setn(0,   (~xsensValues.at("dancer-"++(i+1)++"|sensor-"++(j+1)).quaternion+1.0)/2.0 ); ~tree.kNearest(~testBuf[j],1,{|data| ~ds_playback.getPoint( data,~idBuf[j]);})}) });

		0.01.wait;
	})


}.fork;

)





a={0.1*SinOsc.ar(440).scope}.play
a.free

