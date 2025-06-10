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

/* LEVEL
A non-zero value causes a trigger to
a) fire the internal decaying envelope generator
b) excites the physical and percussive models
c) strikes the internal low-pass gate (LPG) (unless the 'level' input is modulated (patched))
d) samples and holds the value of the 'model' input
*/
SynthDef(\plaits,
	{
		arg pitch=40, engine=6, harm=0.5, timbre=0.5, morph=0.5, speed=6, level=1.0, decay=0.5, fm_mod=0.0, timb_mod=0.0, morph_mod=0.0, lpg_colour=0.5, mul=0.5;

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
			trigger: Impulse.kr(speed),
			// level: level,
			decay: decay,
			fm_mod: fm_mod,
			// timb_mod: timb_mod,
			// morph_mod: morph_mod,
			lpg_colour: lpg_colour,
			mul: mul
		);
		Out.ar(0, sig);
		// Out.ar(0, sig[0] ! 2);
}).add;


~plaits = Synth(\plaits, []).run(false);
)

// Control /////////////////////////////////////////////////////////////////////

Synth(\plaits, [])

~plaits.run(true)

~plaits.run(false)

~plaits.set(\pitch, 40.99)

~plaits.set(\engine, 0)

~plaits.set(\trigger, 0)

~plaits.set(\speed, 2)

~plaits.set(\i_timbre, 0.9)



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