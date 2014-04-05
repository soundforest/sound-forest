public class FxDelayVariable extends Fx {
    DelayL delay;
    Fader fader;
    input => delay => output;
    Gain feedback;
    0.50 => feedback.gain;
    output => feedback;
    feedback => input;

    fun string idString() {
        return "FxDelayVariable";
    }

    fun void initialise() {
        1 => active;
        501::ms => delay.max;

        spork ~ activity();
    }

    fun void activity() {
        while ( active ) {
            chooser.getDur( 0.05, 0.50 ) => dur duration;
            duration => delay.delay;
            duration - 400::samp => duration;
            fader.fadeIn( 200::samp, 1.0, output );
            200::samp => now;
            duration => now;
            fader.fadeOut( 200::samp, output );
            200::samp => now;
        }
    }
}
