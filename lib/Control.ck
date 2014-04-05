// increase the size of the array to get more channels
// due to Kassen, see http://wiki.cs.princeton.edu/index.php/buses
public class Control {
    static Gain @ leftOut;
    static Gain @ rightOut;
    static Gain @ fxIn;
    static int sampleActive[];

    static OscSend @ oscSend;

    fun static void changeSampleActive( int index, int setting ) {
        <<< "Control.changeSampleActive - index:", index, index - 1, "setting:", setting >>>;
        setting => sampleActive[ index - 1 ];
    }

    fun static int getSampleActive( int index ) {
        return sampleActive[ index - 1 ];
    }
}

new Gain @=> Control.leftOut;
new Gain @=> Control.rightOut;
new Gain @=> Control.fxIn;

Dyno dynoL => dac.left;
Dyno dynoR => dac.right;
dynoL.limit();
dynoR.limit();

Control.leftOut => dynoL; // left 'dry' out
Control.rightOut => dynoR; // right 'dry' out

0.5 => Control.fxIn.gain;
Control.fxIn => blackhole;

[ 0, 0 ] @=> Control.sampleActive;

new OscSend @=> Control.oscSend;
Control.oscSend.setHost("localhost", 3141);

while( true ) {
   10::second => now;
}
