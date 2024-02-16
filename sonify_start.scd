(

 SynthDef(\xsensNNFO,
	{|bus = 0/*28*/, amp = 0.1, variation = 1.5, freq = 50.0, spread = 0.04, modulation = 0.02, xFadeMod = 0.4, inputBus |
		var out;


		var busses = ~xsensValues.values[~xsensValues.keys.collect({|key|(key.split($|)[1].split($-)[1]).asInteger}).asArray-1].collect({|item| (item).getValueBus });
		var measures = busses.collect({|bus| In.kr( bus, bus.numChannels)});

		var fftData = In.kr(~fftNetwork.getBus,~fftNetwork.getBus.numChannels).clump(2).flop.collect({|item| Mix.kr(item)})/(~fftNetwork.getBus.numChannels/2);
		var corrData = Mix.kr(In.kr(~correlations.getBusSelf,~correlations.getBusSelf.numChannels))/(~correlations.getBusSelf.numChannels);

		//fftData.poll(label:\fft);
		//corrData.poll(label:\corr);



		amp=amp*100.0*( measures.collect({|it|(((it[6]*it[6])+(it[7]*it[7])+(it[8]*it[8])).sqrt) + (((it[9]*it[9])+(it[10]*it[10])+(it[11]*it[11])).sqrt)}).sum);

		amp=Lag.ar((amp.clip(0.06,4.0)-0.06).asAudioRateInput,ControlDur.ir*2.5);
		fftData = Lag.ar(fftData.asAudioRateInput,ControlDur.ir*2.5);
		corrData = Lag.ar(corrData.asAudioRateInput,ControlDur.ir*2.5);
		freq=freq.asAudioRateInput+((400.0*(1.0-(fftData[0]*5.0))));
		out = {amp*FBNeuron.ar(
			(freq*variation).asAudioRateInput,
			freq,
			(spread.asAudioRateInput* ((fftData[1]*10.0).asAudioRateInput)).clip(0,16),
			((modulation.asAudioRateInput*((1.0-(corrData*10.0)).asAudioRateInput))/freq).clip(0,1),
			xFadeMod.asAudioRateInput
		);}!2;
		OffsetOut.ar(bus ,Sanitize.ar( Sanitize.ar(out).tanh))
}).add;



)


a=Synth.new(\xsensNNFO)

a.free

~transport.stop
(
~transport ={
	var current=0;
	inf.do({
		var now =~correlations.getDataSetSelf.flat.collect({|item,idx|  ((item>0.95).asInteger*3)+((item.abs<0.1).asInteger)+((item< -0.95).asInteger*2)  }).clump(12).collect({|item,i|var hist =item.histo(4,0,3);hist[1..(hist.size-1)].sum.postln; hist[1..(hist.size-1)].maxIndex*(i+1)}).sum;

		if((current!=now)&&(now!=0),{

			current= now;
			current.postln;

		});

		0.005.sleep;
	});


}.fork;
)

//cloud swarm
a.setn(\bus, 28, \amp, 0.1, \variation , 0.5, \freq , 50.0, \spread ,3.0, \modulation,0.8 , \xFadeMod,0.5)



// chaotic/gendy
a.setn(\bus, 0, \amp, 0.1, \variation , 1.0, \freq , 500.0, \spread ,3.0, \modulation,0.8 , \xFadeMod,0.5)


// near disonant
a.setn(\bus, 28, \amp, 0.1, \variation , 1.0, \freq , 500.0, \spread ,3.0, \modulation,0.1 , \xFadeMod,0.5)


// near disonant
a.setn(\bus, 28, \amp, 0.1, \variation , 1.0, \freq , 300.0, \spread ,3.0, \modulation,0.1 , \xFadeMod,0.5)



// near small variation
a.setn(\bus, 28, \amp, 0.1, \variation , 0.1, \freq , 300.0, \spread ,3.0, \modulation,0.1 , \xFadeMod,0.5)



// xenakis
a.setn(\bus, 28, \amp, 0.1, \variation , 0.1, \freq , 300.0, \spread ,3.0, \modulation,0.3 , \xFadeMod,0.5)



// deep
a.setn(\bus, 28, \amp, 0.3, \variation , 0.1, \freq , 50.0, \spread ,3.0, \modulation,0.3 , \xFadeMod,0.005)



// metallic stutter
a.setn(\bus, 28, \amp, 0.3, \variation , 0.1, \freq , 50.0, \spread ,3.0, \modulation,0.001 , \xFadeMod,0.8)


// metallic hold
a.setn(\bus, 0, \amp, 0.3, \variation , 0.1, \freq , 50.0, \spread ,12.0, \modulation,0.0009 , \xFadeMod,0.98)



