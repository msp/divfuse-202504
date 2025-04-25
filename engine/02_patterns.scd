////////////////////////////////////////////////////////////////////////////////
// (3) PATTERN LOOP
////////////////////////////////////////////////////////////////////////////////
(
var centerBase, centerRange, speed, stepSize, lowerBound, upperBound;
var window, envViews, v, h, durations, thisBuf;

~numVoices = ~samples.size -1;
~voices = Dictionary.new;
~namer = { |buf, index|
	var fileName = PathName(buf.path).fileName;
	((index+1).asString.padLeft(2, "0") ++ "- "++fileName).asSymbol;
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
thisBuf = ~samples[0];

Pdef(~namer.(thisBuf, 0),
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		\rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 0).choose.midiratio }),
		\dur, 1,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.6) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.1, 0.6, 96) },
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		\do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 2 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[1];

Pdef(~namer.(thisBuf, 0),
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		\rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		\dur, 2,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.6) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.1, 0.6, 96) },
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		\do, Pfunc({ |ev| ~debug.(ev) }),
));

// Voice 3 ////////////////////////////////////////////////////////////////////
thisBuf = ~samples[2];

Pdef(~namer.(thisBuf, 0),
	Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, thisBuf.bufnum,
		\rate, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
		\dur, 0.05,
		\panDur, Pkey(\dur),
		\atk, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.01, 0.9, 48) },
		\rel, Pfunc { |e| e[\dur] - e[\atk] },
		\startPos, Pfunc({ rrand(0, thisBuf.numFrames * 0.6) }),
		\amp, Pseries(0, 1).collect { |i| ~lfo1.(i, 0.1, 0.6, 96) },
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
		\do, Pfunc({ |ev| ~debug.(ev) }),
));



PdefAllGui(Pdef.all.size);
)