Chooser c;

me.arg(0) => string file;

Fader f;
Pan2 g;

0 => g.gain;
g.left => Control.leftOut;
g.right => Control.rightOut;
c.getFloat( -1.0, 1.0 ) => g.pan;

DiceSound dice;

c.getInt(1,4) => int choice;
2 => choice;
if ( choice == 1 ) {
    new SlideRate @=> dice;
}

if ( choice == 2 ) {
    new RepeatLoop @=> dice;
}

if ( choice == 3 ) {
    new Wobbulator @=> dice;
}

if ( choice == 4 ) {
    new Divisions @=> dice;
}

dice.initialise( file );
dice.buf => g;
g => Control.fxIn;
dice.getDiceLength() => dur duration;
duration / 5 => dur fadeLength;

<<< "Dicing with", file, "strategy", dice.idString(), "duration", duration / Control.srate >>>;
spork ~ dice.activity();

f.fadeIn( fadeLength, 0.2, g );
duration - fadeLength => now;

f.fadeOutBlocking(fadeLength, g);

0 => dice.active;
<<< "active", dice.active >>>;
dice.buf =< g =< Control.leftOut;
dice.buf =< g =< Control.rightOut;

// before tell the OSC server to kick off another diceSound run,
// let's wait a bit so we have a bit of breathing space
( c.getIntervalLong() / 2.0 )::second => now;

// Tell the server to spawn another
Control.oscSend.startMsg("diceSound", "i");
1 => Control.oscSend.addInt;
