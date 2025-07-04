////////////////////////////////////////////////////////////////////////////////
// SYNTH SPIINERs
////////////////////////////////////////////////////////////////////////////////

////////////////
// this is lush!
////////////////
// No LFO
// 6> Dictionary[ (sig -> Synth('temp__113' : 1278)), (vals -> Dictionary[ (amp -> 0.23485150337219), (pos -> 0.6), (freq -> 92), (speed -> 1.5), (width -> 3) ]) ]
// No LFO
// 8> Dictionary[ (sig -> Synth('temp__115' : 1280)), (vals -> Dictionary[ (amp -> 0.19711318016052), (pos -> 0.3), (freq -> 233), (speed -> 1.5), (width -> 3) ]) ]
// LFO
// 9> Dictionary[ (sig -> Synth('temp__116' : 1281)), (vals -> Dictionary[ (amp -> 0.25121099948883), (pos -> 0.3), (freq -> 415), (speed -> 0.1), (width -> 3) ]) ]
// LFO
// 10> Dictionary[ (sig -> Synth('temp__117' : 1282)), (vals -> Dictionary[ (amp -> 0.19814238548279), (pos -> 0.5), (freq -> 740), (speed -> 0.1), (width -> 3) ]) ]
(
var vals = Array.new;
var synthAmp = 0.4;

vals = vals.add(Dictionary[
	\name -> "voice1".asSymbol,
	\level -> 0.64,
	// \freq -> rrand(50, 120),
	// \amp -> rrand(0.1, 0.3),
	// \pos -> [3, 1, 1/3, 1/5, 1/7].choose,
	// \width -> rrand(0.1, 4)
	// \freq -> 92,
	// \note -> 42,
	\note -> 44,
	// \amp -> rrand(0.1, 0.3),
	\amp -> synthAmp,
	\cutoff -> 20000,
	\res -> 1.0,
	\pos -> 0.2,
	// \width -> rrand(3, 4),
	// \width -> rrand(0.5, 1.5),
	\width -> 1.39,
	\speed -> 0.0,
]);

vals = vals.add(Dictionary[
	\name -> "voice1b".asSymbol,
	\level -> 0.42,
	// \freq -> 46,
	\note -> 37,
	\amp -> synthAmp,
	\cutoff -> 20000,
	\res -> 1.0,
	\pos -> 0.31,
	\width -> 1.96,
	\speed -> 0.0,
]);

vals = vals.add(Dictionary[
	\name -> "voice2".asSymbol,
	\level -> 0.14,
	// \freq -> 233,
	\note -> 52,
	\amp -> synthAmp,
	\cutoff -> 20000,
	\res -> 1.0,
	\pos -> 0.32,
	\width -> 1.66,
	\speed -> 0.0,
]);

vals = vals.add(Dictionary[
	\name -> "voice3".asSymbol,
	\level -> 0.16,
	// \freq -> 415,
	\note -> 56,
	\amp -> synthAmp,
	\cutoff -> 20000,
	\res -> 1.0,
	\pos -> 0.3,
	\width -> 2.85,
	\speed -> 0.6,
]);

vals = vals.add(Dictionary[
	\name -> "voice4".asSymbol,
	\level -> 0.15,
	// \freq -> 740,
	\note -> 78,
	\amp -> synthAmp,
	\cutoff -> 20000,
	\res -> 1.0,
	\pos -> 0.5,
	\width -> 2.34,
	\speed -> 0.8,
]);

vals = vals.add(Dictionary[
	\name -> "voice5".asSymbol,
	\level -> 0.09,
	// \freq -> 350,
	\note -> 61,
	\amp -> synthAmp,
	\cutoff -> 20000,
	\res -> 1.0,
	\pos -> 0.16,
	\width -> 3,
	\speed -> 1,
]);

~synths = [];
~synths.size.postln;
~specs = ();

// these must match the label scales in TouchOSC!
~specs.put(\level,  ControlSpec(0, 1));
~specs.put(\note, ControlSpec.specs[\midinote]);
~specs.put(\amp, ControlSpec(0, 1));
~specs.put(\cutoff, ControlSpec.specs[\freq]);
~specs.put(\res, ControlSpec.specs[\rq]); //(change UI label 0..2)
~specs.put(\pos, ControlSpec(0.1, 4));
~specs.put(\width, ControlSpec(1, 4));
~specs.put(\speed, ControlSpec(0.1, 36.0));

~specs.keys.do { |key, val| [key, ~specs[key] ].postln };

vals.do { |val, i|

	fork {
	var synth = Dictionary[
		\vals -> nil,
		\sig -> nil
	];

	synth[\vals] = val;
	// i.post; '>>> '.post; val.postln;


	SynthDef(val[\name],
		{
			arg out=0, amp=0.3, freq=100, level=0.3, pos=0.5, speed=0.1, width=1, cutoff=440, res=0.01, note=60;
			var sigAmp, ampLFO;

			ampLFO = LFTri.kr(
				freq: speed,
				iphase: 3,
				mul: amp,
				add: amp
			);

			// compile time comparison
			sigAmp = if(val[\speed] == 0) { amp } { ampLFO };

			Out.ar(out,
				PanAz.ar(
					numChans: 6,
					in: RLPF.ar(
						in: Saw.ar(
							// freq: freq,
							freq: note.midicps,
							mul: sigAmp
						),
						freq: cutoff,
						// freq: LFPar.kr(
						// 	freq: pos/3,
						// 	iphase: 0,
						// 	mul: cutoff - 50,
						// add: cutoff),
						rq: res
					),
					pos: LFSaw.kr(
						freq: pos,
						iphase: LFTri.kr(
							freq: 0.03,
							mul: 1,
							add: 1
						)
					),
					level: level,
					width: width,
					orientation: 0.5
				)
			);
	}).add;

	s.sync;

	/*
	"amp = \t".post; amp.postln;
	"freq = \t".post; freq.postln;
	"pos = \t".post; pos.postln;
	"speed = \t".post; speed.postln;
	"width = \t".post; width.postln;
	*/

	synth[\sig] = Synth(val[\name],
		[
			"amp", val[\amp],
			// "freq", val[\freq],
			"note", val[\note],
			"pos", val[\pos],
			"speed", val[\speed],
			"width", val[\width],
			"cutoff", val[\cutoff],
			"res", val[\res],
		]
	).run(false);

	~synths = ~synths.add(synth);
	~synths.size.postln;
	};

};

/*{
	PanAz.ar(
		numChans: 6,
		// in: SinOsc.ar(rrand(50, 120), 0.0, 0.4),
		in: SinOsc.ar(freq: 80, phase: 0.0, mul: 0.5),
		// in: ClipNoise.ar(0.05),
		/*		in: RLPF.ar
		(
		in: LFPulse.ar
		(
		// SinOsc.kr(0.2, 0, 10, 21),
		15,
		0.1,
		0.1,
		),
		freq: 100,
		rq: 0.1,
		mul: 0.6
		).clip2(0.4),*/
		pos: LFSaw.kr(
			freq: 0.6,
			iphase: LFTri.kr(
				freq: 0.03,
				mul: 1,
				add: 1
			)
		),
		level: 0.4,
		width: 2,
		orientation: 0.5
	);
}.play*/
)


