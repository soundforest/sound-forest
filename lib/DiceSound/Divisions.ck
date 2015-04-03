public class Divisions extends DiceSound {
    [ 3, 4, 6, 8, 16 ] @=> int divisions[];
    c.getInt( 0, divisions.cap() - 1 ) => int choice;
    divisions[ choice ] => int division;

    int divisionSamples;

    ( ( ( 60.0 / Control.bpm ) / division $ float ) * Control.srate $ float )
        $ int => int trackDivisionInterval;

    fun void initialise( string file ) {
        file => buf.read;
        buf.samples() / division $ int => divisionSamples;
    }

    fun void activity() {
        while ( true ) {
            getNextPos() => buf.pos;
            trackDivisionInterval::samp => now;
        }
    }

    fun int getNextPos() {
        c.getInt( 0, division - 1 ) => int choice;
 
        if ( choice * divisionSamples == buf.pos() - divisionSamples ) {
            return getNextPos();
        }
        else {
            return choice * divisionSamples;
        }
    }
}
