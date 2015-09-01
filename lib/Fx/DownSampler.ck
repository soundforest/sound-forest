/*----------------------------------------------------------------------------
    Concrète Mixer - an ambient sound jukebox for the Raspberry Pi

    Copyright (c) 2014 Stuart McDonald  All rights reserved.
        https://github.com/concrete-mixer/concrete-mixer

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

// Pinched from https://ccrma.stanford.edu/~spencer/publications/CCC2012.pdf
// Annotated to make more sense to me
public class DownSampler extends Chugen {
    8 => int bits;
    2 => int decimation;
    float sample;
    int count;
    Math.pow(2,31) => float fINT_MAX;

    fun float tick(float in) {
        // if count equals downsample, set the current input to sample
        // means that downsample number of ticks will have the same value
        // reducing bandwidth
        if(count++ % decimation == 0 ) {
            // ensure sample within bounds when setting
            // Math.min(1,Math.max( -1, in )) => sample;
            in => sample;
        }

        // convert from -1 - 1 float to 32bit int
        (sample * fINT_MAX) $ int => int q32;

        32 - bits => int bitShift;

        // perform bitwise operations on value to lowe resolution
        // and then restore
        ((q32 >> bitShift) << bitShift) => q32;

        return q32 / fINT_MAX;
    }

    fun void decimate( int decimateInput ) {
        decimateInput => decimation;
    }

    fun void bittage( int bittageInput ) {
        bittageInput => bits;
    }
}
