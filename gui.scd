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



(
~synths.do { |synth, i|
	var w, startButton, posControl, levelControl, speedControl;
	var balanceControl, ampControl;
	var id, cmdPeriodFunc;


	'---------------------------------------'.postln;
	'nodeID = '.post; synth[\sig].nodeID.postln;
	synth.postln;
	'---------------------------------------'.postln;

	// id = s.nextNodeID; // generate a note id.
	id = synth[\sig].nodeID;

	// make the window
	w = Window(synth[\vals][\name], Rect(20, 400, 440, 180));
	w.front; // make window visible and front window.
	w.view.decorator = FlowLayout(w.view.bounds);

	w.view.background = HiliteGradient(Color.rand(0.0,1.0),Color.rand(0.0,1.0),
		[\h,\v].choose, 100, rrand(0.1,0.9));

	// add a button to start and stop the sound.
	startButton = Button(w, 75 @ 24);
	startButton.states = [
		["Start", Color.black, Color.green],
		["Stop", Color.white, Color.red]
	];
	startButton.action = {|view|
		if (view.value == 1) {
			s.sendMsg("/n_set", id, "level", 0.5);
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
			s.sendMsg("/n_set", id, "level", 0);
		};
	};

	// w.view.decorator.nextLine;
	// cutoffControl = EZSlider(w, 400 @ 24, "Cutoff", ControlSpec(200, 5000, \exp),
	// {|ez| s.sendMsg("/n_set", id, "fc", ez.value); }, 1000);

	w.view.decorator.nextLine;
	levelControl = EZSlider(w, 400 @ 24, "Level", \db,
		{|ez| s.sendMsg("/n_set", id, "level", ez.value.dbamp); }, -6);


	w.view.decorator.nextLine;
	posControl = EZSlider(w, 400 @ 24, "Pos", ControlSpec(0.1, 4.0),
		{|ez| s.sendMsg("/n_set", id, "pos", ez.value); }, synth[\vals][\pos]);

	w.view.decorator.nextLine;
	speedControl = EZSlider(w, 400 @ 24, "Amp LFO Speed", ControlSpec(0.1, 4.0),
		{|ez| s.sendMsg("/n_set", id, "speed", ez.value); }, synth[\vals][\speed]);

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