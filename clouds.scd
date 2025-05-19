

(  // basic granulation
{
    var input = PlayBuf.ar(1, ~samples[0], 1, loop: 1)!2;

    var dens = LFNoise1.kr(0.3).range(0.3, 0.45);
    MiClouds.ar(input, 0, 0, 0, dens, 0.5, drywet: 1, mode: 0);

}.play
)

(  //
{
    var imp = Dust.ar([0.8,1.1]);
    var freq = Latch.ar(PinkNoise.ar(24,80), imp).midicps;
	// var input = RLPF.ar(imp, freq, 0.002, 4);

	var input = PlayBuf.ar(1, ~samples[1], 1, loop: 1)!2;

	// var pit = LFNoise1.kr(0.3,12);
	var pit = 1;

	// var pos = LFNoise2.kr(0.4,0.5,0.5);
	var pos = MouseX.kr(0, 1);

    var size = LFNoise1.kr(0.3,0.5,0.5);
	// var dens = LFNoise1.kr(0.3,0.5,0.5);
	var dens = MouseY.kr(0,1);
    var tex = LFNoise1.kr(0.3,0.5,0.5);

    var frez = LFClipNoise.kr(0.3);

    MiClouds.ar(input, pit, pos, size, dens, tex,
		drywet: 0.5,
		// in_gain: 2,
		rvb:0,
		fb: 0,
		freeze: 1,
		// lofi: 0,
		mode: 0
	);
}.play
)



(
SynthDef(\scratch,
	{
		arg bufnum=0, pit=1, tex=0.5, freeze=0, mode=0, drywet=0.5, in_gain=1, rvb=0, fb=0;
		var input = PlayBuf.ar(1, bufnum, 1, loop: 1)!2;

		var pos = MouseX.kr(0,1);
		var size = MouseY.kr(0,1);
		var dens = LFNoise1.kr(0.3,0.5,0.5);


		Out.ar(0,
			MiClouds.ar(
				input,
				pit: pit,
				pos: pos,
				size: size,
				dens: dens,
				tex: tex,
				drywet: drywet,
				in_gain: in_gain,
				freeze: freeze,
				rvb: rvb,
				fb: fb,
				mode: mode
			)
		);
}).add;
)

x = Synth(\scratch, [\bufnum: ~samples[2].bufnum])

x.set(\freeze, 1)
x.set(\freeze, 0)

x.set(\in_gain, 1.5)

x.set(\mode, 0)

x.set(\drywet, 0.1)

x.set(\pit, 1)

x.set(\tex, 0.8)

x.set(\rvb, 0.5)

x.set(\fb, 0)

x.free

y = Synth(\scratch, [\bufnum: ~samples[3].bufnum])

y.set(\mode, 0)

y.set(\in_gain, 0.6)

y.set(\drywet, 0.5)

y.set(\pit, 1.0)

y.set(\tex, 0.5)

y.set(\rvb, 0.2)

y.set(\fb, 0)

y.free


z = Synth(\scratch, [\bufnum: ~samples[1].bufnum])

z.set(\in_gain, 0.6)

z.set(\drywet, 0.5)

z.set(\pit, 5)

z.set(\tex, 0.3)

z.set(\rvb, 0.6)

z.set(\fb, 0.7)

z.free














