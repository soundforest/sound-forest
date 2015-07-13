public class RingMod extends Chugen {
     440.0 => float freq;
     1.0 / Control.srate => float sampIncrement;
     0 => float ourTime;
     1 => int count;


    fun void setFreq( float val ) {
        val => freq;
    }

    fun float tick( float in ) {
        in * Math.sin( ourTime * freq * Math.PI * 2 ) => float mod;
        sampIncrement +=> ourTime;
        count++;
        return mod;
    }
}
