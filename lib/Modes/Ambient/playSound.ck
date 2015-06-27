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


Fader f;

// set up UGens;
SndBuf buf;

Panner p;

Chooser c;
me.arg(0) => string filepath;

// use PainGain's gain by default
0.9 => p.pan.gain;

// set up buf
512 => buf.chunks;
filepath => buf.read;

buf => p.pan;

p.pan.left => Control.leftOut;
p.pan.right => Control.rightOut;

// send buf to fx
// could make this conditional
buf => Control.fxIn;
c.getFloat( -1.0, 1.0 ) => p.pan.pan;

buf.length() / 10 => dur fadeTime;

0 => buf.gain;

<<< "Playing", filepath >>>;

f.fadeInBlocking( fadeTime, 0.8, buf );

activity();

f.fadeOutBlocking( fadeTime, buf );

// disconnect
buf =< p.pan;
p.pan.left =< Control.leftOut;
p.pan.right =< Control.rightOut;
Control.barLength::samp * 2 => now;
Control.oscSend.startMsg("playSound", "i");

1 => Control.oscSend.addInt;

fun void activity() {
    // define convenient threshold for checking if we should bail
    // for fadeout
    buf.length() - fadeTime => dur activityEnd;

    while ( buf.pos()::samp < activityEnd ) {
        // divvy up time in chunks relative to Control.bpm
        // and determine if we want to do something with them
        Control.beatDur * c.getInt(16, 32) => dur duration;

        // if duration takes us beyond length of buf
        // play whatever we can and then return so
        // we can fade out
        if (
            buf.pos()::samp + duration > buf.length() ||
            buf.pos()::samp + duration > activityEnd
        ) {
            activityEnd - buf.pos()::samp => now;
            <<< "ACTIVITY ENDING" >>>;
            return;
        }

        // still here?
        // every so often we want to do something to the signal
        // just to vary things up a bit
        if ( c.takeAction( 16 ) ) {
            int choice;

            // rpis should be spared the chugens
            if ( Control.rpi ) {
                c.getInt( 1, 8 ) => choice;
            }
            else {
                c.getInt( 1, 10 ) => choice;
            }

            if ( choice == 1 ) {
               if ( buf.pos()::samp - duration > 0::second ) {
                    reverse( duration );
                }
                else {
                    // pick something else then
                    c.getInt( 2, 8 ) => choice;
                }
            }

            if ( choice == 2 ) {
                reepeat();
            }

            if ( choice == 3 ) {
                p.pan.pan() => float oldPan;
                Std.fabs( oldPan ) => float amount;

                if ( amount > 0.3 ) {
                    <<< "PANNING", filepath, oldPan >>>;
                    1 => p.active;
                    spork ~ p.panFromFixed( c.getFloat( 0, 1 ), oldPan, "sine", duration );
                    0 => p.active;
                    oldPan => p.pan.pan;
                }
                else {
                    c.getFloat( -1.0, 1.0 ) => p.pan.pan;
                }

                duration => now;
            }

            if ( choice == 4 ) {
                dur leftoverdur;
                int denominator;

                c.getInt( 4, 16 ) => denominator;
                slideRate( "down" , duration / denominator );
                duration - ( duration / denominator ) => leftoverdur;
                c.getInt( 4, 8 ) => denominator;
                duration / denominator => now;
                leftoverdur - ( duration / denominator ) => leftoverdur;

                c.getInt( 4, 16 ) => denominator;
                slideRate( "up" , duration / denominator );
                leftoverdur - ( duration / denominator ) => leftoverdur;

                leftoverdur => now; // should all add up to duration
            }

            if ( choice == 5 ) {
               xeno( duration );
            }

            if ( choice > 5 ) {
                effecto(duration, choice);
            }
        }
        else {
            duration => now;
        }
    }
}

fun void effecto( dur duration, int choice ) {
    Fx effect;

    if ( choice == 6 ) {
        new FxReverb @=> effect;
    }

    if ( choice == 7 ) {
        new FxFlanger @=> effect;
    }

    if ( choice == 8 ) {
        new FxDelayVariable @=> effect;
    }

    // the following not invoked if Control.rpi
    if ( choice == 9 ) {
        new FxReverseDelay @=> effect;
    }

    if ( choice == 10 ) {
        new FxDownSampler @=> effect;
    }

    <<< "EFFECTING", filepath, effect.idString() >>>;
    buf => effect.input;
    effect.output => Pan2 fpan;
    p.pan.pan() => fpan.pan;
    fpan.left => Control.leftOut;
    fpan.right => Control.rightOut;
    0 => fpan.gain;

    effect.initialise();

    f.fadeOut( duration / 2, p.pan );
    f.fadeIn( duration / 2, 0.8, fpan );

    duration / 2  => now;

    f.fadeIn( duration / 2, 0.8, p.pan );
    f.fadeOut( duration / 2, effect.output );
    duration / 2  => now;
    0 => effect.active;

    fpan =< Control.leftOut;
    fpan =< Control.rightOut;
    <<< "UNEFFECTING", filepath, effect.idString() >>>;
}

fun void reverse( dur duration) {
    reverseMessage( "REVERSING", duration );
    setRate( -1.0 );
    duration => now;
    reverseMessage( "UNREVERSING", duration );
    setRate( 1.0 );
}

fun void reepeat() {
    [ 3, 4, 5, 6, 8 ] @=> int divisions[];
    c.getInt(0, divisions.cap() - 1 ) => int choice;
    divisions[ choice ] => int division;

    ( Control.barLength / division ) $ int => int divisionLength;
    buf.pos() => int repeatoPos;
    5::ms => dur miniFadeTime;

    c.getInt( 1, 8 ) => int repeato;

    <<< "Reepeating", division, divisionLength, buf.gain() >>>;
    0 => buf.gain;

    for ( 0 => int i; i < repeato; i++ ) {
        f.fadeInBlocking( miniFadeTime, 0.8, buf );
        divisionLength::samp - ( 2 * miniFadeTime ) => now;
        f.fadeOutBlocking( miniFadeTime, buf );
        repeatoPos => buf.pos;

        if ( ! c.getInt( 0, 3 ) ) {
            setRate( -1 );
        }
        else {
            setRate( 1 );
        }
    }

    setRate( 1 );

    f.fadeInBlocking( miniFadeTime, 0.8, buf );
}

fun void slideRate( string type, dur slideTime ) {
    slideTime / 100 => dur timeIncrement;

    1 / 100.0 => float rateIncrement;

    1 => float endRate;

    if ( type == "down" ) {
        0 => endRate;
    }

    float currRate;

    while ( slideTime > 0::second ) {
        buf.rate() => currRate;

        if ( type == "up" ) {
            setRate( currRate + rateIncrement );
        }
        else {
            setRate( currRate - rateIncrement );
        }

        timeIncrement => now;
        timeIncrement -=> slideTime;
    }
}

fun void xeno( dur durdur ) {
    durdur / 12 => durdur;

    while ( durdur > 1::samp ) {
        durdur => now;
        buf.rate( -1 );

        // the following values are arbitrary TODO: something more asymptotic
        durdur * ( 5.0 / 6.0 ) => dur newdur;
        newdur => now;
        newdur => durdur;
        buf.rate( 1 );
    }
}

// While developing this I want to tune the amount of reversing that
// that goes on across a stanza. This function logs what's going on
fun void reverseMessage( string type, dur duration ) {
    <<< "playSound:", type, filepath, duration / Control.srate >>>;
}

fun void setRate( float rate ) {
    buf.rate( rate );
}
