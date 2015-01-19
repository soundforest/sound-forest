SndBuf buf => Gain g;
g => Control.leftOut;
g => Control.rightOut;
buf => Control.fxIn;

0.9 => g.gain;

me.dir() + "audio/one-shot/heartbeat.wav" => buf.read;
( 60.0 / 75.0 * 44100 ) $ int => int beat_length;
<<< beat_length >>>;

while ( true ) {
    buf.samples()::samp => now;
    beat_length - buf.samples() => int new_length;
    new_length::samp => now;
    0 => buf.pos;
}
