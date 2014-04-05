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


/*
    Provides LFO functionality for all who need it
*/
public class LFO {
    Chooser chooser;
    string oscTypes[];
    [ "sine", "square", "sampleHold" ] @=> oscTypes;

    fun string getOscType() {
        Std.rand2( 0, oscTypes.cap() - 1 ) => int key;

        return oscTypes[key];
    }

    // used to keep track of current amplitude for square wave
    // oscillator
    float currSquareAmp;

    fun float osc( float freq, float amount, string type ){
        // first convert input to something more convenient
        if ( type == "sine" ) {
            return sineOsc( freq, amount );
        }
        else if ( type == "sampleHold" ) {
            1 / freq => freq;
            freq::second => now;
            return sampleHoldOsc( amount );
        }
        else if ( type == "square" ) {
            1 / freq => freq;
            freq::second => now;
            return squareOsc( amount );
        }
    }

    fun float sineOsc( float freq, float amount ) {
        // invert frequency to convert to duration
        1 / freq => freq;

        return Math.sin( now / freq::second ) * amount;
    }

    // sample and hold oscillator
    fun float sampleHoldOsc( float amount ) {
        // halve to get range above and below the basefreq (note sine LFO
        // does this automatically as part of being a sine function)
        amount / 2 => amount;
        return chooser.getFloat( -amount, amount );
        return Std.randf( );
    }

    fun float squareOsc( float amount ) {
        // halve to get range above and below the basefreq (note sine LFO
        // does this automatically as part of being a sine function)
        amount / 2 => amount;
        // i think this should work...
        if ( currSquareAmp == amount ) {
            -amount => currSquareAmp;
        }
        else {
            amount => currSquareAmp;
        }

        return currSquareAmp;
    }
}
