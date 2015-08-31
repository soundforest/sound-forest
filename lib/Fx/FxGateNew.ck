/*----------------------------------------------------------------------------
    Concrète Mixer - an ambient sound jukebox for the Raspberry Pi

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

public class FxGateNew extends Fx {
    LFO lfo;
    Gain g;
    float amount;
    float gateFreq;
    float gateDeltaIncrement;
    0 => int transition;
    dur transitionTime;
    dur playTime;

    fun string idString() { return "FxGateNew"; }

    fun void initialise() {
        chooser.getFloat( 1, 30 ) => gateFreq;
        <<< "ORIGINAL GATEFREQ", gateFreq >>>;
        chooser.getIntervalShort()::second => playTime;
        <<< "PLAYTIME", playTime >>>;
        0.75 => amount;
        input => g => output;

        spork ~ activity();
    }

    fun void activity() {
        0 => int count;
        while ( active ) {
            if ( transition ) {
                transit();
            }
            else {
                gate();
                10::ms -=> playTime;

                if ( playTime < 0::ms ) {
                    setEndTransitPoints();
                }
            }
            count++;
            if ( count % 100 == 0 ) {
                <<< "GATEFREQ SNAPSHOT", gateFreq >>>;
            }
        }
    }

    fun void gate() {
        lfo.osc( gateFreq, amount, "sine" ) => float gainDelta;
        gainDelta => g.gain;
        10::ms => now;
    }

    fun void transit() {
        10::ms -=> transitionTime;
        gateDeltaIncrement +=> gateFreq;
        gate();

        if ( transitionTime < 0::second) {
            0 => transition;
        }
    }

    fun void setEndTransitPoints() {
        1 => transition;
        chooser.getIntervalShort() => float transitionTimeFloat;
        <<< " " >>>
        <<< "TRANSITIONTIMEFLOAT", transitionTimeFloat >>>;
        getNewFreq() => float gateNewFreq;
        gateNewFreq - gateFreq => float diff;
        // diff * ( transitionTimeFloat * 0.001 ) => gateDeltaIncrement;
        transitionTimeFloat * 100 => float steps;
        <<< "STEPS", steps >>>;
        diff / steps => gateDeltaIncrement;
        <<< "NEW FREQ", gateNewFreq >>>;
        <<< "DIFF", diff >>>;
        <<< "gateDeltaIncrement", gateDeltaIncrement >>>;
        transitionTimeFloat::second => transitionTime;
        <<< transitionTime / Control.srate >>>;
    }

    fun float getNewFreq() {
        if ( gateFreq < 5 ) {
            return chooser.getFloat( 10, 20 );
        }
        else {
            return chooser.getFloat( 0, 11 );
        }
    }
}
