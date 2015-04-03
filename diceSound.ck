me.arg(0) => string file;

<<< "Dicing with", file >>>;

Chooser c;
Fader f;
Gain g;

0 => g.gain;
g => Control.leftOut;
g => Control.rightOut;

DiceSound dice;

c.getInt(1,5) => int choice;

if ( choice == 1 ) {
    new ForwardBackwardLoop @=> dice;
}

if ( choice == 2 ) {
    new RateShift @=> dice;
}

if ( choice == 3 ) {
    new SlideRate @=> dice;
}

if ( choice == 4 ) {
    new RepeatLoop @=> dice;
}

if ( choice == 5 ) {
    new Wobbulator @=> dice;
}

if ( choice == 6 ) {
    new Divisions @=> dice;
}

dice.initialise( file );
spork ~ dice.activity();
f.fadeIn( 10::second, 0.5, g );
dice.buf => g;
dice.buf => Control.fxIn;
c.getDur( 20, 30 ) => dur duration;

<<< "duration", duration / Control.srate >>>;

duration => now;

f.fadeOutBlocking(10::second, g);

0 => dice.active;
<<< "active", dice.active >>>;
dice.buf =< g =< Control.leftOut;
dice.buf =< g =< Control.rightOut;

// Tell the server to spawn another
Control.oscSend.startMsg("diceSound", "i");
1 => Control.oscSend.addInt;
