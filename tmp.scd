{
		arg amp=0.3, freq=100, level=0.3, pos=0.5, speed=0.1, width=1;
		var sigAmp, ampLFO;

		ampLFO = LFTri.kr(
			freq: speed,
			iphase: 3,
			mul: amp,
			add: amp
		);

		sigAmp = if(speed == 0) { amp } { ampLFO };
		"sigAmp = \t".post; sigAmp.postln;

		PanAz.ar(
			numChans: 6,
			// in: SinOsc.ar(rrand(50, 120), 0.0, 0.4),
			// in: SinOsc.ar(freq, 0.0, 0.5),
			// in: ClipNoise.ar(0.05),
			in: Saw.ar(
				freq: freq,
				mul: sigAmp
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
			// in: Saw.ar(73, amp),
			// in: Saw.ar(rrand(250, 420), rrand(0.1, 0.3)),
			// in: Saw.ar(220, 0.3),
			// in: RLPF.ar(Saw.ar([100,250],0.1), XLine.kr(8000,400,5), 0.05),
			// in: Klang.ar(`[ Array.rand(12, 600.0, 1000.0), nil, nil ], 1, 0) * 0.05,
			// pos: LFSaw.kr(MouseX.kr(0.2, 8, 'exponential')).poll,
			// pos: LFSaw.kr(rrand(0.2, 2)),
			// pos: Line.ar(-1, 1, 1),
			// pos: LFSaw.kr(freq: 4, iphase: 3, mul: 0.3, add: 0.3) * LFTri.kr(0.5),
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
		);
		// }.scope.trace
	};