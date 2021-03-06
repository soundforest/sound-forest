public class SlideRate extends DiceSound {
    float endRate;

    fun string idString() { return "SlideRate"; }

    fun dur getDiceLength() {
        return c.getDur( 5, 20 );
    }

    fun void activity() {
        while ( active ) {
            c.getFloat( -2, 2 ) => float endRate;
            slideRateIterate( buf, 1, endRate);
            c.getIntervalLong()::second => now;
        }
    }

    fun void slideRateIterate( SndBuf buf, float slideTime, float endRate ) {
        slideTime / 100 => float timeIncrement;

        buf.rate() => float currentRate;
        float rateDiff;
        string direction;

        if ( endRate > currentRate ) {
            endRate - currentRate => rateDiff;
            "up" => direction;
        }
        else {
            currentRate - endRate => rateDiff;
            "down" => direction;
        }

        rateDiff / 100 => float rateIncrement;

        while ( slideTime > 0 ) {
            buf.rate() => float currRate;

            if ( direction == "up" ) {
                buf.rate( currRate + rateIncrement );
            }
            else {
                buf.rate( currRate - rateIncrement );
            }

            timeIncrement -=> slideTime;
            timeIncrement::second => now;
        }
    }

}
