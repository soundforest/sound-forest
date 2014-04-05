public class FxFilter extends Fx {
    FilterBasic filter;
    LFO lfo;
    string oscType;
    float amount, lfoFreq, baseFilterFreq, Q;

    fun string idString() { return "FxFilter"; }

    fun void initialise() {
        chooser.getInt( 1, 2 ) => int typeChoice;

        // baseFilterFreq is base frequency for filter
        // may or may not end up being oscillated

        string filterChosen;

        if ( typeChoice == 1 ) {
            LPF lpf @=> filter;

            // for lpf, we want a lowish base freq
            "LPF" => filterChosen;
            chooser.getFloat( 700, 1500 ) => baseFilterFreq;
            chooser.getFloat( 5, 10 ) => Q;
        }

        if ( typeChoice == 2 ) {
            HPF hpf @=> filter;
            "HPF" => filterChosen;
            chooser.getFloat( 5, 10 ) => Q;
            chooser.getFloat( 1000, 2000 ) => baseFilterFreq;
        }

        input => filter => output;

        // set baseFilterFreq

        // set Q between 1 and 5
        Q => filter.Q;

        // determine whether to oscillate (mostly yes)
        if ( chooser.takeAction( 1 ) ) {
            // as a rule amount should be less than basefreq over 3
            chooser.getFloat( baseFilterFreq / 3, baseFilterFreq / 3 + baseFilterFreq / 6 ) => amount;

            // going with sine only for oscillation - square a bit annoying
            // and s/h a bit old fash
            "sine" => oscType;

            chooser.getFloat( 0.05, 0.5 ) => lfoFreq;

            // sample hold is better when its faster...
            if ( oscType != "sine" ) {
                lfoFreq * 20 => lfoFreq;
            }

            spork ~ activity();
        }
        <<< "   FxFilter:", filterChosen, "at", baseFilterFreq, "Hz", "q:", Q, "lfoFreq:", lfoFreq, "lfo amount:", amount >>>;
    }

    fun void activity() {
        while ( true ) {
            lfo.osc( lfoFreq, amount, oscType ) => float freqDelta;
            baseFilterFreq + freqDelta => filter.freq;
            100::ms => now;
        }
    }
}
