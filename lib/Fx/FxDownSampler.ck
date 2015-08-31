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


public class FxDownSampler extends Fx {
    Chooser c;
    DownSampler down;

    fun string idString() { return "FxDownSampler"; }

    fun void initialise() {
        if ( Control.rpi ) {
            input => output;
        }
        else {
            input => down => Gain g => output;
            0.7 => g.gain;
        }

        spork ~ activity();
    }


    fun void activity() {
        if ( Control.rpi ) {
            while ( active ) {
                1::second => now;
            }
        }
        else {
            while ( active ) {
                down.decimate( getDecimation() );
                // down.bittage( c.getInt(6, 16) );
                c.getInt(0, Control.bpmIntervalsShort.cap() - 1 ) => int intervalChoice;
                Control.bpmIntervalsShort[ intervalChoice ]::second => now;
            }
        }
    }

    fun int getDecimation() {
        [ 1, 2, 3, 4, 6, 8, 12, 16, 24, 32 ] @=> int options[];

        return options[ c.getInt( 0, options.cap() - 1 ) ];
    }
}
