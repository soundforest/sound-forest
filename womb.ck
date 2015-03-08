Control.bpm => float bpm;
Fader fader;

SndBuf buf => Gain g;
0 => buf.gain;
buf => Control.leftOut;
buf => Control.rightOut;

buf => Control.fxIn;

Noise noise => LPF lpf => dac;
200 => lpf.freq;
0 => noise.gain;


me.dir() + "audio/heartbeat.wav" => buf.read;
( 60.0 / bpm * Control.srate ) $ int => int beat_length;

fader.fadeIn( 5::second, 0.7, buf );
fader.fadeIn( 5::second, 0.1, noise );

while ( true ) {
    buf.samples()::samp => now;
    beat_length - buf.samples() => int new_length;
    new_length::samp => now;
    0 => buf.pos;
}
