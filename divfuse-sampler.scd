////////////////////////////////////////////////////////////////////////////////
// TEST / TRIGGER
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
// PATTERN PLAYGROUND
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


