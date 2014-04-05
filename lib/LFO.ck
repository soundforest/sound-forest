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
