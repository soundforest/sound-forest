# Sound Forest

## About

Sound Forest is an ambient jukebox program for the Raspberry Pi. It plays two different files simultaneously, while also feeding them through an independent effects chain. The files used and the effects used are arbitrary.

The intention of Sound Forest is to be a kind of aural kaleidoscope spinning out sounds in random combinations. The name Sound Forest is a metaphor whereby the app takes the user on a meandering walk through a forest of different sounds. Each walk is and therefore each perspective on the sounds is unique.

If you like ambient music or field recordings are are an inveterate mystic or dreamer, Sound Forest should be just your sort of thing. Alternatively, if you are interested in tinkering with audio programming and the Raspberry Pi generally, Sound Forest can be examined and altered.

### What does it sound like?

A ten minute demo may be evaluated here: https://soundcloud.com/sound-forestation/sound-forest-demo

### How does it work?

Once the software is installed all you copy your sample files (suitably formatted; see [Constraints](#user-content-constraints) below) to a directory called 'loops' in the audio directory of the Sound Forest install. You then run the program (see Installation), and sound should start playing, and continue to play until the execution is terminated.

### What's it written in?

The audio processing is written in [ChucK](http://chuck.cs.princeton.edu). A [Perl](http://www.perl.org) script takes care of the execution and process spawning.

## Prerequisites

* A Raspberry Pi. Sound Forest has only been tested with a Model B, but Model A *should* work, though it will run out of memory faster, and the app process will restart more often (see [Constraints](#user-content-constraints)).
* The Pi should be running the Raspbian operating system. This is the recommended linux distribution of the Raspberry Pi Foundation, and the only one Sound Forest was tested with. The ChucK binary might conceivably work with another Linux distro but there's a pretty good chance it won't.
* The Pi needs to be overclocked to 'high' setting. To do this:
    1. In a shell on the Pi, type ``sudo raspi-config``
    2. In the menu that displays, select option ``7 Overclock``
    3. Select the ``High 950MHz ...`` option. Save the changes and reboot the Pi.

    [Random web literature](http://www.maketecheasier.com/overclock-raspberry-pi) suggests overclocking to High setting is safe, and I've had no problems operating at this frequency, but doing this is at your own risk!

## Installation and operation

1. Visit https://github.com/soundforest/sound-forest and click the 'Download ZIP' link on the right hand side of the page. Save the zipfile to the pi user home directory (/home/pi).
2. Unzip and untar the tarball:
    unzip sound-forest-master.zip
3. A folder called sound-forest-master will be created. Change to that directory:
``$ cd sound-forest-master``
4. Copy the sample-config file to config
``$ cp sample-config config``
5. At this point the software should be good to go, but you'll need some sound samples to play. The author has provided a excerpts from his own library of field recordings that can be used to test the program. [Download the libray](https://archive.org/download/sound-forest-library/sound-forest-library.zip) and unzip the files into a directory called audio/loops in the sound-forest directory (you can specify a different path in the the ``config`` file. Ultimately you'll want to use your own files, or least augment the demo librarby with many more. Ideally you should have hundreds of files available, allowing for a lot of possible combinations of sounds.
6. Now it's time to run the app. Before you can do this you need to set an environment variable in the shell. Run the following command:
``$ export PERL5LIB=.:perllib``
    (This command lets Perl know where the library files used by the app reside.)
7. Finally, you should be able to run ``perl init.pl`` and Sound Forest will start running.

### Making Sound Forest run automatically

The intention of Sound Forest is to turn the Pi into a single-purpose sound generating box that can be plugged in to speakers and left to run without any supervision indefinitely. You don't have to do this, but if you'd like to, here's what you do:

1. Edit ``/etc/inittab`` using your favorite editor (here assuming nano):
    ``sudo nano /etc/inittab``.(Ultimately you'll want to use your own files.)
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
            perl init.pl
        fi
    </code>

    The first line sets the $PERL5LIB environment variable automatically. The subsequent lines invoke Sound Forest if the current terminal is tty1 only. This means you can run the program in one terminal and can perform other tasks in other terminals.

## General discussion

### Constraints

The Raspberry Pi's processor is not powerful; the Pi is the platform of choice for Sound Forest chiefly for its ubiquity and its modest price. ChucK is not the most performance-optimised language either. In short, compromises have had to be made to get as much possible out of Sound Forest:
    * ChucK's playback rate is constrained to 32Khz to save on CPU. Younger ears may note a loss of crispness at the very high end, but depending on the ambient noise levels of the setting this deficit in herzage may not be noticeable.
* To save on redundant processing, samples should be formatted mono 32Khz 16 bit. The app has been tested with PCM wav only, but AIF should also be supported.
* Mix the samples' levels to be generally consistent. This can be batch processed in lnux though there may be a difference between volume calculated by a computer and volume as perceived by the human ear. The demo samples were mixed with peaks around -6db to guarantee some headroom where FX chain might cause a frequency band to 'wig out'.
* Samples should not be more than about five minutes in length. There's two reasons for this:
    1. Sound Forest is constrained to use up to half of the available RAM only. After this ceiling is reached, the app is restarted. If large sound files are used, the greater the likelihood that the RAM limit will be reached - especially on a Model A pi, since the amount of RAM to play will be 128MB. In practice two 5 minute files comes to about 100MB, and if you factor in memory leakage it won't be long until the app gets restarted.
    2. Unless a recording has a lot of variety, short files featuring specific sound 'events' are better than long files, because short files increase variety across playback, whereas a longer file will need to more interesting to avoid blending into the listener's aural background. Some files may be able to do that, but you'll probably find that few files need to be longer than 3 minutes.
* The Pi's sound card is rather poor quality, providing the equivalent of 11 bit playback, with a pretty high noise ceiling. Depending on the quality of the source samples, this may be acceptable (or at least make little difference), but if you want to use something better you can connect a USB sound card or play Sound Forest through the Pi's HDMI output. Note that Sound Forest hasn't been tested with a USB sound card, and using one may increase system load and adversely affect playback.
* The Pi needs to be overclocked. (See [Installation](#user-content-installation).)
* The chuck binary distributed with Sound Forest was compiled against the September 2013 version of Raspbian. It has been tested against the January 2014 edition of Raspbian and still works.

### Aesthetics

The main goal of Sound Forest is to load the mix with as much variation as possible (in terms of the number of samples and the configuration of effects) that there will be as much freedom to surprise listeners with the resulting combinations of sound.

Because the choices made are random, and the app is blind to the characteristics of the sample being loaded, often the configuration chosen may not suit the sample. This may irritate listeners who are used to a more sensitive, conscious treatment of a sound in ambient music compositions.

This is a big problem, but when a sound combination does work out well, the result is *even more satisfying for knowing that it mightn't have been*. This aesthetic strategy may not appeal to everyone, but I think maximising the app's freedom by giving it as many possibilities as possible has been the way to go.

### Customising and extending Sound Forest

#### Customising

Sound Forest has a config file (called config) which includes a handful of settings. The file is annotated with comments, so have a read and see what you can alter. Note that you'll need to restart any existing Sound Forest process for changes to take effect.

#### Extending

Sound Forest is a series of simple scripts written in ChucK. If you're interested in electronic music programming it is relatively easy to learn ChucK and modify the Sound Forest scripts. Sound Forest itself is a very basic ChucK program, in terms of sound processing, but it does provide a reasonable trip around the language.

One quite straight forward extension of the app would be to use very short loops of sound (no more than two seconds). Using two or more loops concurrently will give the playback a very hypnotic feel. If you wanted to be even cleverer and carefully sync the sample lengths, you could create rhythm tracks. It would not be hard to think of a million tools better suited to beat production than Sound Forest, but if you want to try something different, it shouldn't be too hard.

#### Running Sound Forest on other devices

ChucK can be run in Windows, Linux, and OSX environments, and in principle (and with a Perl interpreter) Sound Forest can be operated in those environments too. Sound Forest was originally coded on a laptop running Ubuntu Linux, for example.
* [Information on how to install ChucK on various platforms](http://chuck.cs.princeton.edu/release)
* [Information on how to install Perl on various platforms](http://www.perl.org/get.html)

Note that on other platforms the chuck executable included with Sound Forest will not work as it has been compiled for the Pi (and Raspbian). To use Sound Forest on other platforms you'll need to change the config file to point to a different ChucK executable (read the config file for more details).

If you do wish to use Sound Forest on other systems it's likely you'll be using a device with greater processing power than the Paspberry Pi, and you may wish to change the playback settings in the ``config`` file to 44Khz (assuming 44Khz samples), and play more than two samples concurrently. You can also alter the program to to use stereo audio rather than mono for each stream, though this involves more work than merely altering the config file.

## Future development

Very broadly the project is complete, barring any bugs that sneak through at release time. If Sound Forest gets support through actual usage there's a lot more than could be done to extend the program, especially around the effects chain.

## Licence

This code is distributed under the GPL v2. See the COPYING file for more details. The ChucK binary is also GPLv2. The included Perl code is also GPL.

## Acknowledgments

* The [Chuck authors](http://chuck.cs.princeton.edu/doc/authors.html), especially for giving me their blessing to include the chuck binary with this program, since ChucK itself has no (up to date) Debian package.
* Christian Renz, who authored the [Net::OpenSoundControl](http://search.cpan.org/~crenz/Net-OpenSoundControl-0.05/lib/Net/OpenSoundControl.pm) Perl module
* Jonny Schulz, who authored the [Sys::Statistics::Linux](http://search.cpan.org/~bloonix/Sys-Statistics-Linux/lib/Sys/Statistics/Linux.pm) Perl module

## Contact
* <soundforestation@gmail.com>
