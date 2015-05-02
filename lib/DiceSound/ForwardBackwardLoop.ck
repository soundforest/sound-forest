public class ForwardBackwardLoop extends DiceSound {
    dur forward, backward;
    c.getInt(1,3) => int choice;
    1 => float forwardrate;
    -1 => float backwardrate;
    int forwardLength;

    // Sort of FM synth sound
    if ( choice == 1 ) {
        c.getInt( 400, 600 ) => forwardLength;
        <<< forwardLength >>>;
        forwardLength::samp => forward;
        ( forwardLength -1 )::samp => backward;
        c.getDur( 30, 90 ) => duration;
    }

    // Kind of bit decimatey
    if ( choice == 2 ) {
        c.getInt( 10, 30 ) => forwardLength;
        <<< forwardLength >>>;
        forwardLength::samp => forward;
        ( forwardLength - ( forwardLength / 10 $ int ) )::samp => backward;
        <<< ( forwardLength / 10 $ int ) >>>;
        c.getDur( 15, 30 ) => duration;
    }

    // Kind of growly
    if ( choice == 3 ) {
        c.getInt(800, 1000)::samp => forward;
        c.getInt(600, 800)::samp => backward;
        800::samp => backward;
        c.getDur( 20, 40 ) => duration;
    }

    fun string idString() { return "Divisions " + choice; }

    fun dur getDiceLength() {
        return duration;
    }

    fun void activity() {
        while ( active ) {
            forwardrate => buf.rate;
            forward => now;
            backwardrate => buf.rate;
            backward => now;
        }
    }
}
