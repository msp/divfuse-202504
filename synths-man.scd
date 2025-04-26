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
y = {
	PanAz.ar(
		numChans: 6,
		in: RHPF.ar(
			in: ClipNoise.ar(
				mul: 0.05
				// mul: LFTri.kr(
				// 	freq: 0.5,
				// 	iphase: 3,
				// 	mul: 0.05,
				// 	add: 0.05
				// );
			),
			freq: 10000
		),
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
		level: 0.15,
		width: 2,
		orientation: 0.5
	);
}.play
)

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