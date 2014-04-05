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
