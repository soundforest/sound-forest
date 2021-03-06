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

SinOsc sin;

// best not to ravage ears
0.2 => sin.gain;

// sin => Control.leftOut;
// sin => Control.rightOut;
sin => dac;
200::ms => now;
880 => sin.freq;
200::ms => now;
1760 => sin.freq;
200::ms => now;
3520 => sin.freq;
200::ms => now;
7040 => sin.freq;
200::ms => now;
14080 => sin.freq;
200::ms => now;
