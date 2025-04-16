////////////////////////////////////////////////////////////////////////////////
// (1a) BOOT
////////////////////////////////////////////////////////////////////////////////

(
ServerOptions.devices.do({ |dev, i|
    [i, dev].postln;
});

s.options.device = "Fireface UCX (23733485)";  // must match a name from ServerOptions.devices
s.options.numOutputBusChannels = 8;     // or however many outputs you want
s.options.numInputBusChannels = 0;      // if you don't need inputs
s.reboot; // or s.boot if you're not changing the device
)

////////////////////////////////////////////////////////////////////////////////
// (1b) SETUP - ensure the path to sample folder is correct
////////////////////////////////////////////////////////////////////////////////

(
Buffer.freeAll;

~out1 = 0;
~out2 = 1;
~out3 = 2;
~out4 = 3;
~out5 = 4;
~out6 = 5;
~out7 = 6;
~out8 = 7;
~out9 = 8;

~out1_2 = 0;
~out3_4 = 2;
~out5_6 = 4;


~samples = Array.new;
~synths = Array.new;

// ~sampleDir = "/Users/yourname/Samples/Kicks"
// ~sampleDir = "/data/Dropbox-spatial/Dropbox/spatial/music/AudioSources/divfuse-202504/vowelsfemale*";
// ~sampleDir = "/data/Dropbox-spatial/Dropbox/spatial/music/AudioSources/divfuse-202504/halfmasthums*";
~sampleDir = "/data/Dropbox-spatial/Dropbox/spatial/music/AudioSources/divfuse-202504/halfmastv3*";

PathName(~sampleDir).files.do { |file, i|
	("Found " ++ file.fileName).postln;
    if(file.extension == "wav") {
        var buf = Buffer.readChannel(s, file.fullPath, channels: [0]);  // mono
		// ~samples[file.fileNameWithoutExtension] = buf;
		~samples = ~samples.add(buf);
        ("Loaded " ++ file.fileName).postln;
    }
};

"Total loaded: " ++ ~samples.size;
)

////////////////////////////////////////////////////////////////////////////////
// (2) SAMPLER
////////////////////////////////////////////////////////////////////////////////
(
SynthDef(\panningSamplePlayer, {
    |out=0, bufnum=0, amp=1, rate=1, startPos=0, panDur=5,
     atk=0.01, rel=0.1, gate=1|

    var sig, env, pan;

    // Pan from -1 to 1 over panDur
    pan = Line.kr(-1, 1, panDur);

    // Envelope
    env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction: 2);

    // Sample playback, gated by envelope
    sig = PlayBuf.ar(
        numChannels: 1,
        bufnum: bufnum,
        rate: rate * BufRateScale.kr(bufnum),
		startPos: startPos,
        doneAction: 0
    );

    sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	// Pan4.ar
    Out.ar(out, sig);
}).add;
)

////////////////////////////////////////////////////////////////////////////////
// (3) TEST / TRIGGER
////////////////////////////////////////////////////////////////////////////////

(
Pbind(
    \instrument, \panningSamplePlayer,
    \bufnum, ~samples[0].bufnum,
    \dur, 3,
    \panDur, 3,
    \atk, 0.1,
    \rel, 0.1,
    \amp, 0.2,
	\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
).play;
)

(
Synth(\panningSamplePlayer, [
    \bufnum, ~samples[0].bufnum,
    \amp, 0.4,
    \atk, 0.02,
    \rel, 0.3,
	\pan, 1,
	\out, 0

]);
)

////////////////////////////////////////////////////////////////////////////////
// (4) PATTERN
////////////////////////////////////////////////////////////////////////////////

