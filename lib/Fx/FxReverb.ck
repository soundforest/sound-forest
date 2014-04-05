public class FxReverb extends Fx {
    // need to go with JCRev sadly
    // ( no disrespect to John Chowning )
    // to save some cycles on the pi
    JCRev rev;
    input => rev => output;

    fun string idString() { return "FxReverb"; }
}
