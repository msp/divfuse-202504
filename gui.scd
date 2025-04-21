(
var w, startButton, noteControl, cutoffControl, resonControl;
var balanceControl, ampControl;
var id, cmdPeriodFunc;

// id = s.nextNodeID; // generate a note id.
id = ~synths[3][\sig].nodeID;

// make the window
w = Window("another control panel", Rect(20, 400, 440, 180));
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
			// start sound
			s.sendMsg("/s_new", "window-test", id, 0, 0,
				"note", noteControl.value,
				"fc", cutoffControl.value,
				"rq", resonControl.value,
				"bal", balanceControl.value,
				"amp", ampControl.value.dbamp);
		};
		if (view.value == 0) {
			// set gate to zero to cause envelope to release
			s.sendMsg("/n_set", id, "gate", 0);
		};
};

// create controls for all parameters
w.view.decorator.nextLine;
noteControl = EZSlider(w, 400 @ 24, "Note", ControlSpec(24, 60, \lin, 1),
{|ez| s.sendMsg("/n_set", id, "note", ez.value); }, 36);

w.view.decorator.nextLine;
cutoffControl = EZSlider(w, 400 @ 24, "Cutoff", ControlSpec(200, 5000, \exp),
	{|ez| s.sendMsg("/n_set", id, "fc", ez.value); }, 1000);

w.view.decorator.nextLine;
// resonControl = EZSlider(w, 400 @ 24, "Resonance", ControlSpec(0.1, 0.7),
// {|ez| s.sendMsg("/n_set", id, "rq", ez.value); }, 0.2);

resonControl = EZSlider(w, 400 @ 24, "Pos", ControlSpec(0.1, 2.0),
	{|ez| s.sendMsg("/n_set", id, "pos", ez.value); }, 0.2);

w.view.decorator.nextLine;
balanceControl = EZSlider(w, 400 @ 24, "Balance", \bipolar,
	{|ez| s.sendMsg("/n_set", id, "bal", ez.value); }, 0);

w.view.decorator.nextLine;
// ampControl = EZSlider(w, 400 @ 24, "Amp", \db,
// {|ez| s.sendMsg("/n_set", id, "amp", ez.value.dbamp); }, -6);

ampControl = EZSlider(w, 400 @ 24, "Level", \db,
	{|ez| s.sendMsg("/n_set", id, "level", ez.value.dbamp); }, -6);


// set start button to zero upon a cmd-period
cmdPeriodFunc = { startButton.value = 0; };
CmdPeriod.add(cmdPeriodFunc);

// stop the sound when window closes and remove cmdPeriodFunc.
w.onClose = {
	s.sendMsg("/n_free", id);
	CmdPeriod.remove(cmdPeriodFunc);
};

)