(
var centerBase, centerRange, speed, stepSize, lowerBound, upperBound;
var window, envView;

centerBase = 3.0;
centerRange = 1.0;
speed = 0.1;
stepSize = 0.1;
lowerBound = 0.5;
upperBound = 5.0;

window = Window("Live Envelope", Rect(100, 100, 400, 200)).front;
envView = EnvelopeView(window, Rect(20, 20, 360, 160));
envView.drawLines = true;
envView.setEnv(Env.perc(0.01, 0.1));  // initial envelope

~perlinLikeDur = Array.newClear(128);

// DONT USE AS IT MESSES UP PANNER !
// ~clock = TempoClock.new(2);  // 2 beats per second = 120 bpm

128.do { |i|
	var center = centerBase + (sin(i * speed) * centerRange);
	var prev = if(i == 0) { center } { ~perlinLikeDur[i - 1] };
	var minStep = 0 - stepSize;
	var step = minStep.rrand(stepSize) + ((center - prev) * 0.05);
	var val = (prev + step).clip(lowerBound, upperBound);
	~perlinLikeDur[i] = val;
};

// PdefAllGui(Pdef.all.size);

Pbind(
	\instrument, \panningSamplePlayer,
	// \bufnum, Prand((0..~samples.size), inf),
	// \bufnum, 12,
	// \bufnum, Pseq([0, 1, 2], inf).collect { |i| ~samples[i].bufnum },
	// \bufnum, Pseq([19, 20, 21, 22], inf).collect { |i| ~samples[i].bufnum },
	// \bufnum, Pseq([10, 11, 12, 11, 10], inf).collect { |i| ~samples[i].bufnum },
	// \bufnum, Pseq([30, 31, 32, 33, 34], inf).collect { |i| ~samples[i].bufnum },
	\bufnum, 2,
	\dur, 0.05,
	// \bufnum, Pseq([9, 10], inf).collect { |i| ~samples[i].bufnum },
	// \bufnum, Pseq([5, 6], inf).collect { |i| ~samples[i].bufnum },
	// \dur, Pseq([3, 1, 4, 2, 1], inf),  // pattern for spacing between events
	// \dur, Pseq([0.05, 0.1, 0.2], inf),
	// \dur, Pseq([0.2, 0.1], inf),
	// \dur, Pgeom(0.5, 1.2, 10).repeat,  // start at 0.001, multiply by 1.5 each step
	// \panDur, Pkey(\dur),            // pass dur into synth as pan duration
	// \atk, Pseries(0, 1).collect { |i| ((2 ** (i/4)) * 0.1).clip(0.1, 0.9) },

	\atk, Pseries(0, 1).collect { |i|
		var t = i / (rrand(24, 96)) * 2pi;  // one full wave cycle over 24-96 events
		var min = 0.01;
		var max = 0.9;
		var a = sin(t) * 0.5 + 0.5;  // [0, 1]
		a = a * (max - min) + min;  // [min to max]
		a;
	},
	// \atk, 0.1,
	\rel, Pfunc { |e|
		e[\dur] - e[\atk]
	},
	// \rel, 0.1,
	\do, Pfunc { |e|
		{
			var amp = e[\amp];
				// var env = Env.new([0, 1, 0], [attack, release], 'lin');
            var env = Env.asr(e[\atk], 1, e[\rel]);
            envView.setEnv(env);

			("(%) a: %, r: %, d: %, [%]"
				.format(
					e[\amp].round(0.001),
					e[\atk].round(0.001),
					e[\rel].round(0.001),
					e[\dur].round(0.001),
					e[\dur] - (e[\atk] + e[\rel])
				)
			).postln;
		}.defer
	},
	// \amp, 0.8,
	\amp, Pseries(0, 1).collect { |i|
		var t = i / rrand(24, 96) * 2pi;  // one full wave cycle over 48 events
		var min = 0.2;
		var max = 0.6;
		var a = sin(t) * 0.5 + 0.5;  // [0, 1]
		a = a * (max - min) + min;  // [min to max]
		a;
	},
	\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
	).trace.play();
// );
// ).play();
)

////////////////////////////////////////////////////////////////////////////////
// (5) PATTERN LOOP
////////////////////////////////////////////////////////////////////////////////

