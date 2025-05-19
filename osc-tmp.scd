(
// 1) Adjust these to match your TouchOSC “Host” & port settings:
var touchHost   = "MSP-iPad.local";  // the IP TouchOSC is running on
var touchInPort = 57120;             // TouchOSC → SC (the Local Port in TouchOSC)
var touchOutPort= 57180;             // SC → TouchOSC (the Target Port in TouchOSC)

// 2) Boot the server and set up OSC
s.waitForBoot {
	// the NetAddr we'll use to send messages back to TouchOSC:
	~touch = NetAddr(touchHost, touchOutPort);

	// 3) Define a catch-all OSCdef for any incoming fader messages:
	//    we assume your faders in TouchOSC are mapped to addresses
	//    like /<voiceName>/<paramName>, e.g. /voice5/level

	// OSCdef(\touchIn, { |msg, time, addr, recvPort|
	// 	// msg[0] is the OSC address, msg[1] is the value
	// 	var path   = msg[0].asString.split("/").reject(_.isEmpty);
	// 	var name   = path[0].asSymbol;      // e.g. \voice5
	// 	var param  = path[1].asSymbol;      // e.g. \level
	// 	var value  = msg[1].asFloat;
	//
	// 	// find the matching synth state in ~synths
	// 	~synths.do { |entry|
	// 		if(entry[\vals][\name] == name) {
	// 			// update our state
	// 			entry[\vals][param] = value;
	// 			// also update the Synth parameter if it’s alive
	// 			if(entry[\sig].notNil) {
	// 				entry[\sig].set(param, value);
	// 			};
	// 		};
	// 	};
	// }, '/.*/', recvPort: touchInPort);


	// 4) Function to push ALL current state values back out into TouchOSC
	~syncToTouch = {
		~synths.do { |entry|
			var name = entry[\vals][\name].asString;  // e.g. "voice5"
			entry[\vals].keys.do { |k|
				if(k != \name) {
					var v = entry[\vals][k];
					var vUnmapped = ~specs.at(k).unmap(v);
					// send /voice5/level 0.3, /voice5/note 61, etc.
					["/"++name++"/"++k.asString, vUnmapped].postln;
					~touch.sendMsg("/"++name++"/"++k.asString, vUnmapped);
				};
			};
		};
	};

	// immediately sync on boot so TouchOSC faders reflect our state:
	~syncToTouch.value;
};
)

~touch.sendMsg("/voice1/level", 0.5.rand);

~touch.sendMsg("/voice1/width", 0.9);

ControlSpec.specs.do(_.postln);

c = ControlSpec(0, 2000)
c.map(2)

(
ControlSpec.specs.keys.do {|key, val| [key, ControlSpec.specs[key] ].postln;}
)

ControlSpec.specs[\db]

ControlSpec.specs[\msp] = ControlSpec(0.01, 2000, \exp, 0.01, 440, units: "Hz");

ControlSpec.specs[\msp].map(0.04)

ControlSpec.specs[\msp].unmap(200)

/*vals = vals.add(Dictionary[
	\name -> "voice5".asSymbol,
	\level -> 0.3,
	// \freq -> 350,
	\note -> 61,
	\amp -> synthAmp,
	\cutoff -> 20000,
	\res -> 1.0,
	\pos -> 0.2,
	\width -> 3,
	\speed -> 8,
]);*/

~specs.at(\width).unmap(3)

