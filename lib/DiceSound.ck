public class DiceSound {
    1 => int active;
    SndBuf buf;
    Chooser c;
    buf.length() => dur duration;

    fun void initialise( string file ) {
        1 => buf.loop;
        file => buf.read;
    }

    fun string idString() { return ""; }

    fun dur getDiceLength() {
        if ( duration < 10::second ) {
            return c.getDur( 10, 30 );
        }
        else {
            return c.getDur( 20, 40 );
        }
    }

    fun void activity() {};
}