(
var centerBase, centerRange, speed, stepSize, lowerBound, upperBound;
var window, envViews, v, h, durations;

~numVoices = 21;
~voices = Dictionary.new;
durations = Dictionary.newFrom(
	[
		\1, 1,
		\2, 2,
		\3, 3,
		\4, 4,
		\5, 5,
		\6, 6,
		\7, 22,
		\8, 8,
		\9, 9,
		\10, 10,
		\11, 11,
		\12, 12,
		\13, 13,
		\14, 14,
		\15, 15,
		\16, 16,
		\17, 17,
		\18, 18,
		\19, 19,
		\20, 20,
		\21, 21,
		\22, 22,
	]
);

centerBase = 3.0;
centerRange = 1.0;
speed = 0.1;
stepSize = 0.1;
lowerBound = 0.5;
upperBound = 5.0;

// Window.closeAll;
window = Window("Envs", Rect(100, 100, 400, Window.screenBounds.height/1.6)).front;
h = HLayout();
v = VLayout(h);
window.layout =  v;
window.front;
window.alwaysOnTop = true;

(0..~numVoices).do { |i|
	var fileName = PathName(~samples[i].path).fileName;
	// var voiceName = ("voice" ++ (i+1).asString.padLeft(2, "0")).asSymbol;
	var voiceName = ((i+1).asString.padLeft(2, "0") ++ "- "++fileName).asSymbol;
	var envView = EnvelopeView(window, Rect(20, 20, 360, 160));
	envView.drawLines = true;
	envView.setEnv(Env.asr(0.01, 1, 0.3));
	v.add(envView);

	/*    ~voices[voiceName] = Pdef(voiceName, Pbind(
	\instrument, \yourSynth,   // Replace \yourSynth with your actual SynthDef name
	\amp, Pkey(\amp),          // Volume will be controlled by an external key
	\pan, Pkey(\pan),          // Pan will be controlled by an external key
	\dur, 1                   // Duration of each event (beats)
	));*/

	~voices[voiceName] = Pdef(voiceName, Pbind(
		\instrument, \panningSamplePlayer,
		\bufnum, ~samples[i].bufnum,
		\dur, durations.atFail((i+1).asSymbol, { |j| j }),
		\atk, Pseries(0, 1).collect { |i|
			// var t = i / (rrand(24, 96)) * 2pi;  // one full wave cycle over 24-96 events
			var t = i / 48 * 2pi;  // one full wave cycle over 24-96 events
			var min = 0.01;
			var max = 0.9;
			var a = sin(t) * 0.5 + 0.5;  // [0, 1]
			a = a * (max - min) + min;  // [min to max]
			a;
		},
		\rel, Pfunc { |e|
			e[\dur] - e[\atk]
		},
		// startpos is randomly chosen between 0 and (buffer duration - event duration)
		\startpos, Pfunc { |e|
			// Grab the duration of the buffer (using BufDur.ir so it is evaluated on the language side)
			var bd = BufDur.ir(e[\bufnum]);
			var dur = e[\dur];
			// Return a random number between 0 and (bd - dur)
			var startpos = rrand(0, (bd - dur).max(0));  // .max(0) ensures we have a non-negative value if bd < dur
			("startpos: %".format(startpos.round(0.001))).postln;
			startpos;
		},
		\do, Pfunc { |e|
			{
				// var env = Env.new([0, 1, 0], [attack, release], 'lin');
				var env = Env.asr(e[\atk], 1, e[\rel]);
				envView.setEnv(env);

				("(%) s: %, a: %, r: %, d: %, [%]"
					.format(
						e[\startpos].round(0.001),
						e[\amp].round(0.001),
						e[\atk].round(0.001),
						e[\rel].round(0.001),
						e[\dur].round(0.001),
						e[\dur] - (e[\atk] + e[\rel])
					)
				).postln;
			}.defer
		},
		\amp, Pseries(0, 1).collect { |i|
			// var t = i / rrand(24, 96) * 2pi;  // one full wave cycle over 48 events
			var t = i / 48 * 2pi;  // one full wave cycle over 48 events
			var min = 0.3;
			var max = 0.6;
			var a = sin(t) * 0.5 + 0.5;  // [0, 1]
			a = a * (max - min) + min;  // [min to max]
			a;
		},
		\out, Pseq([~out1_2, ~out3_4, ~out5_6], inf),
	));
	// ~voices[voiceName].play;  // Start the pattern
};

PdefAllGui(Pdef.all.size);
// s.scope;
)


