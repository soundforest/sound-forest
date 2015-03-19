public class RateShift extends DiceSound {
    0 => float choice;
    0 => int note;

    [
        // -0.5, -0.666, -0.75, -0.8, -1.0, -1.2, -1.333, -1.5, -2.0,
        // 0.5, 0.666, 0.75, 0.8, 1.0, 1.2, 1.333, 1.5, 2.0

        // major? key
        // 0.5, 0.5625, 0.625, 0.665, 0.75, 0.8335, 0.875,
        // 1, 1.125, 1.25, 1.3333, 1.5, 1.6667, 1.75,
        0.5, 1, 1.25, 1.3333, 1.5, 1.75, 2
        -0.5, -1, -1.25, -1.3333, -1.5, -1.75, -2
    ] @=> float speeds[];

    fun void activity() {
        while ( active ) {
            Control.beatLength::samp => now;
            speeds[ Math.random2(0, speeds.cap() - 1 ) ] => choice;

            choice => buf.rate;
        }
    }
}
