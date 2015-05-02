public class ReverseDelay extends Chugen {
    float readArray[0];
    float writeArray[0];
    int readCount;
    int writeCount;
    1 => float increment;
    float sample;
    int tickCount;

    fun void delay( int size ) {
        readArray.size( size );
        writeArray.size( size );
        size - 1 => readCount;

        if ( writeCount > writeArray.size() - 1 ) {
            writeArray.size() - 1 => writeCount;
        }
    }

    fun float tick( float in ) {
        tickCount++;

        // if readArray.size(), delay() has not been called
        // do nothing
        if ( ! readArray.cap() ) {
            return in;
        }

        in => writeArray[ writeCount ];
        readArray[ readCount ] => sample;

        if ( increment < 1 ) {
            ( 1 / increment ) $ int => int span;

            if ( tickCount % span == 0 ) {
                readCount--;
            }
        }
        else {
            increment $ int -=> readCount;
        }

        writeCount++;

        if ( readCount <= 0 ) {
            readArray.cap() - 1 => readCount;
        }

        if ( writeCount == writeArray.cap() ) {
            switchArrays();
        }

        return sample;
    }

    fun void setIncrement( float value ) {
        value => increment;
    }

    fun void switchArrays() {
        <<< "Switching" >>>;
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
