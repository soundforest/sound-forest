public class FxDownSampler extends Fx {
    Chooser c;
    DownSampler down;

    fun string idString() { return "FxDownSampler"; }

    fun void initialise() {
        input => down => output;
        spork ~ activity();
    }


    fun void activity() {
        while ( active ) {
            down.decimate( getDecimation() );
            down.bittage( c.getInt(6, 12) );
            c.getInt(0, Control.bpmIntervalsShort.cap() - 1 ) => int intervalChoice;
            Control.bpmIntervalsShort[ intervalChoice ]::second => now;
        }
    }

    fun int getDecimation() {
        [ 1, 2, 3, 4, 6, 8, 12, 16, 24, 32 ] @=> int options[];

        return options[ c.getInt( 0, options.cap() - 1 ) ];
    }
}