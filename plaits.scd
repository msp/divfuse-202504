////////////////////////////////////////////////////////////////////////////////
// PLAITS DEMO
////////////////////////////////////////////////////////////////////////////////
(
s.boot;
)

(
// OSC Listeners ///////////////////////////////////////////////////////////////
OSCdef.freeAll;

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


["engine", "harm", "timbre", "morph", "decay", "speed", "fm_mod", "timb_mod", "morph_mod"].do {|key|
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
SynthDef(\plaits,
	{
		arg pitch=40, engine=6, harm=0.1, timbre=0.5, morph=0.5, speed=1, level=1.0, decay=0.5, fm_mod=0.0, timb_mod=0.0, morph_mod=0.0, lpg_colour=0.5, mul=0.5;

		/*
		var trig = Select.kr(trigger, [
			0.0,
			Impulse.kr(speed)
		]);
		*/

		var sig = MiPlaits.ar(
			pitch: pitch,
			engine: engine,
			harm: harm,
			timbre: timbre,
			morph: morph,
			trigger: Impulse.kr(speed),
			// level: level,
			decay: decay,
			timb_mod: timb_mod,
			morph_mod: morph_mod,
			lpg_colour: lpg_colour,
			mul: mul
		);
		Out.ar(0, sig);
}).add;


~plaits = Synth(\plaits, []).run(false)
)

// Control /////////////////////////////////////////////////////////////////////


~plaits.run(true)

~plaits.run(false)

~plaits.set(\pitch, 40.99)

~plaits.set(\engine, 0)

~plaits.set(\trigger, 0)

~plaits.set(\speed, 2)