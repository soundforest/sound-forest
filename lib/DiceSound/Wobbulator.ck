public class Wobbulator extends DiceSound {
    LFO lfo;

    // set amounts by default for 'vibrato' mode
    c.getFloat(-0.1, 0.1) => float amount;
    c.getFloat(0.5, 10) => float freq;
    c.getInt( 1, 2 ) => int choice;

    if ( choice == 1 ) {
        <<< "Wobbulator: vibrato mode, amount", amount, "freq", freq >>>;
    }
    else {
        <<< "Wobbulator: random mode, amount", amount, "freq", freq >>>;
    }

    fun void activity() {
        while ( active ) {
            // random mode
            if ( choice == 2 ) {
                if ( c.getInt( 1, 100 ) == 1 ) {
                    c.getFloat(0, 0.2) => amount;
                    c.getFloat(0.5, 10) => freq;
                    <<< "Wobbulator: amount", amount, "freq", freq >>>;
                }
            }

            lfo.sineOsc( freq, amount ) + 1 => buf.rate;
            20::ms => now;
        }
    }
}
