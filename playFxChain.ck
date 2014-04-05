Chooser chooser;
Panner panner;
Fader fader;

Std.atoi( me.arg(0) ) => int maxConcurrentFx;

Gain inputGain;
Pan2 outputPan;
0 => outputPan.gain;

// spork ~ panner.initialise(outputPan);
Fx @ fxChain[ maxConcurrentFx ];
Fx @ fxBattery[6];

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

new FxDelay @=> fxBattery[0];
new FxFilter @=> fxBattery[1];
new FxChorus @=> fxBattery[2];
new FxReverb @=> fxBattery[3];
new FxFlanger @=> fxBattery[4];
new FxDelayVariable @=> fxBattery[5];

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


