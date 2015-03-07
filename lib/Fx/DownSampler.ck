// Pinched from https://ccrma.stanford.edu/~spencer/publications/CCC2012.pdf
// Annotated to make more sense to me
public class DownSampler extends Chugen {
    8 => int bits;
    2 => int decimation;
    float sample;
    int count;
    Math.pow(2,31) => float fINT_MAX;

    fun float tick(float in) {
        // if count equals downsample, set the current input to sample
        // means that downsample number of ticks will have the same value
        // reducing bandwidth
        if(count++ % decimation == 0 ) {
            // ensure sample within bounds when setting
            // Math.min(1,Math.max( -1, in )) => sample;
            in => sample;
        }

        // convert from -1 - 1 float to 32bit int
        (sample * fINT_MAX) $ int => int q32;

        32 - bits => int bitShift;

        // perform bitwise operations on value to lowe resolution
        // and then restore
        ((q32 >> bitShift) << bitShift) => q32;

        return q32 / fINT_MAX;
    }

    fun void decimate( int decimateInput ) {
        decimateInput => decimation;
    }

    fun void bittage( int bittageInput ) {
        bittageInput => bits;
    }
}
