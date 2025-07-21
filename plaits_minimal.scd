// Minimal Plaits test - debugging NaN issues
(
// Increase buffer size to reduce late messages
s.options.blockSize = 128;
s.options.numBuffers = 2048;
s.options.memSize = 8192 * 16;

s.waitForBoot {

    // Simplified SynthDef with safety bounds
    SynthDef(\plaits_safe, {
        arg pitch=40, engine=6, harm=0.5, timbre=0.5, morph=0.5, decay=0.5, mul=0.5, gate=1;

        // Smooth parameter changes to reduce clicks
        var smooth_engine = Lag.kr(engine, 0.05);  // Longer smoothing for engines
        var smooth_harm = Lag.kr(harm, 0.005);
        var smooth_timbre = Lag.kr(timbre, 0.005);
        var smooth_morph = Lag.kr(morph, 0.005);

        var sig = MiPlaits.ar(
            pitch: pitch.clip(0, 127),
            engine: smooth_engine.clip(0, 15),
            harm: smooth_harm.clip(0, 1),
            timbre: smooth_timbre.clip(0, 1),
            morph: smooth_morph.clip(0, 1),
            trigger: gate,
            decay: decay.clip(0, 1),
            mul: mul.clip(0, 1)
        );

        var env = EnvGen.kr(Env.asr(0.005, 1, 0.02), gate, doneAction: Done.freeSelf);

        // Sanitize to kill denormals, infs, and NaNs
		sig = sig.sanitize;

        Out.ar(0, LeakDC.ar((sig * env).tanh));
    }).add;

    s.sync;

    // Test 1: Fixed engine (safe baseline)
    Pdef(\test_fixed, Pbind(
        \instrument, \plaits_safe,
        \dur, 0.1,
        \pitch, 40,
        \engine, 2,
		// \legato, 1,
		\legato, Prand([1,2,3,4,7,8,9], inf),
		// \gate, 1
    ));

    // Test 2: Simple engine switching
    Pdef(\test_engines, Pbind(
        \instrument, \plaits_safe,
        \dur, 0.2,
        \pitch, 40,
		\engine, Pseq([6, 9, 2, 0, 1, 3, 4], inf),  // Simple numeric engines
		// \engine, Prand((0..15), inf),  // Simple numeric engines
		\legato, 9.1,  // Overlap notes to avoid envelope retriggering
		// \gate, 1
    ));

    // Test 3: Your original pattern logic (risky)
	~e = 15;
    ~setEngine = { |seqExpr|
        var engines = (0..15);
        var output = engines.wrapAt(seqExpr.asString.interpret);
        output;
    };

    Pdef(\test_original, Pbind(
        \instrument, \plaits_safe,
        \dur, 0.1,
        \pitch, 40,
        \engine, Pfunc { ~setEngine.("~e") },  // Test the risky expression
		\legato, Prand([0.1, 1,2,3,4,7,8,9], inf),
        \gate, 1
    ));

    "Minimal Plaits patch loaded. Use: Pdef(\\test).play to start".postln;
}
)

~e = 2
~e = 3

// Test commands:
Pdef(\test_fixed).play;
Pdef(\test_fixed).stop;

Pdef(\test_engines).play;
Pdef(\test_engines).stop;

Pdef(\test_original).play;
Pdef(\test_original).stop;
// Pdef(\test).stop;