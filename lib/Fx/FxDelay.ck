public class FxDelay extends Fx {
    Delay delay;
    input => delay => output;
    Gain feedback;
    0.5 => feedback.gain;
    delay => feedback;
    feedback => input;

    fun string idString() {
        return "FxDelay";
    }

    fun void initialise() {
        1 => active;
        chooser.getInt( 200, 2000 ) => int delayLength;
        2000 => int delayMax;
        chooser.getFloat( 0.4, 0.7 ) => float delayMix;
        <<< "   FxDelay: delayLength", delayLength, "delayMax", delayMax, "delayMix", delayMix >>>;

        delayMax::ms => delay.max;
        delayLength::ms => delay.delay;
        delayMix => feedback.gain;
        spork ~ activity();
    }

    fun void activity() {
        while ( active ) {
            1::second => now;
        }

        input =< delay =< output;
        delay =< feedback =< input;
    }
}
