////////////////////////////////////////////////////////////////////////////////
// (.) CLOUDS
////////////////////////////////////////////////////////////////////////////////

(  // basic granulation
{
    var input = PlayBuf.ar(1, ~samples[0], 1, loop: 1)!2;

    var dens = LFNoise1.kr(0.3).range(0.3, 0.45);
    MiClouds.ar(input, 0, 0, 0, dens, 0.5, drywet: 1, mode: 0);

}.play
)

~samples[1].path

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
		drywet: 1.0,
		// in_gain: 2,
		rvb:0,
		fb: 0,
		freeze: 0,
		// lofi: 0,
		mode: 0
	);
}.play
)



(
SynthDef(\clouds,
	{
		arg bufnum=0, pit=1, tex=0.5, freeze=0, mode=0, drywet=0.5, in_gain=1, rvb=0, fb=0, dens=0.3, trig=0.0;
		var input = PlayBuf.ar(1, bufnum, 1, loop: 1)!2;

		var pos = MouseX.kr(0,1);
		var size = MouseY.kr(0,1);
		// var dens = LFNoise1.kr(0.3,0.5,0.5);


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
				mode: mode,
				trig: trig
			)
		);
}).add;
)

x = Synth(\clouds, [\bufnum: ~testSamples[0].bufnum])

x.set(\freeze, 1)
x.set(\freeze, 0)

x.set(\in_gain, 1.5)

x.set(\mode, 0)

x.set(\drywet, 1.0)

x.set(\pit, 1)

x.set(\dens, 0.38)

x.set(\tex, 0.1)

x.set(\rvb, 0)

x.set(\fb, 0)

x.set(\trig, 0.0)

x.free

y = Synth(\clouds, [\bufnum: ~samples[3].bufnum])

y.set(\mode, 0)

y.set(\in_gain, 0.6)

y.set(\drywet, 1.0)

y.set(\pit, 1.0)

y.set(\tex, 0.5)

y.set(\rvb, 0.2)

y.set(\fb, 0)

y.free


z = Synth(\clouds, [\bufnum: ~samples[1].bufnum])

z.set(\in_gain, 0.6)

z.set(\drywet, 1.0)

z.set(\pit, 5)

z.set(\tex, 0.3)

z.set(\rvb, 0.6)

z.set(\fb, 0.7)

z.free


// using external grain trigger (from docs)
(
a = {
	arg freeze=0, speed=1, size=0.5, dens=0.5;
    var input = PlayBuf.ar(1, b, 1, loop: 1)!2;

	// var dens = 0.5;
	// var trig = Dust.kr(10).poll;
	var trig = Pulse.kr(speed);
	var pos = MouseX.kr(0,1);
	// var freeze = MouseY.kr(0,1);
	// var size = 0.9;
	var pitch = 1;

    MiClouds.ar(input, pitch, pos, size, dens, 0.5, freeze: freeze, trig: trig, drywet: 1, mode: 0);

}.play
)

a.set(\size, 0.2);

a.set(\dens, 0.4);

a.set(\speed, 1.0);

a.set(\freeze, 1);


////////////////////////////////////////////////////////////////////////////////
// (.) PLAITS
////////////////////////////////////////////////////////////////////////////////

(
{
	// var trigger = Dust.kr( LFNoise2.kr(0.1).range(0.1, 7) );
	// var trigger = Dust.kr( 4 );
	var trigger = Impulse.ar(8);
	var harmonics = SinOsc.kr(0.03, 0, 0.5, 0.5).range(0.0, 1.0);
	// var harmonics = 0.5;
	// var timbre = LFTri.kr(0.07, 0, 0.5, 0.5).range(0.0, 1.0);
	var timbre = MouseY.kr(0,1);
	// var morph = LFTri.kr(0.11, 0, 0.5, 0.5).squared;
    var morph = MouseX.kr(0,1);
	// var pitch = TIRand.kr(24, 48, trigger);
	// var pitch = TIRand.kr(24, 26, trigger);
	// var pitch = TWChoose.kr(trigger, [24, 28], [0.8, 0.2].normalizeSum);
	var pitch = 30;
	// var engine = TRand.kr(0, 15, trig: trigger).round;
	var engine = 3;
	// var sub = SinOsc.ar(pitch.midicps, 0, 0.1);
    var sub = SinOsc.ar(55, 0, 0.3);
	// var env = EnvGen.kr(
	// 	Env.perc, doneAction: Done.freeSelf
	// );

    var mi = MiPlaits.ar(
		pitch: pitch,
		engine: engine,
		harm: harmonics,
		timbre: timbre,
		morph: morph,
        trigger: trigger,
		decay: 0.4,
		lpg_colour: 0.2,
		mul: 0.5
	);
	// mi + (sub)
	mi
}.play
)


(   // some chords + trigger + level
{
    var harm = MouseY.kr(0,1);  // select chord
    var timbre = 0.5;
    var morph = 0.5;
    var trigger = Impulse.kr(8);
	// var lev = TRand.kr(trig: trigger);
	var lev = 0;
    var out = MiPlaits.ar(
		40,
		6,
		harm,
		timbre,
		morph,
		trigger,
		// level: lev.squared,
		level: lev,
        decay: 0.3, timb_mod: 0.4, mul: 0.5);
	// out[0] ! 2
    //out.sum ! 2
	out
}.play
)


