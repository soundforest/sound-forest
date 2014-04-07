# Sound Forest

## About

Sound Forest is an ambient jukebox program for the Raspberry Pi. It plays two different files simultaneously, while also feeding them through an independent effects chain. The files used and the effects used are arbitrary.

### Why would I want to listen to that?

If you like ambient music or field recordings are are an inveterate mystic or dreamer, you might be keen. If you are interested in tinkering with the Raspberry Pi and audio, examining and modifying Sound Forest might be a good way to learn.

The main intention though is for the app to play from a Pi through speakers into a room, so that random real world sounds fill up the space for as long as they are desired.

### What does it sound like?

A ten minute demo may be evaluated here: https://soundcloud.com/sound-forestation/sound-forest-demo

Feel underwhelmed? See the [Aesthetics](#user-content-aesthetics) section.

### How does it work?

Once the software is installed all you copy your sample files (suitably formatted; see [Constraints](#user-content-constraints) below) to a directory called 'loops' in the audio directory of the Sound Forest install. You then run the program (see Installation), and sound should start playing, and continue to play until the execution is terminated.

### What's it written in?

The audio processing is written in [ChucK](http://chuck.cs.princeton.edu). A [Perl](http://www.perl.org) script takes care of the execution and process spawning.

## Prerequisites

* A Raspberry Pi. Model B preferred (and tested on by the developer), but Model A *should* work, though it will run out of memory faster and the Sound Forest process will restart more often.
* Raspbian operating system. This is the recommended linux distribution of the Raspberry Pi Foundation, and the only one Sound Forest was tested with. The ChucK binary might conceivably work with another Linux distro but there's a pretty good chance it won't.
* The Pi needs to be overclocked to 'high' setting. To do this:
    1. In a shell on the Pi, type ``sudo raspi-config``
    2. In the menu that displays, select option ``7 Overclock``
    3. Select the ``High 950MHz ...`` option. Save the changes and reboot the Pi.

    Note that overclocking creates strain on the CPU and the SD card, and running in this mode may shorten the Pi's operating life. What literature I've read suggests High should be ok (though Turbo might be a bit iffy). For what it's worth I've had no problems running in High mode myself, for up to 36 hours. In any event, use at your own risk!

## Installation and operation

1. Visit https://github.com/soundforest/sound-forest (though you're probably already there) and click the 'Download ZIP' link on the right hand side of the page. Save the zipfile to the pi user home directory (/home/pi).
2. Unzip and untar the tarball:
    unzip sound-forest-master.zip
3. A folder called sound-forest-master will be created. Change to that directory:
``$ cd sound-forest-master``
4. Copy the sample-config file to config
``$ cp sample-config config``
5. At this point the software should be good to go, but you'll need some sound samples to play. The author has very kindly (he thinks) provided a library of field recordings that can be used to test the program. (Ultimately you'll want to use your own files.) [Download the libray](https://archive.org/download/sound-forest-library/sound-forest-library.zip) and unzip the files into a directory called audio/loops in the sound-forest directory.
6. Perl requires a run time variable set so it knows where to look for libraries included with Sound Forest. Run the following command:
``$ export PERL5LIB=.:perllib``
7. Finally, you should be able to run ``perl init.pl`` and Sound Forest will start running.

### Making Sound Forest run automatically

The intention of Sound Forest is to turn the Pi into a single-purpose sound generating box that can be plugged in to speakers and left to run without any supervision indefinitely. You don't have to do that, but if you'd like to make the Pi run Sound Forest on boots, here's what you do:

1. Edit ``/etc/inittab`` using your favorite editor (here assuming nano):
    ``sudo nano /etc/inittab``.
    Enter your password if required.
2. Search for the line ``1:2345:respawn:/sbin/getty 115200 tty1`` and comment it out by adding a ``#`` character at the start of line.
3. Add the following code beneath the commented out line:

    ``1:2345:respawn:/bin/login -f pi tty1 </dev/tty1 >/dev/tty1 2>&1``

    This line sets tty1 (the system's terminal number 1) to log in the pi user automatically on boot.

2. Edit the /home/pi/.bashrc file to get the pi to run Sound Forest: ``nano /home/pi/.bashrc``.

3. At the bottom of the file, add the following lines:

    <code>
        export PERL5LIB=/home/pi/sound-forest/perllib

        if [ $(tty) == /dev/tty1 ]; then
            cd ~/sound-forest
            perl ~/sound-forest/init.pl
        fi
    </code>

    The first line sets the $PERL5LIB environment variable automatically. The subsequent lines invoke Sound Forest if the current terminal is tty1 only. This means you can run the program in one terminal and can perform other tasks in other terminals.

## Discussion

This section rambles more generally about Sound Forest.

### Constraints

The Raspberry Pi's processor is not powerful; the Pi is the platform of choice for Sound Forest chiefly for its ubiquity and its modest price. ChucK is not the most performance-optimised language either. In short, compromises have had to be made to get as much possible out of Sound Forest:
* ChucK's playback rate is constrained to 32Khz to save on CPU. This means a 16KHz frequency range; for older ears this should be acceptable.
* Ideally, samples should be mono 32Khz 16 bit PCM wav, though the demo samples are formatted at 44.1Khz. When mixing stereo samples to mono be careful not to introduce phasing effects caused by spatial differentiation between the channels. I'm not sure that's actually a thing but I've found that sometimes taking one channel (I go with the channel with the spikier waveform) has a more satisfying result than mixing both channels together at 50% volume.
* Mix the samples' levels to be consistent with each other. This can be a nightmare. The test samples were mixed at quiet levels, with peaks around -6db to minimise the possibility of distortion from the Pi's ropey sound card, and to guarantee some headroom where FX filter effecs might see certain frequency bands balloon in volume. In short, for best results be conservative with gains and compress (dynamically) the signal if where there is big dynamic range between the loudest and quietest signals. Every recording has different properties. Good luck and God bless.
* Samples should not be more than about five minutes in length. There's two reasons for this:
    1. Sound Forest is constrained to use up to half of the available RAM only. After this ceiling is reached, the app is restarted. If large sound files are used, the greater the likelihood that the RAM limit will be reached - especially on a Model A pi, since the amount of RAM to play with is only 128MB. In practice two 5 minute files comes to about 100MB, and if you factor in memory leakage it won't be long until the app gets restarted.
    2. Unless a recording has a lot of variety, short files showcasing particular sounds are better than long files, because short files increase variety across playback, whereas a longer file will need to sustain interest for longer. Some files may be able to do that, but you'll probably find that view files need to be longer than 3 minutes.
* Use of mono samples might seem like a serious drawback, but single channels help to differentiate the two sources better and make for a less cluttered sound scape (esp after effects are applied).
* The Pi's sound card is rather poor quality, providing the equivalent of 11 bit playback, with a pretty high noise ceiling. Depending on the quality of the source samples, this may be acceptable (or at least make little difference), but if you want to use something better you can connect a USB sound card or play Sound Forest through the Pi's HDMI output. Note that Sound Forest hasn't been tested with a USB sound card, and using one may increase system load and adversely affect playback.
* The Pi needs to be overclocked. (See [Installation](#user-content-installation).)

### Aesthetics

The main goal of Sound Forest is to load the mix with as much variation as possible (in terms of the number of samples and the configuration of effects) that there will be as much freedom to surprise listeners with the resulting combinations of sound.

With this freedom there's a price: at any given point in Sound Forest's playback chances are good that the choices the program has made (samples selected, the effects chain parameters) will be sub-optimal. For example, one sample might swamp another, the frequency on a delay may be out of time with a rhythmic noise occurring in one of the samples. Or, for real reason, the outcome might just sound dull.

We could eliminate dullness by only using samples we know will always work well with all other samples. And we could used only an approved effects configuration known good will all samples, or define preset effects for different samples. And that would sound more consistently good, but it would also be a lot less interesting than if the path taken along the forest stumbled across something interesting.

So sometimes the mix will sound blah, and sometimes the mix will be intriguing. That's just how it is.

### Extending Sound Forest

Sound Forest is a series of simple scripts written in ChucK. If you're interested in learning electronic music programming it is relatively easy to learn ChucK (as long as you know the very basic principles of programing) and modify the program to do whatever you like. Note though that the current Sound Forest config produces system load at about the capacity of a Raspberry Pi, so you'll probably be wanting to use a laptop or even desktop system if you want to make the program do more work.

One quite straight forward extension would be use very short loops of sound (no more than two seconds). Using two or more loops concurrently will give the playback a very hypnotic feel. If you wanted to be even cleverer and carefully sync the sample lengths, you could create dance tracks. It would not be hard to think of a million tools better suited to beat production than Sound Forest, but if you want to try something different, it shouldn't be too hard.

### Running Sound Forest on other devices

ChucK can be run in Windows, Linux, and OSX environments, and in principle (and with a Perl interpreter) Sound Forest can be operated in those environments too. Sound Forest was originally coded on a laptop running Ubuntu Linux, for example.
* [Information on how to install ChucK on various platforms](http://chuck.cs.princeton.edu/release)
* [Information on how to install Perl on various platforms](http://www.perl.org/get.html)

If you do wish to use Sound Forest in this way it's likely you'll be using a device with greater processing power than the Paspberry Pi, you can extend the program to (for example) run more than two concurrent streams, or to use stereo files rather than mono.

## Future development

Very broadly the project is complete, barring any bugs that sneak through at release time. If Sound Forest gets support through actual usage there's a lot more than could be done to extend the program, especially around the effects chain.

## Licence

This code is distributed under the GPL v2. See the COPYING file for more details. The ChucK binary is also GPLv2. The included Perl code is also GPL.

## Acknowledgments

* The [Chuck authors](http://chuck.cs.princeton.edu/doc/authors.html), especially for giving me their blessing to include the chuck binary with this program, since ChucK itself has no (up to date) Debian package.
* Christian Renz, who authored the [Net::OpenSoundControl](http://search.cpan.org/~crenz/Net-OpenSoundControl-0.05/lib/Net/OpenSoundControl.pm) Perl module
* Jonny Schulz, who authored the [Sys::Statistics::Linux](http://search.cpan.org/~bloonix/Sys-Statistics-Linux/lib/Sys/Statistics/Linux.pm) Perl module

## Contact
<soundforestation@gmail.com>
