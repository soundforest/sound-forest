public class Fader {
    // this is the number of steps through which the fade will iterate
    // 100 seems reasonable
    100 => static int steps;

    fun static dur getTimeIncrement( dur fadeTime ) {
        return fadeTime / steps;
    }

    fun static float getGainIncrement( float finalGain ) {
        return finalGain / steps;
    }

    fun static void fadeIn( dur fadeTime, float finalGain, UGen gen ) {
        getTimeIncrement( fadeTime )  => dur timeIncrement;
        getGainIncrement( finalGain ) => float gainIncrement;

        spork ~ fade( fadeTime, timeIncrement, gainIncrement, gen );
    }

    fun static void fadeOut( dur fadeTime, UGen gen ) {
        getTimeIncrement( fadeTime ) => dur timeIncrement;
        getGainIncrement( gen.gain() ) => float gainIncrement;
        -gainIncrement => gainIncrement;

        spork ~ fade( fadeTime, timeIncrement, gainIncrement, gen );
    }

    fun static void fade( dur fadeTime, dur timeIncrement, float gainIncrement, UGen gen ) {
        while( fadeTime > 0::second ) {
            gen.gain() => float currGain;
            currGain + gainIncrement => float newGain;
            newGain => gen.gain;
            timeIncrement -=> fadeTime;
            timeIncrement => now;
        }
    }
}
