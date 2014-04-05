Fader fader;

fader.fadeOut( 10::second, Control.leftOut );
fader.fadeOut( 10::second, Control.rightOut );
10::second => now;

Control.oscSend.startMsg("fadeOutComplete", "i");
1 => Control.oscSend.addInt;