// reset
~synths = []

// print
~synths.do({ arg synth, i; i.post; '> '.post; synth.postln });

// release all
~synths.do({ arg synth, i; synth[\sig].release(3)});


// force a release
~synths[0][\sig].release(3);
// and then clear
~synths[1].clear;
// FADER

// MSP
~synths[0][\sig].set(\note, 44 );

// MUCH
~synths[0][\sig].set(\note, 42);

// MSP
~synths[1][\sig].set(\note, 32);

// MUCH
~synths[1][\sig].set(\note, 37);


~synths[4][\sig].set(\note, 78);


~synths[5][\sig].set(\note, 61);

~synths[0][\sig].set(\pos, 1.5);

~synths[0][\sig].nodeID

~synths[0][\sig].run(true)

~synths[0][\sig].run(false)

s.sendMsg("/n_free", ~synths[0][\sig].nodeID);

// s.sendMsg("/n_set", ~synths[0][\sig].nodeID, "gate", 0)
s.sendMsg("/n_set", ~synths[0][\sig].nodeID, "pos", 0.5)

~synths.size

z = Synth(\voice1)

z.pause




/*0> Dictionary[ (sig -> Synth('temp__107' : 1272)), (vals -> Dictionary[ (amp -> 0.15), (pos -> 1), (freq -> 740), (speed -> 0.3), (width -> 3) ]) ]
1> Dictionary[ (sig -> Synth('temp__108' : 1273)), (vals -> Dictionary[ (amp -> 0.15), (pos -> 1), (freq -> 213), (speed -> 0.1), (width -> 4) ]) ]
2> Dictionary[  ]
3> Dictionary[  ]
4> Dictionary[  ]
5> Dictionary[  ]
6> Dictionary[ (sig -> Synth('temp__113' : 1278)), (vals -> Dictionary[ (amp -> 0.23485150337219), (pos -> 0.6), (freq -> 92), (speed -> 1.5), (width -> 3) ]) ]
7> Dictionary[  ]*/


/*0> Dictionary[  ]
1> Dictionary[  ]
2> Dictionary[  ]
3> Dictionary[  ]
4> Dictionary[  ]
5> Dictionary[  ]
6> Dictionary[ (sig -> Synth('temp__113' : 1278)), (vals -> Dictionary[ (amp -> 0.23485150337219), (pos -> 0.6), (freq -> 92), (speed -> 1.5), (width -> 3) ]) ]
7> Dictionary[  ]
8> Dictionary[ (sig -> Synth('temp__115' : 1280)), (vals -> Dictionary[ (amp -> 0.19711318016052), (pos -> 0.3), (freq -> 233), (speed -> 1.5), (width -> 3) ]) ]*/

(
{
	LFTri.ar(
		420,
		0,
		LFTri.kr(0.1, 0, 0.3, 0.3)
	)
}.play

)

(
{
	// LFTri.kr(freq: 1, iphase: 3, mul: 0.3, add: 0.3)
	LFPar.kr(freq: 4, iphase: 0, mul: 750, add: 800)
}.plot(1)
)

{LFPar.ar(1, 2)}.plot(1)

rrand(250, 420)

(
{
	// Saw.ar(220, 0.2)
	SinOsc.ar(rrand(50, 120), 0.0, 0.4)
}.play;
)

// Panning calcs ////////////////////////////////
[0, 2, 4, 6, 8, 10]/6
// [ 0.0, 0.33333333333333, 0.66666666666667, 1.0, 1.3333333333333, 1.6666666666667 ] from docs, so why do they suggest a bipolar Saw?

3pi/2




