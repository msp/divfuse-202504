(
OSCdef.freeAll;

~synths.do { arg synth, i;
	var action = "start";
	var synthName = synth[\vals][\name];
	var defName = (synthName ++ action ).asSymbol;
	var oscPattern = "/" ++ synthName ++ "/" ++ action;

	// defName.postln;
	// [i, synth].postln;
	[defName, oscPattern].postln;
	OSCdef.new(
		defName,
		{
			arg msg, time, addr, port;
			var value = msg[1];
			// [msg, time, addr, port].postln;
			[msg[0], value].postln;
			if (value == 1.0,
				{ synth[\sig].run(true) },
				{ synth[\sig].run(false) }
			);

		}
		,oscPattern
	);

	action = "level";
	defName = (synthName ++ action ).asSymbol;
	oscPattern = "/" ++ synthName ++ "/" ++ action;
	[defName, oscPattern].postln;
	OSCdef.new(
		defName,
		{
			arg msg, time, addr, port;
			var value = msg[1];
			[msg[0], value, action].postln;
			synth[\sig].set(action.asSymbol, value);
		}
		,oscPattern
	);

	action = "pos";
	defName = (synthName ++ action ).asSymbol;
	oscPattern = "/" ++ synthName ++ "/" ++ action;
	[defName, oscPattern].postln;
	OSCdef.new(
		defName,
		{
			arg msg, time, addr, port;
			// var value = msg[1].linlin(0.0, 1.0, 0.0, 4.0);
			var value = msg[1];
			[msg[0], value, action].postln;
			synth[\sig].set(action.asSymbol, value);
		}
		,oscPattern
	);

	action = "width";
	defName = (synthName ++ action ).asSymbol;
	oscPattern = "/" ++ synthName ++ "/" ++ action;
	[defName, oscPattern].postln;
	OSCdef.new(
		defName,
		{
			arg msg, time, addr, port;
			// var value = msg[1].linlin(0.0, 1.0, 0.0, 4.0);
			var value = msg[1];
			[msg[0], value].postln;
			synth[\sig].set(action.asSymbol, value);
		}
		,oscPattern
	);

};
// ["engine", "harm", "timbre", "morph", "decay", "speed", "fm_mod", "timb_mod", "morph_mod"].do {|key|
// 	var name = ("plaits" ++ key).asSymbol;
// 	("Creating OSCdef: "++ name).postln;
//
// 	OSCdef.new(
// 		name,
// 		{
// 			arg msg, time, addr, port;
// 			var value = msg[1];
// 			msg.postln;
// 			~plaits.set(key.asSymbol, value);
// 		}
// 		, "/plaits1/" ++ key
// 	);
// };




////////////////////////////////////////////////////////////////////////////////
// (.) PLAITS
////////////////////////////////////////////////////////////////////////////////


OSCdef.new(
	\plaitsFrequency,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		[msg[0], value].postln;
		a.set(\width, value);
	}
	, '/plaits1/frequency'
);

OSCdef.new(
	\plaitsHarmonics,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		[msg[0], value].postln;
		a.set(\harm, value);
	}
	, '/plaits1/harmonics'
);

OSCdef.new(
	\plaitsTimbre,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		[msg[0], value].postln;
		a.set(\timbre, value);
	}
	, '/plaits1/timbre'
);

OSCdef.new(
	\plaitsMorph,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		[msg[0], value].postln;
		a.set(\morph, value);
	}
	, '/plaits1/morph'
);


OSCdef.new(
	\plaitsDecay,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		[msg[0], value].postln;
		a.set(\decay, value);
	}
	, '/plaits1/decay'
);


)