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
// ~sampleDir = "/Users/yourname/Samples/Kicks"
~sampleDir = "/data/Dropbox-spatial/Dropbox/spatial/music/AudioSources/divfuse-202504/vowelsfemale*";

PathName(~sampleDir).files.do { |file, i|
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

PdefAllGui(Pdef.all.size);

Pdef(\loop10,
Pbind(
	\instrument, \panningSamplePlayer,
	// \bufnum, Prand((0..~samples.size), inf),
	// \bufnum, 12,
	// \bufnum, Pseq([0, 1, 2], inf).collect { |i| ~samples[i].bufnum },
	// \bufnum, Pseq([19, 20, 21, 22], inf).collect { |i| ~samples[i].bufnum },
	// \bufnum, Pseq([10, 11, 12, 11, 10], inf).collect { |i| ~samples[i].bufnum },
	// \bufnum, Pseq([30, 31, 32, 33, 34], inf).collect { |i| ~samples[i].bufnum },
	\bufnum, 9,
	\dur, 10,
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
	// ).trace.play();
	);
// ).play();
	);
)

////////////////////////////////////////////////////////////////////////////////
// (5) PATTERN LOOP
////////////////////////////////////////////////////////////////////////////////

// 10.asString.padLeft(2, "0")

(
var centerBase, centerRange, speed, stepSize, lowerBound, upperBound;
var window, envViews, v, h;

~numVoices = 10;
~voices = Dictionary.new;
centerBase = 3.0;
centerRange = 1.0;
speed = 0.1;
stepSize = 0.1;
lowerBound = 0.5;
upperBound = 5.0;

Window.closeAll;
window = Window("Envs", Rect(100, 100, 400, Window.screenBounds.height/1.6)).front;
h = HLayout();
v = VLayout(h);
window.layout =  v;
window.front;
window.alwaysOnTop = true;

(0..~numVoices).do { |i|
	var voiceName = ("voice" ++ (i + 1).asString.padLeft(2, "0")).asSymbol;
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
		\bufnum, i,
		\dur, i+1,
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
		\do, Pfunc { |e|
			{
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
		\amp, Pseries(0, 1).collect { |i|
			var t = i / rrand(24, 96) * 2pi;  // one full wave cycle over 48 events
			var min = 0.2;
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

(
{
    PanAz.ar(
        numChans: 6,
		in: SinOsc.ar(rrand(50, 120), 0.0, 0.4),
		// in: ClipNoise.ar(0.1),
		// in: Saw.ar(rrand(50, 120), rrand(0.1, 0.3)),
		// in: Saw.ar(rrand(250, 420), rrand(0.1, 0.3)),
		// in: RLPF.ar(Saw.ar([100,250],0.1), XLine.kr(8000,400,5), 0.05),
		// in: Klang.ar(`[ Array.rand(12, 600.0, 1000.0), nil, nil ], 1, 0) * 0.05,
		// pos: LFSaw.kr(MouseX.kr(0.2, 8, 'exponential')).poll,
		pos: LFSaw.kr(rrand(0.2, 2)),
        level: 0.5,
		width: rrand(0.1, 4),
		// width: 4,
        orientation: 0.5
    );
// }.scope.trace
}.play.trace
)
