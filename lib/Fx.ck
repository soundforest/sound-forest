public class Fx {
    Chooser chooser;
    1 => int active;

    Gain input, output;

    fun string idString() { return "Fx"; }

    fun void initialise() {}

    fun void connectToFxChain( Gain targetGain ) {}

    // sets active to false, so when fx.execute while block
    // next loops, it will shut down
    fun void tearDown() {
        <<< "calling Fx.tearDown()" >>>;
        0 => active;
    }
}
