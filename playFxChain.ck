/*----------------------------------------------------------------------------
    Sound Forest - an ambient sound jukebox for the Raspberry Pi

    Copyright (c) 2014 Stuart McDonald  All rights reserved.
        https://github.com/soundforest/sound-forest

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
    U.S.A.
-----------------------------------------------------------------------------*/

Chooser chooser;
Panner panner;
Fader fader;

Std.atoi( me.arg(0) ) => int maxConcurrentFx;

Gain inputGain;
Pan2 outputPan;
0 => outputPan.gain;

// spork ~ panner.initialise(outputPan);
Fx @ fxChain[ maxConcurrentFx ];

[
     new FxDelay,
     new FxFilter,
     new FxChorus,
     new FxReverb,
     new FxFlanger,
     new FxDelayVariable,
     new FxGate,
     new FxHarmonicDelay
] @=> Fx fxBattery[];

UGen outLeft, outRight;

outLeft => Control.leftOut;
outRight => Control.rightOut;
Control.fxIn => inputGain;

// Fx chain is mono, let's make a little cheap stereo
Delay delay;
chooser.getDur( 0.001, 0.005 ) => delay.delay;

// should left side be delayed or right?
if ( chooser.getInt( 0, 1 ) ) {
    outputPan.left => outLeft;
    outputPan.right => delay => outRight;
}
else {
    outputPan.left => delay => outLeft;
    outputPan.right => outRight;
}

fxChainBuild();

Chooser.getDur( 90, 120 ) => dur fxTime;

fader.fadeIn( 10::second, 0.5, outputPan );
fxTime - ( 2 * 10::second ) => now;

// fader now sporks its own fadeout (cleaner) so we need to keep time
// ourselves
fader.fadeOut( 10::second, outputPan );
10::second => now;
tearDown();

fun void fxChainBuild() {
    0 => int i;

    while( i < maxConcurrentFx ) {
        chooser.getInt( 0, fxBattery.cap() - 1 ) => int j;

        // need to check if effect for j is already in fxChain
        if ( effectNotAlreadyPresent( fxBattery[ j ] ) ) {
            fxBattery[ j ] @=> fxChain[ i ];
            i++;
        }
    }

    // fxChain now set up, so wire everything up
    fxChainFx();
}

fun int effectNotAlreadyPresent( Fx fx ) {
    for ( 0 => int j; j < maxConcurrentFx; j++ ) {
        if ( fxChain[ j ] != NULL && fxChain[ j ].idString() == fx.idString() ) {
            return 0;
        }
    }

    return 1;
}

fun void fxChainFx() {
    <<< "FXCHAIN:" >>>;
    for ( 0 => int i; i < fxChain.cap(); i++ ) {
        fxChain[ i ] @=> Fx fx;
        <<< i, fx.idString() >>>;
        fx.initialise();

        if ( i == 0 ) {
            inputGain => fx.input;
        }
        else {
            fxChain[ i - 1 ] @=> Fx upstreamFx;
            upstreamFx.output => fx.input;
        }

        if ( i == fxChain.cap() - 1 ) {
            fx.output => outputPan;
        }
    }

    <<< "END OF FXCHAIN DEBUG" >>>;
}

fun void tearDown() {
    for ( 0 => int i; i < fxChain.cap(); i++ ) {
        fxChain[ i ].tearDown();
    }

    // need to give time for teardown to process
    2::second => now;

    // now we go through and clean up
    for ( 0 => int i; i < fxChain.cap(); i++ ) {
        fxChain[ i ] @=> Fx fx;
        if ( i == 0 ) {
            inputGain =< fx.input;
        }
        else {
            fxChain[ i - 1 ] @=> Fx upstreamFx;
            upstreamFx.output =< fx.input;
        }

        if ( i == fxChain.cap() - 1 ) {
            fx.output =< outputPan;
        }
    }

    outputPan.left =< outLeft;
    outputPan.right =< outRight;

    outLeft =< Control.leftOut;
    outRight =< Control.rightOut;
    2::second => now;
    Control.oscSend.startMsg("playFxChain", "i");
    1 => Control.oscSend.addInt;
}