////////////////////////////////////////////////////////////////////////////////
// SCRATCHPAD
////////////////////////////////////////////////////////////////////////////////

(
~clock = TempoClock.new(2);  // 2 beats per second = 120 bpm

Pbind(
    \instrument, \cleanSamplePlayer,
	// \bufnum, Pseq([10, 11, 12, 11, 10], inf).collect { |i| ~samples[i].bufnum },
    \bufnum, 0,
    \dur, 3,
    \atk, 0.01,
    \rel, 2,
    \amp, 0.8
).play(~clock);
)

(
var tempo;
Routine({
    10.do {
        tempo = exprand(1, 4);
		"Tempo: " ++ tempo.postln;
		~clock.tempo = tempo;
        3.wait;
    }
}).play;
)


~fx = Synth.tail(nil, \fx)

~fx.set(\trigger, 1);

~voices

~synths = [];

(
var vals = Dictionary[
	\freq -> rrand(50, 120),
	\amp -> rrand(0.1, 0.3),
	\pos -> [3, 1, 1/3, 1/5, 1/7].choose,
	\width -> rrand(0.1, 4)
];

var synth = Dictionary[
	\vals -> nil,
	\sig -> nil
];

~synths.size.postln;
synth[\vals] = vals;
synth[\vals].postln;

synth[\sig] = {
	PanAz.ar(
		numChans: 6,
		in: SinOsc.ar(rrand(50, 120), 0.0, 0.4),
		// in: ClipNoise.ar(0.05),
		// in: Saw.ar(vals[\freq], vals[\amp]),
		// in: Saw.ar(rrand(250, 420), rrand(0.1, 0.3)),
		// in: Saw.ar(220, 0.3),
		// in: RLPF.ar(Saw.ar([100,250],0.1), XLine.kr(8000,400,5), 0.05),
		// in: Klang.ar(`[ Array.rand(12, 600.0, 1000.0), nil, nil ], 1, 0) * 0.05,
		// pos: LFSaw.kr(MouseX.kr(0.2, 8, 'exponential')).poll,
		// pos: LFSaw.kr(rrand(0.2, 2)),
		pos: LFSaw.kr(vals[\pos]),
		// pos: Line.ar(-1, 1, 1),
		// pos: 1,
		// level: 0.5,
		level: 0.5,
		width: vals[\width],
		// width: 4,
		orientation: 0.5
	);
	// }.scope.trace
}.play();

~synths = ~synths ++ [synth];
~synths.size.postln;
)

~synths.do({ arg synth, i; i.post; '> '.post; synth.postln });

~synths.do({ arg synth, i; synth[\sig].release(3)});

~synths.do({ arg synth, i; synth[\sig].free  });

~synths = []

~synths[0][\sig].release(3);
~synths[2].clear;


rrand(250, 420)

(
{
	// Saw.ar(220, 0.2)
	SinOsc.ar(rrand(50, 120), 0.0, 0.4)
}.play;
)


(
x = { arg spread=1, level=0.3, width=2, center=0.0;
	SplayAz.ar(
		6,
		// SinOsc.ar( { |i| LFNoise2.kr( rrand(10, 20), 200, i + 3 * 100) } ! 10),
		Saw.ar({ rrand(200, 320) } ! 4, 0.3),
		// Saw.ar(rrand(50, 120), 0.3) ! 2,
		spread,
		level,
		width,
		center
	);
}.play;
)

x.release(3)

x.set(\spread, 0.25,   \center, 0);  // msp

x.set(\spread, 1,   \center, 0);  // full n chans
x.set(\spread, 0.5, \center, -0.25); // less wide
x.set(\spread, 0, \center, 0);  // mono center (depends on orientation, see PanAz)
x.set(\spread, 0, \center, -0.25); //
x.set(\spread, 0.0, \center, 0.5); // mono, but rotate 1 toward the higher channels
x.set(\spread, 0.5, \center, 0.5); // spread over the higher channels
x.set(\spread, 0,   \center, -0.25); // all on first channel
x.set(\spread, 1,   \center, 0);  // full n chans

x.free;


