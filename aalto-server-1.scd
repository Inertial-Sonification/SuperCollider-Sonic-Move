

({

	[0.00*SinOsc.ar(100),0.00*SinOsc.ar(100),0.01*SinOsc.ar(100),0.01*SinOsc.ar(100),0.00*SinOsc.ar(100),0.0*SinOsc.ar(100),0.0*SinOsc.ar(100),0.00*SinOsc.ar(100),

	]

}.play)

Server.default.options.devices

(
s.options.numWireBufs=512*512;
s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
s.options.memSize = 4096 * 256; // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numAudioBusChannels = 1024 * 1024;
s.options.numControlBusChannels = 16384 * 32;


//ServerOptions.devices; //all devices
//ServerOptions.inDevices; //input devices~importMD
//ServerOptions.outDevices;
Server.default.options.hardwareBufferSize=128;
Server.default.options.sampleRate=44100;

Server.default.options.device="ASIO : MOTU Pro Audio";
Server.default.options.numInputBusChannels_(32);
Server.default.options.numOutputBusChannels_(32);
//Server.default.options;

s.waitForBoot({
	~pGroup = ParGroup.new;

	~outputBus = Bus.audio(s, 12);
});
)




[ MME : Microsoft Sound Mapper - Input, MME : MOTU ADAT Optical B 7-8 (MOTU A, MME : MOTU Analog 7-8 (MOTU Audio Wav, MME : MOTU ADAT Optical A 3-4 (MOTU A, MME : MOTU ADAT Optical A 1-2 (MOTU A, MME : MOTU ADAT Optical A 7-8 (MOTU A, MME : MOTU ADAT Optical A 5-6 (MOTU A, MME : Microphone Array (Realtek(R) Au, MME : MOTU ADAT Optical B 3-4 (MOTU A, MME : MOTU Analog 1-2 (MOTU Audio Wav, MME : MOTU Mic/Instrument 1-2 (MOTU A, MME : MOTU Reverb 1-2 (MOTU Audio Wav, MME : MOTU Analog 5-6 (MOTU Audio Wav, MME ...etc...




	ServerOptions.devices.postcs

[ "MME : Microsoft Sound Mapper - Input", "MME : In 1-2 (MOTU Pro Audio)", "MME : In 1-24 (MOTU Pro Audio)", "MME : Microphone Array (Intel® Smart ", "MME : Microsoft Sound Mapper - Output", "MME : Speakers (MOTU Pro Audio)", "MME : Speakers (Realtek(R) Audio)", "MME : Out 1-24 (MOTU Pro Audio)", "Windows DirectSound : Primary Sound Capture Driver", "Windows DirectSound : In 1-2 (MOTU Pro Audio)", "Windows DirectSound : In 1-24 (MOTU Pro Audio)", "Windows DirectSound : Microphone Array (Intel® Smart Sound Technology for Digital Microphones)", "Windows DirectSound : Primary Sound Driver", "Windows DirectSound : Speakers (MOTU Pro Audio)", "Windows DirectSound : Speakers (Realtek(R) Audio)", "Windows DirectSound : Out 1-24 (MOTU Pro Audio)", "ASIO : MOTU Pro Audio", "Windows WASAPI : Speakers (Realtek(R) Audio)", "Windows WASAPI : Out 1-24 (MOTU Pro Audio)", "Windows WASAPI : Speakers (MOTU Pro Audio)", "Windows WASAPI : In 1-24 (MOTU Pro Audio)", "Windows WASAPI : In 1-2 (MOTU Pro Audio)", "Windows WASAPI : Microphone Array (Intel® Smart Sound Technology for Digital Microphones)", "Windows WDM-KS : Microphone (Realtek HD Audio Mic input)", "Windows WDM-KS : Stereo Mix (Realtek HD Audio Stereo input)", "Windows WDM-KS : Headphones 1 (Realtek HD Audio 2nd output with SST)", "Windows WDM-KS : Headphones 2 (Realtek HD Audio 2nd output with SST)", "Windows WDM-KS : PC Speaker (Realtek HD Audio 2nd output with SST)", "Windows WDM-KS : Speakers 1 (Realtek HD Audio output with SST)", "Windows WDM-KS : Speakers 2 (Realtek HD Audio output with SST)", "Windows WDM-KS : PC Speaker (Realtek HD Audio output with SST)", "Windows WDM-KS : Microphone Array 1 ()", "Windows WDM-KS : Microphone Array 2 ()", "Windows WDM-KS : In 1-24 (In 1-24)", "Windows WDM-KS : In 1-2 (In 1-2)", "Windows WDM-KS : Out 1-24 (Out 1-24)", "Windows WDM-KS : Out 1-2 (Out 1-2)" ]




	[ "MME : Microsoft Sound Mapper - Input", "MME : MOTU ADAT Optical B 7-8 (MOTU A", "MME : MOTU Analog 7-8 (MOTU Audio Wav", "MME : MOTU ADAT Optical A 3-4 (MOTU A", "MME : MOTU ADAT Optical A 1-2 (MOTU A", "MME : MOTU ADAT Optical A 7-8 (MOTU A", "MME : MOTU ADAT Optical A 5-6 (MOTU A", "MME : Microphone Array (Realtek(R) Au", "MME : MOTU ADAT Optical B 3-4 (MOTU A", "MME : MOTU Analog 1-2 (MOTU Audio Wav", "MME : MOTU Mic/Instrument 1-2 (MOTU A", "MME : MOTU Reverb 1-2 (MOTU Audio Wav", "MME : MOTU Analog 5-6 (MOTU Audio Wav", "MME : MOTU Return 1-2 (MOTU Audio Wav", "MME : MOTU ADAT Optical B 5-6 (MOTU A", "MME : Line (NewTek NDI Audio)", "MME : MOTU Analog 3-4 (MOTU Audio Wav", "MME : MOTU ADAT Optical B 1-2 (MOTU A", "MME : MOTU S/PDIF 1-2 (MOTU Audio Wav", "MME : Microsoft Sound Mapper - Output", "MME : Digital Output (MOTU Audio Wave", "MME : MOTU Phones 1-2 (MOTU Audio Wav", "MME : MOTU ADAT Optical A 7-8 (MOTU A", "MME : MOTU ADAT Optical B 1-2 (MOTU A", "MME : MOTU ADAT Optical A 1-2 (MOTU A", "MME : MOTU Analog 3-4 (MOTU Audio Wav", "MME : MOTU Analog 1-2 (MOTU Audio Wav", "MME : MOTU Main Out 1-2 (MOTU Audio W", "MME : MOTU ADAT Optical B 3-4 (MOTU A", "MME : Digital Output (MOTU Audio Wave", "MME : MOTU ADAT Optical A 3-4 (MOTU A", "MME : MOTU ADAT Optical A 5-6 (MOTU A", "MME : MOTU Analog 5-6 (MOTU Audio Wav", "MME : MOTU S/PDIF 1-2 (MOTU Audio Wav", "MME : Speakers (Realtek(R) Audio)", "MME : MOTU Analog 7-8 (MOTU Audio Wav", "Windows DirectSound : Primary Sound Capture Driver", "Windows DirectSound : MOTU ADAT Optical B 7-8 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Analog 7-8 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical A 3-4 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical A 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical A 7-8 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical A 5-6 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : Microphone Array (Realtek(R) Audio)", "Windows DirectSound : MOTU ADAT Optical B 3-4 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Analog 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Mic/Instrument 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Reverb 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Analog 5-6 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Return 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical B 5-6 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : Line (NewTek NDI Audio)", "Windows DirectSound : MOTU Analog 3-4 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical B 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU S/PDIF 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : Primary Sound Driver", "Windows DirectSound : Digital Output (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Phones 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical A 7-8 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical B 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical A 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Analog 3-4 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Analog 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Main Out 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical B 3-4 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : Digital Output (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical A 3-4 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU ADAT Optical A 5-6 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU Analog 5-6 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : MOTU S/PDIF 1-2 (MOTU Audio Wave for 64 bit)", "Windows DirectSound : Speakers (Realtek(R) Audio)", "Windows DirectSound : MOTU Analog 7-8 (MOTU Audio Wave for 64 bit)", "ASIO : MOTU Audio ASIO", "ASIO : Realtek ASIO", "Windows WASAPI : MOTU Phones 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical A 7-8 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical B 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical A 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Analog 3-4 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Analog 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Main Out 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : Digital Output (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical B 3-4 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : Digital Output (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical A 3-4 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical A 5-6 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Analog 5-6 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU S/PDIF 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : Speakers (Realtek(R) Audio)", "Windows WASAPI : MOTU Analog 7-8 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Analog 7-8 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical A 3-4 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical A 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical A 7-8 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical A 5-6 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : Microphone Array (Realtek(R) Audio)", "Windows WASAPI : MOTU ADAT Optical B 3-4 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Analog 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Mic/Instrument 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Reverb 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Analog 5-6 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU Return 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical B 5-6 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : Line (NewTek NDI Audio)", "Windows WASAPI : MOTU Analog 3-4 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical B 1-2 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU ADAT Optical B 7-8 (MOTU Audio Wave for 64 bit)", "Windows WASAPI : MOTU S/PDIF 1-2 (MOTU Audio Wave for 64 bit)", "Windows WDM-KS : MOTU Analog 5-6 (MOTU Analog 5-6)", "Windows WDM-KS : Digital Out (MOTU ADAT Optical B 5-6)", "Windows WDM-KS : MOTU ADAT Optical A 3-4 (MOTU ADAT Optical A 3-4)", "Windows WDM-KS : MOTU Analog 7-8 (MOTU Analog 7-8)", "Windows WDM-KS : MOTU ADAT Optical A 3-4 (MOTU ADAT Optical A 3-4)", "Windows WDM-KS : MOTU ADAT Optical B 1-2 (MOTU ADAT Optical B 1-2)", "Windows WDM-KS : MOTU Analog 1-2 (MOTU Analog 1-2)", "Windows WDM-KS : MOTU ADAT Optical B 3-4 (MOTU ADAT Optical B 3-4)", "Windows WDM-KS : MOTU S/PDIF 1-2 (MOTU S/PDIF 1-2)", "Windows WDM-KS : MOTU ADAT Optical A 5-6 (MOTU ADAT Optical A 5-6)", "Windows WDM-KS : MOTU Analog 7-8 (MOTU Analog 7-8)", "Windows WDM-KS : MOTU Analog 1-2 (MOTU Analog 1-2)", "Windows WDM-KS : MOTU Phones 1-2 (MOTU Phones 1-2)", "Windows WDM-KS : MOTU Mic/Instrument 1-2 (MOTU Mic/Instrument 1-2)", "Windows WDM-KS : MOTU ADAT Optical A 7-8 (MOTU ADAT Optical A 7-8)", "Windows WDM-KS : MOTU ADAT Optical A 1-2 (MOTU ADAT Optical A 1-2)", "Windows WDM-KS : MOTU Analog 5-6 (MOTU Analog 5-6)", "Windows WDM-KS : MOTU ADAT Optical A 1-2 (MOTU ADAT Optical A 1-2)", "Windows WDM-KS : MOTU ADAT Optical B 7-8 (MOTU ADAT Optical B 7-8)", "Windows WDM-KS : Digital Out (MOTU ADAT Optical B 7-8)", "Windows WDM-KS : MOTU ADAT Optical B 1-2 (MOTU ADAT Optical B 1-2)", "Windows WDM-KS : MOTU Return 1-2 (MOTU Return 1-2)", "Windows WDM-KS : MOTU ADAT Optical B 3-4 (MOTU ADAT Optical B 3-4)", "Windows WDM-KS : MOTU Analog 3-4 (MOTU Analog 3-4)", "Windows WDM-KS : MOTU ADAT Optical A 7-8 (MOTU ADAT Optical A 7-8)", "Windows WDM-KS : MOTU S/PDIF 1-2 (MOTU S/PDIF 1-2)", "Windows WDM-KS : MOTU ADAT Optical A 5-6 (MOTU ADAT Optical A 5-6)", "Windows WDM-KS : MOTU Analog 3-4 (MOTU Analog 3-4)", "Windows WDM-KS : MOTU Main Out 1-2 (MOTU Main Out 1-2)", "Windows WDM-KS : MOTU ADAT Optical B 5-6 (MOTU ADAT Optical B 5-6)", "Windows WDM-KS : MOTU Reverb 1-2 (MOTU Reverb 1-2)", "Windows WDM-KS : Stereo Mix (Realtek HD Audio Stereo input)", "Windows WDM-KS : Microphone (Realtek HD Audio Mic input)", "Windows WDM-KS : Headphones (Realtek HD Audio 2nd output)", "Windows WDM-KS : Speakers 1 (Realtek HD Audio output with SST)", "Windows WDM-KS : Speakers 2 (Realtek HD Audio output with SST)", "Windows WDM-KS : PC Speaker (Realtek HD Audio output with SST)", "Windows WDM-KS : Microphone Array 1 (Realtek HD Audio Mic input with SST)", "Windows WDM-KS : Microphone Array 2 (Realtek HD Audio Mic input with SST)", "Windows WDM-KS : Microphone Array 3 (Realtek HD Audio Mic input with SST)", "Windows WDM-KS : Line (Aud #1)" ]








	{SinOsc.ar}.play