public class FxChorus extends Fx {
    Chorus chorus;

    input => chorus => output;

    fun string idString() { return "FxChorus"; }

    fun void initialise() {
        1 => active;
        chooser.getInt(1, 2) => int freqChoice;
        float freq, depth;

        if ( freqChoice == 1 ) {
            chooser.getFloat( 0.1, 0.5 ) => freq;
            chooser.getFloat( 0.1, 0.3 ) => depth;
        }
        else {
            chooser.getFloat( 1, 4 ) => freq;
            chooser.getFloat( 0.01, 0.05 ) => depth;
        }

        chooser.getFloat( 0.1, 0.6 ) => float mix;

        <<< "   FxChorus: freq", freq, "depth", depth, "mix", mix >>>;
        freq => chorus.modFreq;
        depth => chorus.modDepth;
        mix => chorus.mix;
    }
}
