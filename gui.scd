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
var colCount = 0;
var rowCount = 0;

~synthWindows.do {|w|
	w.close;
};

~synthWindows = [];

~synths.do { |synth, i|
	var startButton, posControl, levelControl, speedControl, cutoffControl, label;
	var balanceControl, ampControl;
	var id, cmdPeriodFunc;
	// Window.screenBounds.height/1.4
	var width = 440;
	var height = 250;
	var left = 0;
	var top = Window.screenBounds.height;
	var w;

	if (i % 3 == 0) {
		if (i > 0) {
			colCount = colCount + 1;
			rowCount = 0
		};
	};

	if (i % 3 >  0) {
		rowCount = rowCount + 1;
	};

	left = colCount * width;
	top = Window.screenBounds.height - ((rowCount * height) + 75);

	w = Window(synth[\vals][\name].toUpper, Rect(left, top, width, height));
	w.front;
	w.view.decorator = FlowLayout(w.view.bounds);
	w.view.background = Color.grey.alpha = 0.1;

	'---------------------------------------'.postln;
	'nodeID = '.post; synth[\sig].nodeID.postln;
	synth.postln;
	// [(i % 3), colCount, rowCount, top, left].postln;
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

	w.view.decorator.nextLine;
	posControl = EZSlider(w, 400 @ 24, "Width", ControlSpec(1, 4),
		{|ez| s.sendMsg("/n_set", id, "width", ez.value); }, synth[\vals][\width]);

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

	~synthWindows = ~synthWindows.add(w);

};

)

