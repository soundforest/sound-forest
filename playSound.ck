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


me.arg(0) => string file;
Fader fader;

// set up UGens;
SndBuf buf;
Pan2 pan;

1 => int active;
Chooser chooser;
me.arg(0) => string filepath;

// use PainGain's gain by default
0.3 => float maxGain;
maxGain => pan.gain;

// set up buf
512 => buf.chunks;
filepath => buf.read;

// set sample loop so we can arbitrarily reverse even at the start
// of the sample
1 => buf.loop;
buf => pan;

pan.left => Control.leftOut;
pan.right => Control.rightOut;

// send buf to fx
// could make this conditional
buf => Control.fxIn;
chooser.getFloat( -1.0, 1.0 ) => pan.pan;

// TODO: reinstate dynamic panning

10::second => dur fadeTime;

spork ~ reverseSchedule();
0 => buf.gain;
fader.fadeIn( 10::second, 0.8, buf );

// run for determined length of playback, minus fadeout time
getTiming() => now;

fader.fadeOut( 10::second, buf );

// fader sporks so we can fade two channels concurrently
// so we have to observe time here as well
10::second => now;

// disconnect
buf =< pan;
pan.left =< Control.leftOut;
pan.right =< Control.rightOut;
0 => active;
Control.oscSend.startMsg("playSound", "i");
1 => Control.oscSend.addInt;

// Returns duration of sample playback
// At the moment we expect the samples given to us to be played for 'long'
// periods, at least 90 seconds - 2 minutes. Some shorter samples are conducive
// to looping, and others are intended as 'one-shots'. How do we distinguish
// the two? We don't. For now, assume all samples passed to this file are
// intended to play for a while. Next question: how long do we loop for?
// Let's assume 90 - 150 seconds is a reasonable amount of time for a shortish
// (30::second) loop to be played.
fun dur getTiming() {
    dur timing;
    buf.length() => dur length;

    if ( length < 1::minute ) {
        chooser.getDur( 90, 150 ) => timing;
    }
    else {
        // timing for 'main sequence' of sample is its length - fade time
        buf.length() - fadeTime => timing;
    }

    return timing;
}

fun void reverseSchedule() {
    // give buffer chance to load before trying to reverse as may lead
    // to dropout because samples at the end haven't been loaded yet
    2::second => now;

    while ( active ) {
        chooser.getDur( 5, 10 ) => dur duration;

        // we don't want to reverse too often
        // 1/32 seems pretty infrequent, but we are checking every 7.5 seconds
        // on average so you'd expect a reverse event to happen across two 
        // streams once every couple of minutes
        if ( chooser.takeAction( 32 ) ) {
            if ( buf.pos() == 0 ) {
                buf.samples() => buf.pos;
            }
            reverse( duration );
        }
        else {
            duration => now;
        }
    }
}

fun void reverse( dur duration) {
    reverseMessage( "REVERSING", duration );
    setRate( -1.0 );
    duration => now;
    reverseMessage( "UNREVERSING", duration );
    setRate( 1.0 );
}

// While developing this I want to tune the amount of reversing that
// that goes on across a stanza. This function logs what's going on
fun void reverseMessage( string type, dur duration ) {
    <<< "playSound:", type, filepath, duration / 44100 >>>;
}

fun void setRate( float rate ) {
    buf.rate( rate );
}

// API call to give Sample option of killing or lowering
// its dry output
// useful for providing variation when using fx chains
fun void setMixChoice() {
    chooser.getInt( 0, 8 ) => int mixChoice;

    // if mixChoice is 0, kill dry output
    // if 1-6, keep dry volume normal
    // if 7-8, halve volume
    if ( !mixChoice ) {
        // set sample dry out to 0
        0 => setMix;
    }
    else if ( mixChoice > 6 ) {
        // halve dry gain
        buf.gain() / 2 => setMix;
    }
}

fun void setMix( float gain ) {
    0 => pan.gain;
}
