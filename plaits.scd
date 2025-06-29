////////////////////////////////////////////////////////////////////////////////
// PLAITS DEMO
////////////////////////////////////////////////////////////////////////////////
(
s.boot;
)

(
// OSC Listeners ///////////////////////////////////////////////////////////////
OSCdef.freeAll;
s.defaultGroup.freeAll;

OSCdef.new(
	\plaitsStart,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.postln;
		if (value == 1.0,
			{ ~plaits.run(true) },
			{ ~plaits.run(false) }
		);

	}
	, '/plaits1/start'
);

OSCdef.new(
	\plaitsFrequency,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.postln;
		~plaits.set(\pitch, value);
	}
	, '/plaits1/frequency'
);

OSCdef.new(
	\plaitsTestHarm,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.postln;
		~harm = value;
		// ~plaits.set(\pitch, value);
	}
	, '/plaits1/harm'
);

OSCdef.new(
	\plaitsTestTimbre,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.postln;
		~timbre = value;
		// ~plaits.set(\pitch, value);
	}
	, '/plaits1/timbre'
);

OSCdef.new(
	\plaitsTestMorph,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.postln;
		~morph = value;
		// ~plaits.set(\pitch, value);
	}
	, '/plaits1/morph'
);


["engine", "XXXharm", "XXtimbre", "XXmorph", "decay", "speed", "fm_mod", "timb_mod", "morph_mod"].do {|key|
	var name = ("plaits" ++ key).asSymbol;
	("Creating OSCdef: "++ name).postln;

	OSCdef.new(
		name,
		{
			arg msg, time, addr, port;
			var value = msg[1];
			msg.postln;
			~plaits.set(key.asSymbol, value);
		}
		, "/plaits1/" ++ key
	);
};

// Synth Def ///////////////////////////////////////////////////////////////////

/* LEVEL
A non-zero value causes a trigger to
a) fire the internal decaying envelope generator
b) excites the physical and percussive models
c) strikes the internal low-pass gate (LPG) (unless the 'level' input is modulated (patched))
d) samples and holds the value of the 'model' input
*/
SynthDef(\plaits,
	{
		arg out=0, pitch=40, engine=6, harm=0.5, timbre=0.5, morph=0.5, speed=6, level=1.0, decay=0.5, fm_mod=0.0, timb_mod=0.0, morph_mod=0.0, lpg_colour=0.5, mul=0.5, gate=1.0;

		/*
		var trig = Select.kr(trigger, [
			0.0,
			Impulse.kr(speed)
		]);
		*/

		// var timb_mod = MouseY.kr(-1,1);

		var l_timbre = timbre + LFTri.kr(freq: speed/100, mul: timb_mod);
		var l_morph = morph + LFTri.kr(freq: speed/100, mul: morph_mod);

		var sig = MiPlaits.ar(
			pitch: pitch,
			engine: engine,
			harm: harm,
			timbre: l_timbre,
			morph: l_morph,
			trigger: gate,
			// trigger: Impulse.kr(speed),
			// level: level,
			decay: decay,
			fm_mod: fm_mod,
			// timb_mod: timb_mod,
			// morph_mod: morph_mod,
			lpg_colour: lpg_colour,
			mul: mul
		);

		var env = Linen.kr(gate, doneAction: Done.freeSelf);

		Out.ar(out, sig * env);
		// Out.ar(0, sig[0] ! 2);
}).add;

// s.sync;

// ~plaits = Synth(\plaits, []).run(false);
)

// Control /////////////////////////////////////////////////////////////////////

~plaits = Synth(\plaits, [])

~plaits.run(true)

~plaits.run(false)

~plaits.set(\pitch, 40.99)

~plaits.set(\engine, 2)

~plaits.set(\trigger, 0)
~plaits.set(\trigger, 1)

~plaits.set(\speed, 2)

~plaits.set(\i_timbre, 0.9)

Scale.bhairav.degrees.copyRange(0, 2).midicps

~scale = Scale.bhairav.degrees.copyRange(0, 2);

~harm = 0.5;

