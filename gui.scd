(
var foo;

~synths.do { |synth, i|

	'---------------------------------------'.postln;
	'nodeID '.postln;
	synth[\sig].nodeID.postln;
	'xxxxxxx '.postln;
	'---------------------------------------'.postln;
};
)

(1.0).dbamp;

"1.0".asFloat.ampdb

(
var w = Window("Synths", Rect(20, 400, 440, Window.screenBounds.height/1.4 ));
w.front;
w.view.decorator = FlowLayout(w.view.bounds);
w.view.background = Color.grey.alpha = 0.1;
// w.view.background = Color.green.alpha = 0.1;


~synths.do { |synth, i|
	var startButton, posControl, levelControl, speedControl, cutoffControl, label;
	var balanceControl, ampControl;
	var id, cmdPeriodFunc;

	'---------------------------------------'.postln;
	'nodeID = '.post; synth[\sig].nodeID.postln;
	synth.postln;
	'---------------------------------------'.postln;

	// id = s.nextNodeID; // generate a note id.
	id = synth[\sig].nodeID;


	w.view.decorator.nextLine;
	// label = StaticText(w, Rect(w.bounds.extent.x.rand, w.bounds.extent.y.rand, 160, 16)
	label = StaticText(w, 400 @ 24);
	label.string = synth[\vals][\name].toUpper;
	label.stringColor = Color.white;
	label.align = \center;
	label.background=Color.grey.alpha = 0.6;
	label.font = Font("Monaco", 16, bold: true);

	w.view.decorator.nextLine;
	w.view.decorator.nextLine;
	w.view.decorator.nextLine;
	levelControl = EZSlider(w, 400 @ 24, "Level", \db,
		{|ez| s.sendMsg("/n_set", id, "level", ez.value.dbamp); }, synth[\vals][\level].ampdb);

	w.view.decorator.nextLine;
	cutoffControl = EZSlider(w, 400 @ 24, "Cutoff", ControlSpec(50, 20000, \exp),
	{|ez| s.sendMsg("/n_set", id, "cutoff", ez.value); }, synth[\vals][\cutoff]);

	w.view.decorator.nextLine;
	cutoffControl = EZSlider(w, 400 @ 24, "Res", ControlSpec(0.01, 1.0),
	{|ez| s.sendMsg("/n_set", id, "res", ez.value); }, synth[\vals][\res]);

	w.view.decorator.nextLine;
	posControl = EZSlider(w, 400 @ 24, "Pan Pos", ControlSpec(0.1, 4.0),
		{|ez| s.sendMsg("/n_set", id, "pos", ez.value); }, synth[\vals][\pos]);

	if (synth[\vals][\speed] > 0) {
		w.view.decorator.nextLine;
		speedControl = EZSlider(w, 400 @ 24, "Amp LFO", ControlSpec(0.1, 4.0),
			{|ez| s.sendMsg("/n_set", id, "speed", ez.value); }, synth[\vals][\speed]);
	};


	// add a button to start and stop the sound.
	w.view.decorator.nextLine;
	w.view.decorator.nextLine;
	w.view.decorator.nextLine;
	startButton = Button(w, 75 @ 24);
	startButton.states = [
		["Start", Color.black, Color.green],
		["Stop", Color.white, Color.red]
	];
	startButton.action = {|view|
		if (view.value == 1) {
			synth[\sig].run(true);
			// s.sendMsg("/n_set", id, "level", synth[\vals][\level].dbamp);
			// start sound
			/*			s.sendMsg("/s_new", "window-test", id, 0, 0,
			"note", noteControl.value,
			"fc", cutoffControl.value,
			"rq", resonControl.value,
			"bal", balanceControl.value,
			"amp", ampControl.value.dbamp);*/
		};
		if (view.value == 0) {
			// set gate to zero to cause envelope to release
			// s.sendMsg("/n_set", id, "level", 0);
			synth[\sig].run(false);
		};
	};

	w.view.decorator.nextLine;
	w.view.decorator.nextLine;
	w.view.decorator.nextLine;
	w.view.decorator.nextLine;
	w.view.decorator.nextLine;

	// set start button to zero upon a cmd-period
	cmdPeriodFunc = { startButton.value = 0; };
	CmdPeriod.add(cmdPeriodFunc);

	// stop the sound when window closes and remove cmdPeriodFunc.
	w.onClose = {
		// s.sendMsg("/n_free", id);
		CmdPeriod.remove(cmdPeriodFunc);
	};

};

)