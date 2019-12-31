/*
trigger warning.
R.McMASTERS.
2016.

for Sonya BELAYA

i hope to someday finish writing this piece.

*/

s.boot;
s.waitForBoot{
	s.record;

	//buffer setup

	~buffer=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname +/+ "audio files/ar 15.2.wav", channels:1);
	~buffer2=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname +/+ "audio files/at rest.wav",channels:1);

	//changes the distance between events (higher is faster). default  of 20 puts 50ms/day.
	~ratio=20;



	//data sets
	~days_between=[0,679,19,763,246,299,336,240,277,485,16,13,169,167,259,36,123,7,188,287,312,584,94,78,18,58,334,100, 48,48,58,362,41,883,519,94,9,315,54,191,133,63,174,59,64,7,132,277,5, 216, 24, 247, 158, 241, 38, 131, 40, 48, 61, 16, 53, 78, 89, 39, 47, 49, 52, 157, 42, 50, 154, 230, 6, 29, 77, 30, 27, 5, 80, 5, 108, 25, 10];

	~days_total=[0,679,698, 1461, 1707,2006,2342,2582,2859,3344,3360,3373,3542,3709,3968,4004,4127,4134,4322,4609,4921,5505,5599,5677,5695,5753,6087,6187,6235,6283,6341,6703,6744,7627,8146,8240,8249,8564,8618,8809,8942,9005,9179,9238,9302,9309,9441,9718,9723,9939,9963,10210,10368,10609,10647,10778,10818,10866,10927,10943,10996,11074,11163,11202,11249,11298,11350,11507,11549,11599,11753,11983,11989,12018,12095,12125,12152,12157,12237,12242,12350,12375,12385];

	~where=[80, 97, 117, 97, 81, 122, 121, 86, 82, 98, 92, 83, 122, 77, 122, 78, 73, 104, 117, 97, 80, 81, 117, 72, 90, 123, 104, 84, 97, 157, 82, 71, 87, 88, 83, 88, 95, 119, 122, 76, 111, 80, 88, 95, 90, 88, 87, 79, 75, 97, 122, 72, 110, 119, 118, 84, 122, 122, 104, 87, 93, 73, 74, 122, 118, 80, 76, 120, 97, 119, 122, 88, 79, 85, 123, 104, 104, 117, 85, 97, 81, 96, 91];
	~victims=[8,6,22,15,6,7,6,9,10,24,6,5,4,5,9,4,6,4,5,6,6,4,5,5,5,4,13,9,8,7,5,7,5,7,5,7,10,8,7,6,6,33,6,9,6,6,6,8,14,13,4,9,6,5,8,5,7,6,12,7,7,28,5,5,6,7,12,4,3,6,5,3,9,5,9,3,3,14,6,3,49,5,3];

	~victims_total=[8,14,36,51,57,64,70,79,89,113,119,124,128,133,142,146,152,156,161,167,173,177,182,187,192,196,209,218,226,233,238,245,250,257,262,269,279,287,294,300,306,339,345,354,360,366,372,380,394,407,411,420,426,431,439,444,451,457,469,476,483,511,516,521,527,534,546,550,553,559,564,567,576,581,590,593,596,610,616,619,668,673,676];

	//diagnostic info
	~victims.size.postln;
	~where.size.postln;
	~days_between.size.postln;
	~days_total.size.postln;


	//synthdefs

	//gunshot
	SynthDef(\bang,
		{
			arg panpos=(-1.0);
			var panpan, sound, delay;
			sound = PlayBuf.ar(1,~buffer.bufnum, doneAction:2);
			panpan = Pan2.ar(sound,panpos);
			Out.ar(0,panpan);
		}
	).load(s);

	//crackle
	SynthDef(\rest,
		{
			arg amp, dur, panpos, rate=0.1, freq;
			var sound, pan, lfo;
			sound = PlayBuf.ar(1,~buffer2.bufnum,rate,loop:1);
			lfo = Dust2.ar(freq,sound);
			pan = Pan2.ar(lfo,0);
			Out.ar(0,pan);
	}).load(s);

	~rest=Routine({
		~rest2=Synth(\rest, [\freq,1]);
	});

	//faster crackle
	SynthDef(\rest3,
		{
			arg amp, dur, panpos, rate=0.25, freq;
			var sound, pan, lfo,env;
			sound = PlayBuf.ar(1,~buffer2.bufnum,rate,loop:1);
			env = XLine.kr(0.001,1,3);
			env = env*sound;
			lfo = LFCub.ar(500,mul:sound);
			Out.ar([0,1],lfo);
	}).load(s);

	~rest3=Routine({
		~rest4=Synth(\rest3);
	});



	//final chorale
	SynthDef(\restLast,
		{
			var sound, delay, env1,env2;
			sound = PlayBuf.ar(1,~buffer2.bufnum,startPos:500000);
			env1 = XLine.kr(1,0.0000001,1200);
			env2 = XLine.kr(0.000001,1,10);
			env1 = env1*sound*env2;
			delay = GVerb.ar(env1, 50);
			Out.ar([0,1],delay);
	}).load(s);

	~restLast=Routine({
		~restLast2=Synth(\restLast);
	});


	//the window
	~w=Window("trigger warning.", Rect(100,100,1200,650))
	.front
	.alwaysOnTop_(true)
	.background_(Color.black)
	.onClose_({~a.free});

	//pitch array
	~image1 = Image.new("C:/Users/Ryan/Documents/Finale/mine/trigger warning/images/rangeBW2.0.TIF").scalesWhenResized_(true).setSize(1100, 300);

	~userView = UserView(~w, Rect(50,300,1100,300)).backgroundImage_(~image1);


	//blinker functions
	//blind width
	~pW=90;

	//blind vertical offset
	~pV=300;

	//blinds
	~a = StaticText(~w, Rect(50, 300, 110, 300)).background_(Color.grey(0,0.9));
	~b = StaticText(~w, Rect(160,~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~c = StaticText(~w, Rect(250,~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~d = StaticText(~w, Rect(340,~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~e = StaticText(~w, Rect(430,~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~f = StaticText(~w, Rect(520,~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~g = StaticText(~w, Rect(610,~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~h = StaticText(~w, Rect(700, ~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~i = StaticText(~w, Rect(790, ~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~j = StaticText(~w, Rect(880, ~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~k = StaticText(~w, Rect(970, ~pV,~pW, 300)).background_(Color.grey(0,0.9));
	~l = StaticText(~w, Rect(1060, ~pV,~pW, 300)).background_(Color.grey(0,0.9));

	//start button
	~button=Button(~w, Rect(450,50, 300, 100))
	.font_(Font("Garamond", size:96))
	.states_([
		["Start", Color.white, Color.black]
	])
	.action_({
		arg obj;
		if(
			obj.value==0,

			{
				~rest.play;
				Routine({
					~days_between.size.do{
						arg counter;
						(~days_between[(counter)]/~ratio).wait;
						Synth(\bang, [\panpos, (-1.0*((~where[counter]-71)/(43) - 1)).postln]);
						~rest2.set(\freq,~victims_total[counter]);
				}}
				).play;


				AppClock.sched(~days_total[0], Routine(
					{ ~victims[0].do{
						arg counter1;
						[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
							~a.background_(Color.new(0,0,0,(counter)));
							0.1.wait};
						2.0.wait}}));

				AppClock.sched((~days_total[1]/~ratio), Routine(
					{ ~victims[1].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					0.8.wait;}}));

				AppClock.sched((~days_total[2]/~ratio), Routine(
					{ ~victims[2].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[3]/~ratio), Routine(
					{ ~victims[3].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~g.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[4]/~ratio), Routine(
					{ ~victims[4].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[5]/~ratio), Routine(
					{ ~victims[5].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~f.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[6]/~ratio), Routine(
					{ ~victims[6].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[7]/~ratio), Routine(
					{ ~victims[7].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				SystemClock.sched((~days_total[7]/~ratio), ~rest2.set(\rate,0.25));

				AppClock.sched((~days_total[8]/~ratio), Routine(
					{ ~victims[8].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~b.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[9]/~ratio), Routine(
					{ ~victims[9].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[10]/~ratio), Routine(
					{ ~victims[10].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[11]/~ratio), Routine(
					{ ~victims[11].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~g.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[12]/~ratio), Routine(
					{ ~victims[12].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~i.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[13]/~ratio), Routine(
					{ ~victims[13].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~k.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[14]/~ratio), Routine(
					{ ~victims[14].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~l.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[15]/~ratio), Routine(
					{ ~victims[15].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~k.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[16]/~ratio), Routine(
					{ ~victims[16].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~j.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[17]/~ratio), Routine(
					{ ~victims[17].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~i.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[18]/~ratio), Routine(
					{ ~victims[18].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~h.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[19]/~ratio), Routine(
					{ ~victims[19].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[20]/~ratio), Routine(
					{ ~victims[20].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~i.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					2.0.rand.wait;}}));

				AppClock.sched((~days_total[21]/~ratio), Routine(
					{ ~victims[21].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~l.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.rand.wait;}}));

				AppClock.sched((~days_total[22]/~ratio), Routine(
					{ ~victims[22].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~f.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[23]/~ratio), Routine(
					{ ~victims[23].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~g.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[24]/~ratio), Routine(
					{ ~victims[24].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~k.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[25]/~ratio), Routine(
					{ ~victims[25].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~i.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[26]/~ratio), Routine(
					{ ~victims[26].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[27]/~ratio), Routine(
					{ ~victims[27].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[30]/~ratio), Routine(
					{ ~victims[30].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~g.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[31]/~ratio), Routine(
					{ ~victims[31].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[32]/~ratio), Routine(
					{ ~victims[33].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				SystemClock.sched((~days_total[32]/~ratio), Routine({~rest4=Synth(\rest3)}));

				AppClock.sched((~days_total[33]/~ratio), Routine(
					{ ~victims[33].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[34]/~ratio), Routine(
					{ ~victims[34].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~c.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[35]/~ratio), Routine(
					{ ~victims[35].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~f.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[36]/~ratio), Routine(
					{ ~victims[36].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[37]/~ratio), Routine(
					{ ~victims[37].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~g.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[38]/~ratio), Routine(
					{ ~victims[38].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[39]/~ratio), Routine(
					{ ~victims[39].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[40]/~ratio), Routine(
					{ ~victims[40].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[41]/~ratio), Routine(
					{ ~victims[41].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~f.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[42]/~ratio), Routine(
					{ ~victims[42].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~c.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched(~days_total[43], Routine(
					{ ~victims[43].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait}}));

				AppClock.sched((~days_total[44]/~ratio), Routine(
					{ ~victims[44].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					0.8.wait;}}));

				AppClock.sched((~days_total[45]/~ratio), Routine(
					{ ~victims[45].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[46]/~ratio), Routine(
					{ ~victims[46].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~g.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[47]/~ratio), Routine(
					{ ~victims[47].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[48]/~ratio), Routine(
					{ ~victims[48].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~f.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[49]/~ratio), Routine(
					{ ~victims[49].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[50]/~ratio), Routine(
					{ ~victims[50].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[51]/~ratio), Routine(
					{ ~victims[51].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~b.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[52]/~ratio), Routine(
					{ ~victims[52].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[53]/~ratio), Routine(
					{ ~victims[53].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[54]/~ratio), Routine(
					{ ~victims[54].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~g.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[55]/~ratio), Routine(
					{ ~victims[55].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~i.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[56]/~ratio), Routine(
					{ ~victims[56].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~k.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[57]/~ratio), Routine(
					{ ~victims[57].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[58]/~ratio), Routine(
					{ ~victims[58].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~k.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[59]/~ratio), Routine(
					{ ~victims[59].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~j.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[60]/~ratio), Routine(
					{ ~victims[60].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~i.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[61]/~ratio), Routine(
					{ ~victims[61].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~h.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[62]/~ratio), Routine(
					{ ~victims[62].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[63]/~ratio), Routine(
					{ ~victims[63].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~i.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[64]/~ratio), Routine(
					{ ~victims[64].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~l.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[65]/~ratio), Routine(
					{ ~victims[65].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[66]/~ratio), Routine(
					{ ~victims[66].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[67]/~ratio), Routine(
					{ ~victims[67].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~k.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[68]/~ratio), Routine(
					{ ~victims[68].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~i.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[69]/~ratio), Routine(
					{ ~victims[69].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[70]/~ratio), Routine(
					{ ~victims[70].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[71]/~ratio), Routine(
					{ ~victims[71].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~g.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[72]/~ratio), Routine(
					{ ~victims[72].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[73]/~ratio), Routine(
					{ ~victims[73].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[74]/~ratio), Routine(
					{ ~victims[74].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[75]/~ratio), Routine(
					{ ~victims[75].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~c.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[76]/~ratio), Routine(
					{ ~victims[76].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~f.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[77]/~ratio), Routine(
					{ ~victims[77].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[78]/~ratio), Routine(
					{ ~victims[78].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~g.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[79]/~ratio), Routine(
					{ ~victims[79].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~e.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[80]/~ratio), Routine(
					{ ~victims[80].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~d.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[81]/~ratio), Routine(
					{ ~victims[81].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~a.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				AppClock.sched((~days_total[82]/~ratio), Routine(
					{ ~victims[82].do{[0.9,0.75,0.5,0.25,0,0.25,0.5,0.75,0.9].do{arg counter;
						~f.background_(Color.new(0,0,0,(counter)));
						0.1.wait};
					1.0.wait;}}));

				SystemClock.sched((~days_total[82]/~ratio), Routine({
					~restLast2=Synth(\restLast)}
				))
	})}
)}