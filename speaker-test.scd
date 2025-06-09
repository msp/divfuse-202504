////////////////////////////////////////////////////////////////////////////////
// SPEAKER TESTER
////////////////////////////////////////////////////////////////////////////////

(
Pbind(
    \instrument, \samplePlayer,
    \bufnum, Pseq(
		[
			~testSamples[0].bufnum,
			~testSamples[1].bufnum,
			~testSamples[2].bufnum,
			~testSamples[3].bufnum,
			~testSamples[4].bufnum,
			~testSamples[5].bufnum,
			// ~testSamples[6].bufnum,

	], inf),
    \dur, 1,
    \panDur, 1,
    \atk, 0.1,
    \rel, 0.1,
    \amp, 0.2,
	\out, Pseq(
		[
			~out1,
			~out2,
			~out3,
			~out4,
			~out5,
			~out6,
			// ~out7,

	], inf),
).play;
)