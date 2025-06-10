////////////////////////////////////////////////////////////////////////////////
// (2) SAMPLER
////////////////////////////////////////////////////////////////////////////////
(
SynthDef(\samplePlayer, {
    |out=0, bufnum=0, amp=1, rate=1, startPos=0, atk=0.01, rel=0.1, gate=1|

    var sig, env;

    env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction: 2);

    sig = PlayBuf.ar(
        numChannels: 1,
        bufnum: bufnum,
        rate: rate * BufRateScale.kr(bufnum),
		startPos: startPos,
        doneAction: 0
    );

    sig = sig * env * amp;
    Out.ar(out, sig);
}).add;

SynthDef(\panningSamplePlayer, {
    |out=0, bufnum=0, amp=1, rate=1, startPos=0, panDur=5,
     atk=0.01, rel=0.1, gate=1, volume=0.7|

    var sig, env, pan;

    // Pan from -1 to 1 over panDur
    pan = Line.kr(-1, 1, panDur);

    // Envelope
    env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction: 2);

    // Sample playback, gated by envelope
    sig = PlayBuf.ar(
        numChannels: 1,
        bufnum: bufnum,
        rate: rate * BufRateScale.kr(bufnum),
		startPos: startPos,
        doneAction: 0
    );

    sig = sig * env * amp * volume;
	sig = Pan2.ar(sig, pan);
	// Pan4.ar
    Out.ar(out, sig);
}).add;
)