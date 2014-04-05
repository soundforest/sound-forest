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

public class FxFlanger extends Fx {
    LFO lfo;
    DelayA flanger;
    Gain feedback;

    float oscFreq, oscAmount, volFreq, volAmount, baseDelay;
    string oscType, volType;

    fun string idString() { return "FxFlanger"; }

    fun void initialise() {
        input => flanger => output;
        flanger => feedback => input;

        // choose to go with slow and heavy flange
        // or fast and light
        chooser.getInt( 1, 2 ) => int flangeType;

        // 1 == slow
        if ( flangeType == 1 ) {
            chooser.getFloat( 0.05, 0.25 ) => oscFreq;
            chooser.getFloat( 1, 5 ) => baseDelay;
            chooser.getFloat( 1, baseDelay - 0.1 ) => oscAmount;
            chooser.getFloat( 0.05, 0.25 ) => volFreq;
            chooser.getFloat( 0.4, 0.8 ) => volAmount;
            "sine" => oscType;
            "sine" => volType;
        }
        // 2 == fast
        else {
            chooser.getFloat( 0.5, 5 ) => oscFreq;
            chooser.getFloat( 1, 2.5 ) => baseDelay;
            chooser.getFloat( 1, baseDelay - 0.1 ) => oscAmount;
            chooser.getFloat( 0.1, 0.6 ) => volFreq;
            chooser.getFloat( 0.4, 0.8 ) => volAmount;
            getOscType() => oscType;
            getOscType() => volType;
        }

        <<< "   FxFlanger", "oscType:", oscType, "volType:", volType, "oscFreq:", oscFreq, "volFreq:", volFreq, "oscAmount:", oscAmount, "volAmount:", volAmount, "baseDelay:", baseDelay >>>;

        0 => feedback.gain;
        baseDelay::ms => flanger.delay;
        2000::ms => flanger.max;

        spork ~ activity();
    }

    fun string getOscType() {
        chooser.getInt( 1, 4 ) => int choice;

        // sine is best but sampleHold on flange is a bit of
        // a novelty, so keeping
        if ( choice == 1 ) {
            return "sampleHold";
        }
        else {
            return "sine";
        }
    }

    fun void activity() {
        while ( active ) {
            lfo.osc( oscFreq, oscAmount, oscType ) => float freqDelta;
            baseDelay::ms + freqDelta::ms => flanger.delay;
            lfo.osc( volFreq, volAmount, volType ) => feedback.gain;
            10::ms => now;
        }
    }

    fun void tearDown() {
        input =< flanger =< output;
        flanger =< feedback =< input;
        0 => active;
    }
}
