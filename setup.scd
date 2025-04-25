////////////////////////////////////////////////////////////////////////////////
//
// SETUP
//
// Most things found and hacked from vairous sources online. Respect!
//
// We run the SETUP to define the audio system and load the PATTERNS.
//
// The CONTROL section allows us to start/stop each sequence.
// Multiple sequences can be played together for layering.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// (1) SETUP - ensure the path to sample folder is correct
////////////////////////////////////////////////////////////////////////////////

(
// place cursor below this line and execute CMD + enter to execute the section
var foo;

s.meter;
s.plotTree;
s.scope;

"===============================================".postln;
"SETUP =========================================".postln;
"===============================================".postln;
// Server.freeAll;
// Pdef.removeAll;
// Pbindef.removeAll;

Buffer.freeAll;

~oscClient = NetAddr.new("127.0.0.1", 1234);
~samples = Array.new;
~synths = Array.new;
// ~sampleDir = "/data/Dropbox-spatial/Dropbox/spatial/music/AudioSources/divfuse-202504/vowelsfemale*";
// ~sampleDir = "/data/Dropbox-spatial/Dropbox/spatial/music/AudioSources/divfuse-202504/halfmastv4*";
~sampleDir = "/Users/spatial/Documents/music-icld/music-2025/Samples/divfuse-2504/halfmastv5trim*";

"\n".postln;
"----------------------------------------------".postln;
"Loading Samples ------------------------------".postln;
"----------------------------------------------".postln;
"\n".postln;

PathName(~sampleDir).files.do { |file, i|
	("...found: " ++ file.fullPath).postln;
    if(file.extension == "wav") {
        var buf = Buffer.readChannel(s, file.fullPath, channels: [0]);  // mono
		Buffer.read(s, file.fullPath);
		// ~samples[file.fileNameWithoutExtension] = buf;
		~samples = ~samples.add(buf);
        ("......loaded: " ++ file.fileName).postln;
    }
};

"----------------------------------------------".postln;
("| Total loaded: " ++ ~samples.size).postln;
"----------------------------------------------".postln;

"\n".postln;
"----------------------------------------------".postln;
"Loading Engine  ------------------------------".postln;
"----------------------------------------------".postln;
"\n".postln;

~enginePath = PathName.new(thisProcess.nowExecutingPath.dirname+/+"engine/");
// ~enginePath.entries.postln;

~enginePath.files.do{|aFile|
    aFile.fullPath.postln;

	// 95 == '_"
	if(aFile.fileName[0].ascii != 95) {
		"(loading).......................................".postln;
		load(aFile.fullPath);
	} {
		"......................................(ignoring)".postln;
	};
};

"===============================================".postln;
"DONE SETUP ====================================".postln;
"===============================================".postln;
)