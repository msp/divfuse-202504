////////////////////////////////////////////////////////////////////////////////
// (3) PATTERN LOOP
////////////////////////////////////////////////////////////////////////////////
(
var centerBase, centerRange, speed, stepSize, lowerBound, upperBound;
var window, envViews, v, h, durations;

~numVoices = ~samples.size -1;
~voices = Dictionary.new;
durations = Dictionary.newFrom(
	[
		\1, 1,
		\2, 2,
		\3, 3,
		\4, 4,
		\5, 5,
		\6, 6,
		\7, 7,
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
/*		\startPos, Pfunc { |e|
			// Grab the duration of the buffer (using BufDur.ir so it is evaluated on the language side)
			var bd = BufDur.ir(e[\bufnum]);
			var dur = e[\dur];
			// Return a random number between 0 and (bd - dur)
			var startpos = rrand(0, (bd - dur).max(0));  // .max(0) ensures we have a non-negative value if bd < dur
			// ("startpos: %".format(startpos.round(0.001))).postln;
			startpos;
		},*/
		// \startPos, 1000,
		\do, Pfunc { |e|
			{
				var env = Env.asr(e[\atk], 1, e[\rel]);
				envView.setEnv(env);

				("amp: %, a: %, r: %, d: %, [%]"
					.format(
						// e[\startpos].round(0.001),
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
			var t = i / 96 * 2pi;  // one full wave cycle over 48 events
			var min = 0.1;
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
