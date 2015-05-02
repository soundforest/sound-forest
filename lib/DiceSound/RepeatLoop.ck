public class RepeatLoop extends DiceSound {
    [ 3, 4, 5, 6, 8, 12, 16 ] @=> int divisions[];
    c.getInt(0, divisions.cap() - 1 ) => int choice;
    divisions[ choice ] => int division;
    <<< "division", division >>>;
    ( Control.barLength / division ) $ int => int divisionLength;
    0 => int repeatoPos;
    int endPos;
    int repeato;
    5::ms => dur fadeTime;
    Fader f;
    1 => buf.loop;

    fun string idString() { return "RepeatLoop"; }

    fun void activity() {
        while ( active ) {
            c.getInt( 1, 8 ) => repeato;

            for ( 0 => int i; i < repeato; i++ ) {
                repeatoPos => buf.pos;
                f.fadeInBlocking( fadeTime, 1, buf );
                divisionLength::samp - ( 2 * fadeTime ) => now;

                f.fadeOutBlocking( fadeTime, buf );

                buf.pos() => endPos;

                if ( ! c.getInt( 0, 3 ) ) {
                    -1 => buf.rate;
                }
                else {
                    1 => buf.rate;
                }
            }

            endPos => repeatoPos;
        }
    }
}

