////////////////////////////////////////////////////////////////////////////////
// PLAITS DEMO
////////////////////////////////////////////////////////////////////////////////
(
~plaits = [
	(
		pitch: 49, harm: 0.48, timbre: 0.44, morph: 0.43,
		decay: 0.59, engine: 6, fm_mod: 0.0, lpg_colour: 0.5,
		timb_mod: 0.0, morph_mod: 0.0, mul: 0.5,
		speed: 1, dur: 0.5, pattern: nil,
		sequences: (
			timbre: Pseq([0.5], inf).asStream,
			decay: Pseq([0.4, 0.2, Pseq([0.6, 0.1, 0.8] / 6)] / 3, inf).asStream,
			morph: Pseq(0.7 ! 19 ++ 0.5, inf).asStream,
			harm: Pseq([0.5], inf).asStream,
			fm_mod: Pseq([0.5], inf).asStream,
			lpg_colour: Pseq([0.1, 0.2, 0.4, 1], inf).asStream,
			engine: Pseq([
				"~plaits[0].engine",
				Pwrand([2,11], [0.9, 0.1].normalizeSum),
				"~plaits[0].engine",
				"~plaits[0].engine", 
				Pwrand(["~plaits[0].engine", 2], [0.8, 0.2].normalizeSum),
				"~plaits[0].engine+2",
				"~plaits[0].engine",
				0,
			], inf).asStream,
			duration: (
				Pseq([
					Rest(1.0),
					Pwrand([0.5, Rest(0.5)], [0.9, 0.1].normalizeSum),
					Pwrand([1.0, Rest(1.0)], [0.2, 0.8].normalizeSum),
					Rest(0.5),
					1.5
				], inf) / Pseq(1.5 ! 15 ++ 1.5, inf)
			).asStream,
			percDuration: Prand([0.5, Rest(0.5), Rest(0.5), Rest(0.5)], inf).asStream,
			div: Pseq([1], inf).asStream
		)
	),
	(
		pitch: 51, harm: 0.19, timbre: 0.74, morph: 0.07,
		decay: 0.59, engine: 6, fm_mod: 0.0, lpg_colour: 0.5,
		timb_mod: 0.0, morph_mod: 0.0, mul: 0.3,
		speed: 1, dur: 0.5, pattern: nil,
		sequences: ()
	),
	(
		pitch: 45, harm: 0.3, timbre: 0.6, morph: 0.2,
		decay: 0.4, engine: 2, fm_mod: 0.1, lpg_colour: 0.3,
		timb_mod: 0.0, morph_mod: 0.0, mul: 0.7,
		speed: 1.2, dur: 0.5, pattern: nil,
		sequences: ()
	)
];
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

~setEngine = { |seqExpr, instanceIndex=0|
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
	var e = ~plaits[instanceIndex].engine;
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

// Create OSC listeners for all PLaits instances and parameters
~plaits.do { |instance, instanceIndex|
	var instanceNum = instanceIndex + 1; // Convert to 1-based for OSC paths

	// Special case: start/stop
	OSCdef.new(
		("plaitsStart" ++ instanceNum).asSymbol,
		{
			arg msg, time, addr, port;
			var value = msg[1];
			msg.postln;
			if (value == 1.0,
				{ x.play },
				{ x.stop }
			);
		},
		("/plaits/" ++ instanceNum ++ "/start").asString
	);

	// Generic parameter handling - OSC keys match data structure keys
	instance.keys.select({ |key| key != \pattern }).do { |paramKey|
		OSCdef.new(
			("plaits" ++ instanceNum ++ paramKey).asSymbol,
			{
				arg msg, time, addr, port;
				var value = msg[1];
				msg.round(0.001).postln;

				// Special handling for speed (affects global tempo clock)
				if (paramKey == 'speed') {
					~plaits[instanceIndex].speed = value;
					~tempoClock.tempo = (value.max(0.1))/60;
				} {
					// Generic parameter update
					~plaits[instanceIndex][paramKey] = value;
				};
			},
			("/plaits/" ++ instanceNum ++ "/" ++ paramKey).asString
		);
	};
};

// Synth Def ///////////////////////////////////////////////////////////////////
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

// Sequence ////////////////////////////////////////////////////////////////////
// (
~tempoClock = TempoClock.new(165/60);
~playCount = 0;
// Sequence streams now moved into ~plaits[0].sequences

// chooses synthesis engine (0 -- 15): 0:virtual_analog_engine, 1:waveshaping_engine, 2:fm_engine, 3:grain_engine, 4:additive_engine, 5:wavetable_engine, 6:chord_engine, 7:speech_engine, 8:swarm_engine, 9:noise_engine, 10:particle_engine, 11:string_engine, 12:modal_engine, 13:bass_drum_engine, 14:snare_drum_engine, 15:hi_hat_engine

// Global sequence variables moved to ~plaits[0].sequences
~durDiv = [4, 2, 4, 2];



x = Pdef(\plaitsSequence,
	Ppar([
		Pbind(
			\instrument, \plaits,
			// \pitch, Pfunc({ Scale.bhairav.degrees.copyRange(0, 2).choose.midiratio }),
			// \pitch, Pseq([40, 30], inf),
			// \pitch, Pseq(~scale, inf) + 60,
			\pitch, Pfunc { |event|
				// ["--->", ~state, ~plaits[0].engine, ~playCount].postln;

				~playCount = ~playCount + 1;

				if (~playCount % 16 == 0) {
					~state = ~states.next;
					// "Completed 16 steps".postln;
				};

				~plaits[0].dur = ~setDuration.(~plaits[0].sequences.duration.next, ~plaits[0].sequences.div.next, ~plaits[0].speed);

				~plaits[0].pitch ;
			},
			// \dur, 1,
			\dur, Pfunc { |event|
				// ~setDuration.(~durationSeq.next, ~divSeq.next, ~speed)
				~plaits[0].dur
			},
			// \dur, Pseq([0.1, Rest(0.4), 0.2]/[0.5, 0.5, 1, 0.25], inf),
			// \decay, Pseq([0.4, 0.2, Pseq([0.6, 0.1, 0.8] / 1.5)] / 1, inf),
			\decay, Pfunc { |event|
				~modulateBipolar.(~plaits[0].sequences.decay.next, ~plaits[0].decay)
			},
			// \harm, Pseq([0.5, 0.2, 0.1, 0.6]/1, inf),
			\harm, Pfunc { |event|
				~modulateBipolar.(~plaits[0].sequences.harm.next, ~plaits[0].harm)
			},
			\timbre, Pfunc { |event|
				~modulateBipolar.(~plaits[0].sequences.timbre.next, ~plaits[0].timbre)
			},
			// \morph, Pseq([0.5, Pseq([0.3, 1])]/2, inf),
			\morph, Pfunc { |event|
				~modulateBipolar.(~plaits[0].sequences.morph.next, ~plaits[0].morph)
			},
			\fm_mod, Pfunc { |event|
				~modulateBipolar.(~plaits[0].sequences.fm_mod.next, ~plaits[0].fm_mod)
			},
			// \lpg_colour, Pseq([0.1, 0.2, 0.4, 1], inf),
			\lpg_colour, Pfunc { |event|
				~modulateBipolar.(~plaits[0].sequences.lpg_colour.next, ~plaits[0].lpg_colour)
			},
			\timb_mod, ~plaits[0].timb_mod,
			\morph_mod, ~plaits[0].morph_mod,
			// \engine, Pseq([~e], inf),
			\engine, Pfunc { |event|
				~setEngine.(~plaits[0].sequences.engine.next)
			},
			\mul, ~plaits[0].mul,
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
				~plaits[0].dur
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

x.play;
x.stop;

