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

public class FxHarmonicDelay extends Fx {
    Delay delay;
    Chooser c;
    input => delay => output;
    Gain feedback;
    -0.9 => feedback.gain;
    delay => feedback;
    feedback => input;
    60.0 / Control.bpm * 1000.0 => float beatInterval; // BI = beat interval in ms;

    // select a few interesting delay values
    Control.bpmIntervalsShort @=> float delayIntervals[];
    1.0 / 55 => float baseFreq;
    [ 0.25, 0.5, 0.75, 1.5, 2.0 ] @=> float factors[];
    baseFreq => float delayAmount;

    fun string idString() {
        return "FxHarmonicDelay";
    }

    fun void initialise() {
        1 => active;

        0.5 => float delayMax;
        delayAmount => float delayLength;

        0.9 => float delayMix;

        delayMax::second => delay.max;
        delayLength::second => delay.delay;
        delayMix => feedback.gain;
        spork ~ activity();
    }

    fun void activity() {
        // set a delay frequency and a period for that delay to be in place
        // using the factors array
        while ( active ) {
            factors[ c.getInt(0, factors.cap() - 1) ] => float choice;
            ( beatInterval * choice )::ms => now;
            factors[ c.getInt(0, factors.cap() - 1) ] => choice;
            baseFreq * choice => float amount;
            amount::second => delay.delay;
        }

        input =< delay =< output;
        delay =< feedback =< input;
    }
}
