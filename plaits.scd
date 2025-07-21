////////////////////////////////////////////////////////////////////////////////
// PLAITS DEMO
////////////////////////////////////////////////////////////////////////////////
(
// s.boot;

// ~pitch = 51;
// ~harm = 0.19;
// ~timbre = 0.74;
// ~morph = 0.07;
~pitch = 49;
~harm = 0.48;
~timbre = 0.44;
~morph = 0.43;
~decay = 0.59;
~speed = 1;
~fmMod = 0.0;
~lpgColour = 0.5;
// The dominant Plaits engine
~e = 6;
~dur = 0.5;
~engines = (0..15);
~states = Pseq([\a, \b, \c, \d], inf).asStream;
~state = ~states.next;

~modulateBipolar = { |seqValue, uiValue|
	var output = 0.5;

    uiValue = uiValue.clip(0, 1);  // Optional safety clamp

	if (uiValue <= 0.5) {
        output = seqValue * (uiValue * 2)
    } {
        output = seqValue + (((uiValue - 0.5) * 2) * (1 - seqValue))
    };

	// ['modulateBipolar:', seqValue, uiValue.round(0.0001), output.round(0.0001)].postln;

	output;
};

~setDuration = { |seqValue, divSeqValue, uiValue|
	var output = 1;
	uiValue = uiValue.clip(0.8, 1.4);
	divSeqValue = divSeqValue.max(0.001);
	uiValue = uiValue.max(0.001);
	output = seqValue / divSeqValue / uiValue;
	output = output.clip(0.001, 100);

	// ['~setDuration:', uiValue.round(0.0001), output.round(0.0001)].postln;

	output;
};

~setEngine = { |seqExpr|
	// var output = switch(~state,
	// 	\a, { 11 },
	// 	\b, { 15 },
	// 	\c, { 2 },
	// 	\d, { 0 },
	// 	{ 0 }
	// );
	// var output = 11;
	// get or in the case of an expression, interpret the engine index to use
	// ensuring we wrap for negative values
	var output = ~engines.wrapAt(seqExpr.asString.interpret);

	// ['~setEngine:', seqExpr, output].postln;

	output;
};


s.waitForBoot {}
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
		// if (value == 1.0,
		// 	{ ~plaits.run(true) },
		// 	{ ~plaits.run(false) }
		// );
		if (value == 1.0,
			{ x.play },
			{ x.stop }
		);

	}
	, '/plaits1/start'
);

OSCdef.new(
	\plaitsFrequency,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.round(0.001).postln;
		~pitch = value;
		// ~plaits.set(\pitch, value);
	}
	, '/plaits1/frequency'
);

OSCdef.new(
	\plaitsTestHarm,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.round(0.001).postln;
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
		msg.round(0.001).postln;
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
		msg.round(0.001).postln;
		~morph = value;
		// ~plaits.set(\pitch, value);
	}
	, '/plaits1/morph'
);

OSCdef.new(
	\plaitsTestDecay,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.round(0.001).postln;
		~decay = value;
	}
	, '/plaits1/decay'
);

OSCdef.new(
	\plaitsTestEngine,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.round(0.001).postln;
		~e = value;
	}
	, '/plaits1/engine'
);

OSCdef.new(
	\plaitsTestSpeed,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.round(0.001).postln;
		// ~speed = value;
		~tempoClock.tempo = (value.max(0.1))/60;
	}
	, '/plaits1/speed'
);

OSCdef.new(
	\plaitsTestFmMod,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.round(0.001).postln;
		~fmMod = value;
	}
	, '/plaits1/fm_mod'
);

OSCdef.new(
	\plaitsTestLpgColour,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		msg.round(0.001).postln;
		~lpgColour = value;
	}
	, '/plaits1/lpg_colour'
);