// Sequence ////////////////////////////////////////////////////////////////////
(
// ~pitch = 23;
// ~harm = 0.5;
// ~timbre = 0.5;
// ~morph = 0.5;

x = Pdef(\plaitsSequence,
	Ppar([
		Pbind(
			\instrument, \plaits,
			// \pitch, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
			// \pitch, Pseq([40, 30], inf),
			// \pitch, Pseq(~scale, inf) + 60,
			\pitch, Pfunc { |event| ~pitch },

			// \dur, Prand([1, 0.3, 0.2, 0.5]/3, inf),
			// \dur, Pseq([0.2, 0.5, 0.5]/2, inf),
			\dur, Pseq([
				Pseq([0.2, 0.4, 0.8]),
				0.2,
				0.2,
				0.2,
				0.2,
				0.2,
				Pseq([0.8, 0.4, 0.2]),
				0.2,
				0.2
			] / [2, 2, 2, 2, 2, 1], inf),
			// \dur, Pseq(
			// 	[
			// 		1,
			// 		0.3,
			// 		Pseq([0.1, 0.2, 0.5]),
			// 		0.5
			// ] / 3, inf),
			// \decay, Pseq([0.4, 0.2, Pseq([0.6, 0.1, 0.8])], inf),
			// \harm, Pseq([0.5, 0.2, 0.1, 0.6], inf),
			\harm, Pfunc { |event| ~harm },
			\timbre, Pfunc { |event| ~timbre },
			// \timbre, Pseq([0.5, Pseq([0.6, 0.5, 0.95])], inf),
			// \morph, Pseq([0.5, Pseq([0.3, 1])], inf),
			\morph, Pfunc { |event| ~morph },
			\lpg_colour, Pseq([0.1, 0.2, 0.4, 1], inf),
			\engine, Pseq([
				Prand([0,1]),
				Prand([2,11]),
				// 3,
				Pseq([6, 6, 6, 6, 6, 6, 12,
					// 5
					Pwrand([5, 6, 7, 11], [1, 1, 0.3, 1].normalizeSum)
				]
				),

			], inf),
			// \panDur, 1,
			// \atk, 0.1,
			// \rel, 0.1,
			// \amp, 0.2,
			\out, Pseq(
				[
					// 0
					0,1,2,3,4,5
					// 3
					// ~out1_2,
					// ~out3_4,
					// ~out1_2,
					// ~out5_6,
					// ~out2,
					// ~out3,
					// ~out4,

			], inf),
		),
		Pbind(
			\instrument, \plaits,
			// \dur, 0.2,
			\dur, Pseq([
				Pseq([0.2, 0.4, Rest(0.8)]),
				0.2,
				Rest(0.2),
				0.2,
				Rest(0.2),
				0.2,
				Pseq([0.8, 0.4, 0.2]),
				0.2,
				0.2
			] / [2, 2, 2, 2, 2, 1], inf),
			\pitch, 35,
			\harm, 0.95,
			\timbre, 0.3,
			\morph, Pseq([0.3, 0.1, 0.1, 0.1, 0.4, 0.1, 0.1, 0.1, Pseq([0.5, 0.3, 0.1])], inf),
			\engine, Pseq([13,13,13,13,13,13,13,13,14], inf),
			// \engine, 14,
			// \decay, 0.2,
			\mul, 0.4,
			// \out, 0
			\out, Pseq([0,1,2,3,4,5], inf)
		)
	])
).play;
)

// engine
// chooses synthesis engine (0 -- 15): 0:virtual_analog_engine, 1:waveshaping_engine, 2:fm_engine, 3:grain_engine, 4:additive_engine, 5:wavetable_engine, 6:chord_engine, 7:speech_engine, 8:swarm_engine, 9:noise_engine, 10:particle_engine, 11:string_engine, 12:modal_engine, 13:bass_drum_engine, 14:snare_drum_engine, 15:hi_hat_engine

x.stop;

// Pseq([0.2, 0.5, 0.5]/2, inf)



// Help patch /////////////////////////////////////////////////////////////////////

(
{
    var harm = 0.5;  // chord
    var timbre = 0.9;
    var morph = 0.5;
	// var timb_mod = MouseY.kr(-1,1);
	var timb_mod = LFTri.kr(
		freq: 0.2,
		iphase: 3
	);
    var trigger = Impulse.kr(6);
    var out = MiPlaits.ar(40, 6, harm, timbre, morph, trigger,
        decay: 0.5, timb_mod: timb_mod, mul: 0.5);
	// out[0] ! 2
	Out.ar(0, out[0] ! 2);
}.play
)