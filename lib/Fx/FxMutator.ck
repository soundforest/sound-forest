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

public class FxReverseDelay extends Fx {
    ( Control.bpmIntervalsShort[ Control.bpmIntervalsShort.cap() - 1 ] * Control.srate ) $ int => int delaySize;
    <<< "Delaysize", delaySize >>>;
    ReverseDelay delay;
    delaySize => delay.delay;
    input => delay => output;
    Gain feedback;
    // 0.5 => feedback.gain;
    Chooser c;
    c.getInt(0,1) => int doFeedback;
    c.getInt(0,1) => int doRandomSpeed;
    0 => doRandomSpeed;
    [ 0.25, 0.5, 1, 2 ] @=> float randomSpeeds[];

    if ( doFeedback ) {
        c.getFloat(0.25, 0.75) => feedback.gain;
    }
    else {
        0 => feedback.gain;
    }
    // 0.5 => feedback.gain;
    delay => feedback => input;
    60.0 / Control.bpm * 1000.0 => float beatInterval; // BI = beat interval in ms;


    fun string idString() {
        return "FxReverseDelay";
    }

    fun void initialise() {
        spork ~ activity();
    }

    fun void activity() {
        while ( active ) {
            if ( doRandomSpeed ) {
                c.getInt(0, randomSpeeds.cap() - 1) => int choice;
                <<< "New Increment:", randomSpeeds[ choice ] >>>;
                delay.setIncrement( randomSpeeds[ choice ] );
                c.getIntervalShort() => float choiceDur;
                ( ( choiceDur * Control.srate ) - 1 ) $ int => int newLength;
                newLength => delay.delay;
                choiceDur::second => now;
            }
            else {
                1::second => now;
            }
        }

        input =< delay =< output;
        delay =< feedback =< input;
    }
}
