(
x = {
	PanAz.ar(
		numChans: 6,
		// in: SinOsc.ar(rrand(50, 120), 0.0, 0.4),
		in: SinOsc.ar(freq: 90, phase: 0.0, mul: 0.5),
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
		level: 0.3,
		width: 2,
		orientation: 0.5
	);
}.play
)

x.free;

(

SynthDef(\noise,
	{
		arg out=0, amp=0.3, freq=100, level=0.3, pos=0.5, speed=0.1, width=1, cutoff=10000, res=0.01;
		var sigAmp, ampLFO;

		ampLFO = LFTri.kr(
			freq: speed,
			iphase: 3,
			mul: amp,
			add: amp
		);

		Out.ar(out,
			PanAz.ar(
				numChans: 6,
				in: RHPF.ar(
					in: ClipNoise.ar(
						// mul: 0.05
						mul: ampLFO
					),
					freq: cutoff
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
}).add
)

y = Synth(\noise, [\level, 0.04]);

y = Synth(\noise, [\speed, 1]);

// AMP LFO
y.set(\speed, 0.1);

// PAN SPEED
y.set(\pos, 0.6);

// LEVEL
y.set(\level, 0.04);

y.free;

(
z = {
	PanAz.ar(
		numChans: 6,
		in: RHPF.ar
		(
			in: LFPulse.ar
			(
				// SinOsc.kr(0.2, 0, 10, 21),
				15,
				0.1,
				0.1,
			),
			freq: 10000,
			rq: 1.0,
			mul: 0.6
		).clip2(0.4),
		// pos: 2,
		pos: LFSaw.kr(
			freq: 0.3,
			iphase: LFTri.kr(
				freq: 0.03,
				mul: 1,
				add: 1
			)
		),
		level: 0.65,
		width: 2,
		orientation: 0.5
	);
}.play
)

z.free;


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