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

public class FxRingMod extends Fx {
    Chooser c;
    RingMod ring;
    ring.setFreq( 20 );
    float freq;
    [ 1.0, 1.333, 1.5, 2.0, 2.666, 2.5, 3.0, 4.0, 5.0, 6.0 ] @=> float factors[];

    if ( ! Control.rpi ) {
        input => ring => output;
    }
    else {
        // do nothing
        input => output;
    }


    fun string idString() {
        return "FxRingMod";
    }

    fun void initialise() {
        spork ~ activity();
    }

    fun void activity() {
        if ( Control.rpi ) {
            while ( active ) {
                1::second => now;
            }

            input =< output;
        }
        else {
            c.getFloat( 20, 1600 ) => float freq;
            ring.setFreq( freq );

            <<< "setting RingMod freq", freq >>>;
            while ( active ) {
                factors[ c.getInt( 0, factors.cap() - 1 ) ] => float choice;
                choice * Control.beatDur => now;
            }

            input =< ring =< output;
        }
    }
}
