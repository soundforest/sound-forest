public class ReverseDelay extends Chugen {
    float readArray[0];
    float writeArray[0];
    int readCount;
    int writeCount;
    float sample;

    fun void delay( int size ) {
        readArray.size( size );
        writeArray.size( size );
        size - 1 => readCount;
    }

    fun float tick( float in ) {
        // if readArray.size(), delay() has not been called
        // do nothing
        if ( ! readArray.cap() ) {
            return in;
        }

        in => writeArray[ writeCount ];
        readArray[ readCount ] => sample;
        writeCount++;
        readCount--;

        if ( writeCount == writeArray.cap() ) {
            switchArrays();
        }

        return sample;
    }

    fun void switchArrays() {
        float tempArray[];

        // switch arrays
        readArray @=> tempArray;
        writeArray @=> readArray;
        tempArray @=> writeArray;

        // reset counts
        0 => writeCount;
        readArray.cap() - 1 => readCount;
    }
}
