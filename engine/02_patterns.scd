////////////////////////////////////////////////////////////////////////////////
// (3) PATTERNS
////////////////////////////////////////////////////////////////////////////////
(
var centerBase, centerRange, speed, stepSize, lowerBound, upperBound;
var window, envViews, v, h, durations, thisBuf, thisPdef;

~numVoices = ~samples.size -1;
~voices = Dictionary.new;
~pdefNames = Array.new;
~namer = { |buf, index|
	var fileName = PathName(buf.path).fileName;
	var name = ((index+1).asString.padLeft(2, "0") ++ "- "++fileName).asSymbol;
	("namer: " ++ name).postln;
	~pdefNames = ~pdefNames.add(name);
	name;
};

~lfo1 = { | index, min, max, cycles|
	var t = index / cycles * 2pi;  // one full wave cycle over cycles events
	var a = sin(t) * 0.5 + 0.5;  // [0, 1]
	a = a * (max - min) + min;  // [min to max]
	a;
};

~debug = { |ev|
	("amp: %, start: %, a: %, r: %, d: %, [%]"
		.format(
			// e[\startpos].round(0.001),
			ev[\amp].round(0.001),
			ev[\startPos].round(0.001),
			ev[\atk].round(0.001),
			ev[\rel].round(0.001),
			ev[\dur].round(0.001),
			ev[\dur] - (ev[\atk] + ev[\rel])
		)
	).postln;
	// or, for all params
	// ev.postln;
};

centerBase = 3.0;
centerRange = 1.0;
speed = 0.1;
stepSize = 0.1;
lowerBound = 0.5;
upperBound = 5.0;

// Pdef.removeAll;

// Pdef.all.do { |p|
// 	p.postln;
// };


// Voice 1 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[8];
thisPdef = ~namer.(thisBuf, 0);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		\dur, 7,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		// \startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.6) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.1, 0.6, 96) },
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 2 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[9];
thisPdef = ~namer.(thisBuf, 1);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		\dur, 10.3,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		// \startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.6) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.1, 0.6, 96) },
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 3 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[10];
thisPdef = ~namer.(thisBuf, 2);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		\dur, 14.2,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.6) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.1, 0.6, 96) },
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 4 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[14];
thisPdef = ~namer.(thisBuf, 3);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		\dur, 19.2,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.2) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.5, 0.7, 96) },
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 5 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[15];
thisPdef = ~namer.(thisBuf, 4);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, Pseq([thisBuf.bufnum, ~samples[19]], inf),
		// \rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		// \rate, rrand(-1, 1).midiratio,
		\dur, 20,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.2) }),
		\amp, 0.4,
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 6 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[16];
thisPdef = ~namer.(thisBuf, 5);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		// \rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		\dur, 30,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.2) }),
		// \amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.2, 0.6, 96) },
		\amp, 0.6,
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 7 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[17];
thisPdef = ~namer.(thisBuf, 6);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		// \rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		\dur, 19.2,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.2) }),
		// \amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.1, 0.6, 96) },
		\amp, 0.5,
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 8 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[11];
thisPdef = ~namer.(thisBuf, 7);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		\dur, 0.8,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		// \startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.6) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.6, 96) },
		\out, Pseq([~out1_2], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 9 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[12];
thisPdef = ~namer.(thisBuf, 8);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		// \rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		\dur, 0.6,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.2) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.5, 96) },
		\out, Pseq([~out3_4], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 10 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[13];
thisPdef = ~namer.(thisBuf, 9);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		// \rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		// \rate, rrand(-1, 1).midiratio,
		\dur, 0.3,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.7) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.25, 96) },
		// \out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		\out, Pseq([~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 11 ////////////////////////////////////////////////////////////////////
// Manually start / stop
thisBuf = ~samples[14];
thisPdef = ~namer.(thisBuf, 10);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		\dur, 4,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.6) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.6, 96) },
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 12 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[19];
thisPdef = ~namer.(thisBuf, 11);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		// \rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		// \dur, 24.6,
		\dur, 2.4,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		// \startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.2) }),
		\amp, 0.4,
		\out, Pseq([~out1_2], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 13 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[18];
thisPdef = ~namer.(thisBuf, 12);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		// \rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		\dur, 4.8,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		// \startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.2) }),
		\amp, 0.4,
		\out, Pseq([~out3_4], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 14 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[19];
thisPdef = ~namer.(thisBuf, 13);

Pdef(thisPdef,
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		// \rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		\rate, 2.midiratio,
		\dur, 4.8,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		// \startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.2) }),
		\amp, 0.4,
		\out, Pseq([~out5_6], inf),
		// \do, Pfunc({ |ev| ~debug.(ev) }),
));




PdefAllGui(Pdef.all.size);
)

// Pdef.removeAll;

// ~samples.size
