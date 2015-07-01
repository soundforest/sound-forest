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

public class FxDelay extends Fx {
    Delay delay;
    input => delay => output;
    Gain feedback;
    0.5 => feedback.gain;
    delay => feedback;
    feedback => input;
    60.0 / Control.bpm * 1000.0 => float beatInterval; // BI = beat interval in ms;

    // select a few interesting delay values
    Control.bpmIntervalsMedium @=> float delayIntervals[];

    fun string idString() {
        return "FxDelay";
    }

    fun float getDelayLength() {
        chooser.getInt( 0, delayIntervals.cap() - 1 ) => int targetDelay;

        // determine if delay value greater than 2 second limit on Delay size
        if ( delayIntervals[ targetDelay ] > 2 ) {
            // it is, so try again
            return getDelayLength();
        }
        else {
            // return what we found
            return delayIntervals[ targetDelay ] * 1000; // convert to ms
        }
    }

    fun void initialise() {
        1 => active;
        getDelayLength() => float delayLength;

        chooser.getFloat( 0.4, 0.7 ) => float delayMix;
        <<< "   FxDelay: delayLength", delayLength, "delayMix", delayMix >>>;

        delayLength::ms => delay.max;
        delayLength::ms => delay.delay;
        delayMix => feedback.gain;
        spork ~ activity();
    }

    fun void activity() {
        while ( active ) {
            1::second => now;
        }

        input =< delay =< output;
        delay =< feedback =< input;
    }
}
