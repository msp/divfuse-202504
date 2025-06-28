////////////////////////////////////////////////////////////////////////////////
// STARTUP
////////////////////////////////////////////////////////////////////////////////
(
var workingDir = "/data/development/supercollider/divfuse-202504/";
var synthDefsFile = "setup.scd";
var synthDefs;
var includePath;

// configure the audio outputs
~out1 = 0;
~out2 = 1;
~out3 = 2;
~out4 = 3;
~out5 = 4;
~out6 = 5;
~out7 = 6;
~out8 = 7;
~out9 = 8;
~out10 = 9;
~out11 = 10;
~out12 = 11;
~out13 = 12;
~out14 = 13;
~out15 = 14;
~out16 = 15;

~out1_2 = 0;
~out3_4 = 2;
~out5_6 = 4;

ServerOptions.devices.do({ |dev, i|
    [i, dev].postln;
});

"\nAbout to set audio device  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".postln;
s.options.device = "Fireface UCX (23733485)";  // must match a name from ServerOptions.devices
"\nDONE SET audio device  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".postln;


s.options.numOutputBusChannels = 8;     // or however many outputs you want
s.options.numInputBusChannels = 0;      // if you don't need inputs
s.options.recChannels = 8;

s.waitForBoot {
	"\nRunning MSP startup file >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".postln;

	includePath = PathName.new(thisProcess.nowExecutingPath.dirname+/+"include/");

	includePath.postln;
	includePath.entries.postln;

	// includePath.files.do{|aFile|
	// 	"\nloading >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".postln;
	// 	aFile.fullPath.postln;
	// 	load(aFile.fullPath);
	// };

	synthDefs = PathName.new(workingDir+/+synthDefsFile);
	"\nloading >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".postln;
	synthDefs.postln;

	load(synthDefs.fullPath);
}
)