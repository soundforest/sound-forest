public class DiceSound {
    1 => int active;
    SndBuf buf;
    Chooser c;

    fun void initialise( string file ) {
        1 => buf.loop;
        file => buf.read;
    }

    fun void activity() {};
}
