"audio/drum-machine/" + me.arg(0) + "/" => string drumPath;

<<< drumPath >>>;

Gain g;
g => Control.leftOut;
g => Control.rightOut;
g => Control.fxIn;

SndBuf kickBuf, snareBuf, chBuf, ohBuf;

drumPath + "kick.wav" => kickBuf.read;
drumPath + "snare.wav" => snareBuf.read;
drumPath + "closed-hat.wav" => chBuf.read;
drumPath + "open-hat.wav" => ohBuf.read;

[ kickBuf, snareBuf, chBuf, ohBuf ] @=> SndBuf bufs[];

for ( 0 => int i; i < bufs.cap(); i++ ) {
    bufs[ i ] => g;
    bufs[ i ].samples() - 1 => bufs[ i ].pos;
}

[
    1, 0, 0, 0,
    1, 0, 1, 0,
    1, 0, 0, 0,
    1, 0, 0, 0
] @=> int kickPattern[];

[
    0, 0, 0, 0,
    1, 0, 0, 0,
    0, 0, 0, 0,
    1, 0, 0, 0
] @=> int snarePattern[];

[
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 0, 0
] @=> int chPattern[];

[
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0
] @=> int ohPattern[];

( Control.beatDur / 4 ) $ dur => dur sixteenthBeat;

0 => int step;

while ( true ) {
    if ( kickPattern[ step ] ) {
        0 => kickBuf.pos;
    }

    if ( snarePattern[ step ] ) {
        0 => snareBuf.pos;
    }

    if ( chPattern[ step ] ) {
        0 => chBuf.pos;
    }

    if ( ohPattern[ step ] ) {
        0 => ohBuf.pos;
    }

    sixteenthBeat => now;
    step++;

    if ( step == 16 ) {
        0 => step;
    }
}
