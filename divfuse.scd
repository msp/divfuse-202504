//// TEST ///////////////////////////////////////////////////////////////
(

(
type:\dirt,
orbit: ~out1_2,
// s: \halfmast,
s: \vowelsfemale,
n: 24.rand,
// n: 0,
// begin: rrand(0, 0.9),
// end: rrand(0.1, 1),
speed: rrand(0.8, 1),
pan: rrand(0, 1),
gain: 0.85,
).play;

)

(

var speed, delayTime;

if (0.5.coin) {
	speed = 0.7;
} {
	speed = 1.0;
};

if (0.5.coin) {
	delayTime = 1/3;
} {
	delayTime = 1/2;
};

(
type:\dirt,
// orbit: ~out1_2,
s: \vowelsfemale,
n: 0,
// n: 0,
// begin: rrand(0, 0.9),
// end: rrand(0.1, 0.3),
// speed: speed,
// delaytime: delayTime,
// delay: rrand(0.1, 0.8),
// delayfeedback: rrand(0.1, 0.9),
// shape: 0.2,
pan: rrand(0, 1),
gain: 1.0
).play;

)


//// SEQN ///////////////////////////////////////////////////////////////
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
// envView.drawDots = true;
envView.setEnv(Env.perc(0.01, 0.1));  // initial envelope
// envView.timeScale = 1.0;  // scales the X-axis (time)

~perlinLikeDur = Array.newClear(128);

128.do { |i|
	var center = centerBase + (sin(i * speed) * centerRange);
	var prev = if(i == 0) { center } { ~perlinLikeDur[i - 1] };
	var minStep = 0 - stepSize;
	var step = minStep.rrand(stepSize) + ((center - prev) * 0.05);
	var val = (prev + step).clip(lowerBound, upperBound);
	~perlinLikeDur[i] = val;
};

// Pdef(\autobotSeq,
Pbind(
	\type, \dirt,
	\s, \vowelsfemale,
	\n, Prand((0..36), inf),
	// \n, 22,
	// \s, \halfmast,
	// \n, Prand((0..24), inf),
	// \n, 0,
	// \amp, Pseq([0.1], inf),
	// \room, Pseq([0, 0.25, 0.75, 0.8], inf),
	// \size, Pseq([0.6, 0.75, 0.25, 0], inf),
	// \shape, 0.4,
    \dur, 5,
	// \attack, Prand([0.3, 0.5, 0.8, 0.9], inf),
	// \attack, Pgeom(0.01, 1.1, inf),
	// \attack, Pseries(0, 1).collect { |i| ((2 ** (i/4)) * 0.1).clip(0.1, 0.9) },
	\attack, Pgeom(0.01, 1.5, 12).repeat,  // start at 0.001, multiply by 1.5 each step
	// \release, Prand([0.5,1,2], inf),
    \release, Pfunc { |e|
        e[\dur] - e[\attack]
    },
    \legato, Pfunc { |e|
        var total = e[\attack] + e[\release];
        (total / e[\dur]).max(0.95)
    },
	\do, Pfunc { |e|
		{
            var attack = e[\attack];
            var release = e[\release];
            var env = Env.new([0, 1, 0], [attack, release], 'lin');
            envView.setEnv(env);

			("a: %, r: %, d: %, [%]"
				.format(
					e[\attack].round(0.001),
					e[\release].round(0.001),
					e[\dur].round(0.001),
					e[\dur] - (e[\attack] + e[\release])
				)
			).postln;
		}.defer
	},
	// \legato,7,
	\out, Pseq([0, 1], inf),
	// \out, 0.5,
// ).trace.play;
	).play;
// )
// );
)

SuperDirt.synthDef("default").def.dumpUGens;












(
var centerBase, centerRange, speed, stepSize, lowerBound, upperBound;

centerBase = 3.0;
centerRange = 1.0;
speed = 0.1;
stepSize = 0.1;
lowerBound = 0.5;
upperBound = 5.0;

~perlinLikeDur = Array.newClear(128);

128.do { |i|
	var center = centerBase + (sin(i * speed) * centerRange);
	var prev = if(i == 0) { center } { ~perlinLikeDur[i - 1] };
	var minStep = 0 - stepSize;
	var step = minStep.rrand(stepSize) + ((center - prev) * 0.05);
	var val = (prev + step).clip(lowerBound, upperBound);
	~perlinLikeDur[i] = val;
};
)


~perlinLikeDur.plot(discrete: true);

Quarks.gui