["XXengine", "XXXharm", "XXtimbre", "XXmorph", "XXdecay", "XXspeed", "XXfm_mod", "timb_mod", "morph_mod"].do {|key|
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
		arg out=0, pitch=40, engine=6, harm=0.5, timbre=0.5, morph=0.5, speed=6, level=1.0, decay=0.5, fm_mod=0.0, timb_mod=0.0, morph_mod=0.0, lpg_colour=0.5, mul=0.5, gate=1.0, drywet=0.25, reverb_time=0.3;

		/*
		var trig = Select.kr(trigger, [
			0.0,
			Impulse.kr(speed)
		]);
		*/

		// var timb_mod = MouseY.kr(-1,1);

		var l_timbre = (timbre + LFTri.kr(freq: speed/100, mul: timb_mod)).clip(0, 1);
		var l_morph = (morph + LFTri.kr(freq: speed/100, mul: morph_mod)).clip(0, 1);

		var sig = MiPlaits.ar(
			pitch: pitch.clip(0, 127),
			engine: engine.clip(0, 15),
			harm: harm.clip(0, 1),
			timbre: l_timbre,
			morph: l_morph,
			trigger: gate,
			// trigger: Impulse.kr(speed),
			// level: level,
			decay: decay.clip(0, 1),
			fm_mod: fm_mod.clip(-1, 1),
			// timb_mod: timb_mod,
			// morph_mod: morph_mod,
			lpg_colour: lpg_colour.clip(0, 1),
			mul: mul
		);

		var env = Linen.kr(gate, doneAction: Done.freeSelf);

		// Sanitize to kill denormals, infs, and NaNs - crucial for engine switching!
		sig = sig.sanitize;

		sig = MiVerb.ar(
			(sig * env).tanh,
			time: reverb_time.clip(0, 1),
			drywet: drywet.clip(0, 1),
			damp: 0.8,
			hp: 0.7,
			freeze: TRand.kr(-1, 1, Dust.kr(0.7)),
			// freeze: 1,
			diff: 0.625,
			mul: 1.1,
			add: 0.0
		);

		Out.ar(out, LeakDC.ar(sig.tanh));
		// Out.ar(0, sig[0] ! 2);
}).add;

// s.sync;


// Sequence ////////////////////////////////////////////////////////////////////
// (
~tempoClock = TempoClock.new(165/60);
~playCount = 0;
~timbreSeq = Pseq([0.5], inf).asStream;
// ~timbreSeq = Pseq([0.6, 0.5, 0.95], inf).asStream;
// ~decaySeq = Pseq([0.5], inf).asStream;
~decaySeq = Pseq([0.4, 0.2, Pseq([0.6, 0.1, 0.8] / 6)] / 3, inf).asStream;
// ~morphSeq = Pseq([0.5], inf).asStream;
~morphSeq = Pseq(0.7 ! 19 ++ 0.5, inf).asStream;
~harmSeq = Pseq([0.5], inf).asStream;
// ~harmSeq = Pseq([0.5, 0.2, 0.1, 0.6]/1, inf).asStream;
~fmModSeq = Pseq([0.5], inf).asStream;
~lpgColourSeq = Pseq([0.1, 0.2, 0.4, 1], inf);
// ~lpgColourSeq = Pseq([0.5], inf);

// chooses synthesis engine (0 -- 15): 0:virtual_analog_engine, 1:waveshaping_engine, 2:fm_engine, 3:grain_engine, 4:additive_engine, 5:wavetable_engine, 6:chord_engine, 7:speech_engine, 8:swarm_engine, 9:noise_engine, 10:particle_engine, 11:string_engine, 12:modal_engine, 13:bass_drum_engine, 14:snare_drum_engine, 15:hi_hat_engine

// ~engineSeq = Pseq(["~e+2"], inf).asStream;
// ~engineSeq = Pseq([11], inf).asStream;

~engineSeq = Pseq([
	// Prand([0,1]),
	"~e",
	Pwrand([2,11], [0.9, 0.1].normalizeSum),
	"~e",
	"~e",
	Pwrand(["~e", 2], [0.8, 0.2].normalizeSum),
	"~e+2",
	"~e",
	0,
], inf).asStream;

