(
OSCdef.freeAll;

OSCdef.new(
	\s1Start,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		[msg, time, addr, port].postln;
		[msg[0], value].postln;
		if (value == 1.0,
			{ ~synths[0][\sig].run(true) },
			{ ~synths[0][\sig].run(false) }
		);

	}
	, '/synth1/start'
);

OSCdef.new(
	\s1Level,
	{
		arg msg, time, addr, port;
		var value = msg[1];
		[msg[0], value].postln;
		~synths[0][\sig].set(\level, value);
	}
	, '/synth1/level'
);

OSCdef.new(
	\s1Pos,
	{
		arg msg, time, addr, port;
		var value = msg[1].linlin(0.0, 1.0, 0.0, 4.0);
		[msg[0], value].postln;
		~synths[0][\sig].set(\pos, value);
	}
	, '/synth1/pos'
);

OSCdef.new(
	\s1Width,
	{
		arg msg, time, addr, port;
		var value = msg[1].linlin(0.0, 1.0, 0.0, 4.0);
		[msg[0], value].postln;
		~synths[0][\sig].set(\width, value);
	}
	, '/synth1/width'
);

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