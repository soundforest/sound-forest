# Concrète Mixer

## About

Concrète Mixer is an ambient jukebox system. Its intent is to randomly one or more sound recordings with an a randomly assembled, frequently changing effects chain. No two renderings of a set of sounds will be the same.

Concrète Mixer may be run continuously on a Raspberry Pi and, when hooked up loudspeakers, will haunt any space of your choosing.

### What does it sound like?

A ten minute demo may be evaluated here: https://soundcloud.com/concrete-mixer/concrete-mixer-demo

### What's it written in?

The audio processing is written in [ChucK](http://chuck.cs.princeton.edu). A [Perl](http://www.perl.org) script (with supporting libraries) takes care of the execution and process restarts.

## Prerequisites

Strictly speaking, the only prequisite is a system which supports both Perl and ChucK. In practice, the Concrete Mixer was developed in Linux (Ubuntu and Raspbian). A Raspberry Pi 2 Model B is the target device. Earlier Pi models *may* work with overclocking and configuration restraints applied.

## Installation and operation

1. The first thing you'll need is a set of sound files you want the software to mix. If you don't happen to have a collection of sound files you want to play, your best bet for this is to download files from [SoundCloud](http://soundcloud.com) or [FreeSound](https://freesound.org). From experience sound files from about 90 seconds to two and a half minutes seem to work best, but it depends on the dynamics of the recording.

2. Visit https://github.com/concrete-mixer/concrete-mixer and click the 'Download ZIP' link on the right hand side of the page.
3. Unzip the code:
``$ unzip concrete-mixer-master.zip``
4. In the conf/ directory in the root concrete-mixer directory set up the configuration files from their templates:
``$ cp conf/global.conf.sample conf/global.conf``
``$ cp conf/concrete.conf.sample conf/concrete.conf``

5. Edit conf/concrete.conf and specify a directory location for your sounds:
``play_sounds_main_path=<insert your dir here>``
Note that you can also supply a second directory (the play_sounds_alt_path) for sounds that you don't want to be played against each other; instead these sounds will be mixed with the 'main' sounds.
concrete.conf provides several other configuration options for tuning the app.

6. It's nearly time to start the app. Before you can do so, however, you need to make a Perl environment setting:
``$ export PERL5LIB=.:perllib``
To make this permanent, run:
``$ echo export PERL5LIB=.:perllib >> ~/.bashrc``
(This assumes that you're using bash as your shell.)

7. Run the app typing the following from your app's directory:
``./init.pl``

### Making a Raspberry Pi a concrète mixing machine

The intention of Concrète Mixer is to turn a Pi into a single-purpose sound that may be left to run without any supervision indefinitely (speakers not included). You don't have to do this, but if you'd like to, here's what you do:

1. Edit ``/etc/inittab`` using your favorite editor (here assuming nano):
    ``sudo nano /etc/inittab``. (Ultimately you'll want to use your own files.)
    Enter your password if required.
2. Search for the line ``1:2345:respawn:/sbin/getty 115200 tty1`` and comment it out by adding a ``#`` character at the start of line.
3. Add the following code beneath the commented out line:

    ``1:2345:respawn:/bin/login -f pi tty1 </dev/tty1 >/dev/tty1 2>&1``

    This line sets tty1 (the system's terminal number 1) to log in the pi user automatically on boot.

2. Edit the /home/pi/.bashrc file to get the pi to run Concrète Mixer: ``nano /home/pi/.bashrc``.

3. At the bottom of the file, add the following lines:
    <code>
        export PERL5LIB=<insert your path to concrete mixer dir here>/perllib

        if [ $(tty) == /dev/tty1 ]; then
            cd ~/concrete-mixer
            perl init.pl
        fi
    </code>
The first line sets the $PERL5LIB environment variable automatically (mentioned above). The subsequent lines invoke Concrète Mixer if the current terminal is tty1 only. This means you can run the program in one terminal and can perform other tasks in other terminals.

## General discussion

### Constraints

* You should mix the samples' levels to be generally consistent so that any one sample should not be disproportionately louder than any other. This can be time-consuming process. The author has found the normalize-audio utility in linux to be useful for shunting sounds up or down by 3-6dB
* The Pi's analogue audio output is terrible; if possible use an HDMI audio splitter (preferably powered). A separate USB sound card may also be helpful.
* The chuck binary distributed with Concrète Mixer was compiled against the September 2013 version of Raspbian.

#### Running Concrète Mixer on other devices

You should be able to run Concrète Mixer on OSX without much trouble; on Windows things will be much trickier.
* [Information on how to install ChucK on various platforms](http://chuck.cs.princeton.edu/release)
* [Information on how to install Perl on various platforms](http://www.perl.org/get.html)

Note that on other platforms the chuck executable included with Concrète Mixer will not work as it has been compiled for the Pi (and Raspbian). To use Concrète Mixer on other platforms you'll need to change the conf/global.conf file to point to a different ChucK executable (read the config file for more details).

## Licence

This code is distributed under the GPL v2. See the COPYING file for more details. The ChucK binary is also GPLv2. The included Perl code is also GPL.

## Acknowledgments

* The [Chuck authors](http://chuck.cs.princeton.edu/doc/authors.html), especially for giving me their blessing to include the chuck binary with this program, since ChucK itself has no (up to date) Debian package.
* Christian Renz, who authored the [Net::OpenSoundControl](http://search.cpan.org/~crenz/Net-OpenSoundControl-0.05/lib/Net/OpenSoundControl.pm) Perl module
* Jonny Schulz, who authored the [Sys::Statistics::Linux](http://search.cpan.org/~bloonix/Sys-Statistics-Linux/lib/Sys/Statistics/Linux.pm) Perl module

## Contact
* <concrete-mixer-audio@gmail.com>