// ~durationSeq = Prand([0.5, Rest(1.0), 0.5]/1.5, inf).asStream;
~durationSeq = (
	Pseq(
		[
			Rest(1.0),
			// 0.5,
			Pwrand([0.5, Rest(0.5)], [0.9, 0.1].normalizeSum),
			// Rest(1.0),
			Pwrand([1.0, Rest(1.0)], [0.2, 0.8].normalizeSum),
			Rest(0.5),
			// Pwrand([1.5, Rest(1.5)], [0.8, 0.2].normalizeSum),
			1.5
	], inf)
	/
	Pseq(1.5 ! 15 ++ 1.5, inf)
	// Pwrand([0.75, 1.5, 3.0], [0.3, 0.5, 0.1].normalizeSum, inf)
).asStream;
~percDurationSeq = Prand([0.5, Rest(0.5), Rest(0.5), Rest(0.5)], inf).asStream;
// ~divSeq = Pseq([4, 2, 4, 2], inf).asStream;
~divSeq = Pseq([1], inf).asStream;
~durDiv = [4, 2, 4, 2];



x = Pdef(\plaitsSequence,
	Ppar([
		Pbind(
			\instrument, \plaits,
			// \pitch, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
			// \pitch, Pseq([40, 30], inf),
			// \pitch, Pseq(~scale, inf) + 60,
			\pitch, Pfunc { |event|
				// ["--->", ~state, ~e, ~playCount].postln;

				~playCount = ~playCount + 1;

				if (~playCount % 16 == 0) {
					~state = ~states.next;
					// "Completed 16 steps".postln;
				};

				~dur = ~setDuration.(~durationSeq.next, ~divSeq.next, ~speed);

				~pitch ;
			},
			// \dur, 1,
			\dur, Pfunc { |event|
				// ~setDuration.(~durationSeq.next, ~divSeq.next, ~speed)
				~dur
			},
			// \dur, Pseq([0.1, Rest(0.4), 0.2]/[0.5, 0.5, 1, 0.25], inf),
			// \decay, Pseq([0.4, 0.2, Pseq([0.6, 0.1, 0.8] / 1.5)] / 1, inf),
			\decay, Pfunc { |event|
				~modulateBipolar.(~decaySeq.next, ~decay)
			},
			// \harm, Pseq([0.5, 0.2, 0.1, 0.6]/1, inf),
			\harm, Pfunc { |event|
				~modulateBipolar.(~harmSeq.next, ~harm)
			},
			\timbre, Pfunc { |event|
				~modulateBipolar.(~timbreSeq.next, ~timbre)
			},
			// \morph, Pseq([0.5, Pseq([0.3, 1])]/2, inf),
			\morph, Pfunc { |event|
				~modulateBipolar.(~morphSeq.next, ~morph)
			},
			\fm_mod, Pfunc { |event|
				~modulateBipolar.(~fmModSeq.next, ~fmMod)
			},
			// \lpg_colour, Pseq([0.1, 0.2, 0.4, 1], inf),
			\lpg_colour, Pfunc { |event|
				~modulateBipolar.(~lpgColourSeq.next, ~lpgColour)
			},
			// \engine, Pseq([~e], inf),
			\engine, Pfunc { |event|
				~setEngine.(~engineSeq.next)
			},
			\mul, 0.0,
			\out, Pseq(
				[
					0
					// 0,1,2,3,4,5
			], inf),
		),
		Pbind(
			\instrument, \plaits,
			// \dur, 0.5,
			// \dur, Prand([0.5, Rest(0.5), Rest(0.5), Rest(0.5)]/~durDiv, inf),
			\dur, Pfunc { |event|
				// ~setDuration.(~percDurationSeq.next, ~divSeq.next, ~speed)
				~dur
			},
			\pitch, 36,
			\harm, 0.55,
			\timbre, 0.8,
			// \morph, 0.5,
			\morph, Pseq(
				[0.4, 0.1, 0.2, 0.1, 0.4, 0.1, 0.1, 0.05, Pseq([0.5, 0.3, 0.1])
			] * 0.5, inf),
			\engine, Pseq([13,13,13,13, 13,13,13,13], inf),
			// \decay, 0.2,
			\mul, 0.6,
			\out, 0
			// \out, Pseq([0,1,2,3,4,5], inf)
		),
		// hats / claps ////////////////////////////////////
		Pbind(
			\instrument, \plaits,
			\dur, Pseq([
				Prand([2, Rest(2)]),
				2,
				Rest(2),
				Rest(2),
				Pwrand([1.0, Rest(1)], [0.8, 0.2].normalizeSum)
			]/3, inf),
			\pitch, Pseq([45, 45, 45, 45, 30], inf),
			\harm, Pseq([0.1, 0.6, 0.7, 0.8, 0.4], inf),
			\timbre, Pseq([0.9, 0.6, 0.7, 0.8, 0.2], inf),
			\morph, Pseq([0.1, 0.01, 0.1, 0.1, 0.15], inf),
			\decay, 0.3, //only effects first sound!
			\engine, Pseq([
				// Prand([9, 10, 15]), //9 is the accent
				9,
				15, 15,
				Prand([14, 15]),
				Pwrand([14, 10], [0.8, 0.2].normalizeSum),
			], inf),
			\mul, Pseq([1.05, 0.45, 0.45, 0.45, 1.2] -0.3, inf),
			\out, 0
		),
		// More hats! /////////////////////////////////////////
		Pbind(
			\instrument, \plaits,
			\dur, Pseq([
				Rest(1),
				Prand([Rest(1), 1, 1, 1]),
				1
			], inf) / Pseq([3, 3, 3, 1.5], inf),
			// \dur, Pseq([Rest(1/1.5), 1/1.5 ] / 3, inf),
			\pitch, Pseq([65, 45, 55, 45, 30], inf),
			\harm, Pseq([0.1, 0.6, 0.7, 0.8, 0.4], inf),
			\timbre, Pseq([0.9, 0.6, 0.7, 0.8, 0.2], inf),
			\morph, Pseq([0.1, 0.01, 0.1, 0.1, 0.15] * 2, inf),
			\decay, 0.05,
			\engine, Pseq([
				15
			], inf),
			\mul, Pseq([0.01], inf),
			\out, 0
		),
		// The one /////////////////////////////////////////
		Pbind(
			\instrument, \plaits,
			// \dur, Pseq([Rest(1/1.5), 1/1.5 ] / 3, inf),
			\dur, Pseq([2.5, Rest(0.5), Rest(1.5)]/ (1.5/16), inf),
			\pitch, Pseq([[88, 95, 102]] - 30, inf),
			\harm, Pseq([0.2], inf),
			\timbre, Pseq([0.2], inf),
			\morph, Pseq([0.5] * 2, inf),
			\decay, 1.0,
			\engine, Pseq([8, 9], inf),
			\reverb_time, 1.1,
			\drywet, 0.75,
			\mul, Pseq([0.1, 0.3], inf),
			\out, 0
		)
	])
	).play(~tempoClock);
// ).play();
// )
)

// engine
// chooses synthesis engine (0 -- 15): 0:virtual_analog_engine, 1:waveshaping_engine, 2:fm_engine, 3:grain_engine, 4:additive_engine, 5:wavetable_engine, 6:chord_engine, 7:speech_engine, 8:swarm_engine, 9:noise_engine, 10:particle_engine, 11:string_engine, 12:modal_engine, 13:bass_drum_engine, 14:snare_drum_engine, 15:hi_hat_engine

x.play;
x.stop;

// Pseq([0.2, 0.5, 0.5]/2, inf)

Quarks.gui

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