// metallic variation
a.setn(\bus, 28, \amp, 0.2, \variation , 1.1, \freq , 50.0, \spread ,12.0, \modulation,0.0009 , \xFadeMod,0.5)


// distorted horn
a.setn(\bus, 0, \amp, 0.2, \variation , 4.9, \freq , 50.0, \spread ,8.0, \modulation,0.09 , \xFadeMod,0.00899)



// noise
a.setn(\bus, 0, \amp, 0.1, \variation , 7.9, \freq , 500.0, \spread ,1.2, \modulation,0.9 , \xFadeMod,0.00899)


// noise2
a.setn(\bus, 28, \amp, 0.1, \variation , 7.9, \freq , 500.0, \spread ,1.2, \modulation,0.009 , \xFadeMod,0.00899)




// noise3-moments
a.setn(\bus, 28, \amp, 0.1, \variation , 7.9, \freq , 500.0, \spread ,1.2, \modulation,0.009 , \xFadeMod,0.899)



// noise4-moments
a.setn(\bus, 28, \amp, 0.1, \variation , 17.9, \freq , 500.0, \spread ,2.4, \modulation,0.1 , \xFadeMod,0.7)


// noise5-almost white
a.setn(\bus, 28, \amp, 0.1, \variation , 270.9, \freq , 500.0, \spread ,4.4, \modulation,0.9 , \xFadeMod,0.7)


// suspended
a.setn(\bus, 28, \amp, 0.1, \variation , 0.09, \freq , 1000.0, \spread ,1.2, \modulation,0.09 , \xFadeMod,0.7)




// suspended low
a.setn(\bus, 0, \amp, 0.2, \variation , 1.01, \freq , 60.0, \spread ,1.9, \modulation,0.009 , \xFadeMod,0.12)



//highpitch - add reverb
a.setn(\bus, 0, \amp, 0.04, \variation , 1.4, \freq , 6000.0, \spread ,1.1, \modulation,0.009 , \xFadeMod,0.12)



//radio
a.setn(\bus, 28, \amp, 0.04, \variation , 1.1, \freq , 10000.0, \spread ,5.0, \modulation,0.09 , \xFadeMod,0.32)


//broad noise
a.setn(\bus, 28, \amp, 0.04, \variation , 6.0, \freq , 10000.0, \spread ,5.0, \modulation,0.09 , \xFadeMod,0.32)




//highpitch - uncomfortable
a.setn(\bus, 0, \amp, 0.04, \variation , 1.9, \freq , 10000.0, \spread ,1.01, \modulation,0.02 , \xFadeMod,0.02)



//inside a star
a.setn(\bus, 0, \amp, 0.14, \variation , 1.9, \freq , 40.0, \spread ,1.01, \modulation,0.02 , \xFadeMod,0.02)



//slowly not pleasant
a.setn(\bus, 28, \amp, 0.04, \variation , 2.3, \freq , 400.0, \spread ,8.0, \modulation,0.1 , \xFadeMod,0.2)



//ghouls
a.setn(\bus, 0, \amp, 0.04, \variation , 10.3, \freq , 400.0, \spread ,1.7, \modulation,0.00003 , \xFadeMod,0.2)




//violins
a.setn(\bus, 0, \amp, 0.04, \variation , 1.3, \freq , 400.0, \spread ,1.7, \modulation,0.03 , \xFadeMod,0.7)


//violins2
a.setn(\bus, 0, \amp, 0.04, \variation , 1.3, \freq , 400.0, \spread ,2.7, \modulation,0.024 , \xFadeMod,0.8)









~xsensValues.values[~xsensValues.keys.collect({|key|(key.split($|)[1].split($-)[1]).asInteger.postln}).asArray-1].do({|item| (item).getValueBus })


values.do({|item|item.getValueBus().postln})































































































~paramDict = Dictionary.new()

[\bus , \amp , \variation , \freq , \spread , \modulation , \xFadeMod].do({
	|item,i|
	~paramDict.put(item,Bus.control(s, 1))
	//init defaults here


});



~mapSynthControls= {
	|synthToMap|

~paramDict.keys.do({|key,i|

		synthToMap.map(key,~paramDict.at(key))

})
}


~mapSynthControls.value(a)

[\bus , \amp , \variation , \freq , \spread , \modulation , \xFadeMod].do({
	|item,i|
	~paramDict.at(item).set([28,0.1,1.5,100.0,0.04,0.02,0.4][i])

})





[28,0.1,1.5,100.0,0.04,0.02,0.4].do({|item,i| m[i].set(item)} );


m.do({
	|item,i|
	a.map( [\bus , \amp , \variation , \freq , \spread , \modulation , \xFadeMod][i], item)

})






~paramDict.at(\modulation).set(0.9)

~paramDict.at(\freq).set(500)




a=Synth.new(\xsensNNFO)


m.do(_.free)






