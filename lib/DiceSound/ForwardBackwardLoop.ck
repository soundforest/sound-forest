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
    }

    // Kind of bit decimatey
    if ( choice == 2 ) {
        c.getInt( 10, 30 ) => forwardLength;
        <<< forwardLength >>>;
        forwardLength::samp => forward;
        ( forwardLength - ( forwardLength / 10 $ int ) )::samp => backward;
        <<< ( forwardLength / 10 $ int ) >>>;
    }

    // Kind of growly
    if ( choice == 3 ) {
        1000::samp => forward;
        800::samp => backward;
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
