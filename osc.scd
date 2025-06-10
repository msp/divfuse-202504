(
OSCdef.freeAll;

////////////////////////////////////////////////////////////////////////////////
// (.) SAWS
////////////////////////////////////////////////////////////////////////////////
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

	["level", "pos", "width", "speed"].do {|key|
		var defName = (synthName ++ key ).asSymbol;
		var oscPattern = "/" ++ synthName ++ "/" ++ key;

		[defName, oscPattern].postln;

		OSCdef.new(
			defName,
			{
				arg msg, time, addr, port;
				var value = msg[1];
				[msg[0], value, key].postln;
				synth[\sig].set(key.asSymbol, value);
			}
			, oscPattern
		);
	};
};

////////////////////////////////////////////////////////////////////////////////
// (.) VOX
////////////////////////////////////////////////////////////////////////////////

(1..14).do { |i|
	var action = "start";
	var defName = ("vox" ++ i ++ action ).asSymbol;
	var oscPattern = "/vox/" ++ i ++ "/" ++ action;
	var pdefIndex = i - 1;

	[i, defName, oscPattern].postln;

	OSCdef.new(
		defName,
		{
			arg msg, time, addr, port;
			var value = msg[1];
			// [msg, time, addr, port].postln;
			[msg[0], value].postln;
			if (value == 1.0,
				{ Pdef(~pdefNames[pdefIndex]).play },
				{ Pdef(~pdefNames[pdefIndex]).stop }
			);

		}
		,oscPattern
	);

	action = "volume";
	defName = ("vox" ++ i ++ action ).asSymbol;
	oscPattern = "/vox/" ++ i ++ "/" ++ action;

	[i, defName, oscPattern].postln;

	OSCdef.new(
		defName,
		{
			arg msg, time, addr, port;
			var value = msg[1];
			[msg[0], value].postln;

			Pdef(~pdefNames[pdefIndex]).set(\volume, value);
		}
		,oscPattern
	);

};

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

/*OSCdef.all.do { |o|
	o.postln;
}*/


)