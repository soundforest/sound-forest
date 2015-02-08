me.arg(0) => string file;

SndBuf buf => dac;
// "audio/one-shot/lauterbrunnen - stops on request.wav" => buf.read;
// "audio/one-shot/richard nunns flute loop3.wav" => buf.read;
// "audio/dice-sounds/miles davis brass papr.wav" => buf.read;
// "audio/one-shot/forward aso chanteuse no2.wav" => buf.read;
<<< "Dicing with", file >>>;
// file => buf.read;
buf.length() => dur length;
1 => buf.loop;
0.5 => buf.gain;
buf.samples() => int samples;
buf => Control.fxIn;
[
    // -0.5, -0.666, -0.75, -0.8, -1.0, -1.2, -1.333, -1.5, -2.0,
    // 0.5, 0.666, 0.75, 0.8, 1.0, 1.2, 1.333, 1.5, 2.0

    // major? key
    // 0.5, 0.5625, 0.625, 0.665, 0.75, 0.8335, 0.875,
    // 1, 1.125, 1.25, 1.3333, 1.5, 1.6667, 1.75,
    0.5, 1, 1.25, 1.3333, 1.5, 1.75, 2
    -0.5, -1, -1.25, -1.3333, -1.5, -1.75, -2
] @=> float speeds[];

0 => float choice;
0 => int note;

while ( 1 ) {
    Control.beatLength::samp => now;
    speeds[ Math.random2(0, speeds.cap() - 1 ) ] => choice;

    choice => buf.rate;
}
