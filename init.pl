#!/usr/bin/perl

#----------------------------------------------------------------------------
#    Sound Forest - an ambient sound jukebox for the Raspberry Pi
#
#    Copyright (c) 2014 Stuart McDonald  All rights reserved.
#        https://github.com/soundforest/sound-forest
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
#    U.S.A.
#----------------------------------------------------------------------------


use strict;
use warnings;
use List::Util;
use Cwd;
use Net::OpenSoundControl::Server;
use Sys::Statistics::Linux::MemStats;
use Sys::Statistics::Linux::Processes;

my $config = get_config();

# determine if we have minimum settings to kick things off
if (
    not defined $config->{path_to_chuck}
    or not defined $config->{source_files}
) {
    die "Insufficient settings to run program. Does config file exist and contain settings? See sample-config for details";
}

my $flush_dir = $config->{cwd};
my $audio_path = $flush_dir . '/' . $config->{source_files};
my $restarting = 0;

chdir $flush_dir;

my @source_files = get_files_list();
my $osc_server = Net::OpenSoundControl::Server->new(
    Port => 3141,
    Handler => \&process_osc_notifications,
) or die "Could not start server: $@\n";


initialise();

# kick server listening off
$osc_server->readloop();

# execution ends here

sub initialise {
    # first initialise chuck environment
    my $bufsize = $config->{bufsize} || 4096;
    my $srate = $config->{srate} || 32000;

    system( "$config->{path_to_chuck} --loop --srate$srate --bufsize$bufsize &" );

    # sleeps give time for chuck to initliaise
    sleep 1;

    system( "$config->{path_to_chuck} + initialise.ck:\"$config->{bpm}\"" );

    # as above
    sleep 1;

    # initialise can be called when we don't have any @source_files left
    # so we need to check
    if ( ! @source_files ) {
        @source_files = get_files_list();
    }

    # If fx switched on in config, enable
    if ( $config->{fx_chain_enabled} ) {
        system( "$config->{path_to_chuck} + playFxChain.ck:" . '"' . $config->{fx_max_concurrent_effects} . '"' );
    }

    # kick off samples playback
    my $count = 0;

    while ( $count < $config->{concurrent_sounds} ) {
        my $file = pop @source_files;
        system( "$config->{path_to_chuck} + playSound.ck:" . '"' . $file . '"' );
        $count++;
    }

    if ( $config->{womb_simulator} ) {
        system( "$config->{path_to_chuck} + womb.ck" );
    }
}

# OSC 'server' process. Runs indefinitely
sub process_osc_notifications {
    my ( $sender, $message ) = @_;

    if ( $restarting ) {
        if ( $message->[0] eq 'fadeOutComplete' ) {
            print "REINITIALISING\n";
            reinitialise();
        }
        else {
            print "WAITING FOR REINITIALISATION CALL\n";
            # do nothing; wait for fadeMix.ck to return an OSC signal

            return;
        }
    }

    if ( restart_check() ) {
        # don't do whatever you were going to do, fade out and reinitialise
        # program
        $restarting = 1;
        print "FADING OUT\n";
        system( "$config->{path_to_chuck} + fadeMix.ck" );
        return;
    }

    # if we aren't already in a restart process or we've
    # discovered we need to kick off a restart process, carry on...
    if ( $message->[0] eq 'playSound' ) {
        chdir $flush_dir;

        if ( ! @source_files ) {
            $restarting = 1;
            system( "$config->{path_to_chuck} + fadeMix.ck" );
            system( "$config->{path_to_chuck} + testSine.ck" );
        }

        my $filename = pop @source_files;
        print "Got playSound notification, playing $filename\n";
        system( "$config->{path_to_chuck} + playSound.ck:" . '"' . $filename . '"');
    }

    if ( $message->[0] eq 'playFxChain' ) {
        print "Got playFxChain notification, regenerating\n";
        system( "$config->{path_to_chuck} + playFxChain.ck:" . '"' . $config->{fx_max_concurrent_effects} . '"' );
    }
}

sub reinitialise {
    print "Reinitialising sound forest $restarting\n";
    $restarting = 0;

    system( "$config->{path_to_chuck} + testSine.ck" );

    my $chuck_master_pid = get_chuck_master_pid();

    my $result = `kill $chuck_master_pid`;

    # killing should happen silently
    if ( $result ) {
        die "Could not stop chuck process: $!";
    }

    initialise();
}

sub get_files_list {
   my $glob_target = $config->{source_files} . '/*.wav';
   @source_files = glob( $glob_target );
   @source_files = List::Util::shuffle( @source_files );
   return @source_files;
}

sub restart_check {
    my $lxsm  = Sys::Statistics::Linux::MemStats->new;
    my $mem_stats = $lxsm->get;

    # need to get values to common factor for comparison
    # easiest seems to be choose k(ibi)bytes, even if mem_stats
    # are originally calculated as mega rather than mibi bytes
    my $realfree = $mem_stats->{realfree} * 1024;
    my $memtotal = $mem_stats->{memtotal} * 1024;

    my $page_size = `getconf PAGE_SIZE`;

    my $chuck_master_pid = get_chuck_master_pid();

    my $lxsp = Sys::Statistics::Linux::Processes->new(
        pages_to_bytes => $page_size,
        pids => [ $chuck_master_pid ]
    );

    $lxsp->init;
    my $stat = $lxsp->get;
    my $chuck_resident_mem_used = $stat->{ $chuck_master_pid }{resident};

    # sound forest leaks memory. The code has been rationalised somewhat,
    # but leakage seems to be increasing at a rate of about 1MB per playSound
    # and playFxChain cycle. I'm not sure why this is happening, but I'm guessing
    # the persistent use of the sound bus in the Control class is the source.
    # Independent instances of playSound do not leak, for example.
    #
    # The ChucK mailing list and documentation is vague about memory management
    # and garbage collection, but it looks like this issue isn't going to be
    # resolved any time soon, so we'll have to go with outside intervention to
    # manage memory buildup.
    #
    # One of the primary goals of Sound Forest is for it to run indefinitely, so
    # we need to ensure that the memory leakage doesn't bring down the system.
    #
    # There are three scenarios in which Sound Forest should be restarted
    # 1 when the sample queue has been exhausted (as a polite housekeeping
    #   exercise, not managed here)
    # 2 when the chuck process has used more than 50% of system memory
    # 3 when more than 80% of memory has been utilised, to stop chuck bringing
    #   down the system
    #
    # Sound forest is intended as a single use device (ie, nothing other than
    # system processes should be utilising resources) but it seems polite
    # nontheless to assume a limit of 50% of total resources, in the case
    # where a user decides to utilise some other software on their system - it is
    # their system. 50% memory equates to 256M on a Model B Pi, and 128M on a Model A. Unfortunately restarts are more
    # likely with longer samples, as samples lengths plus leakage are more likely
    # to tip the threshold.

    # scenario no.2
    if ( $memtotal / 2 < $chuck_resident_mem_used ) {
        print "Restarting sound forest (free memory below 20%)\n";
        return 1;
    }

    # scenario no. 3
    if ( $realfree * 5 < $memtotal ) {
        print "Restarting sound forest (chuck process using more than 50% system memory)\n";
        return 1;
    }

    return 0;
}

sub get_chuck_master_pid {
    my @process_results = `ps aux | grep 'chuck --loop'`;

    foreach my $process ( @process_results ) {
        my @frags = split(/\s+/, $process);

        if ( $frags[ -3 ] eq '--loop' ) {
            return $frags[1];
        }
    }
}

sub get_config {
    open( my $fh, './config' ) or die "Cannot open config file";
    my @config_rows = <$fh>;

    # define config hashref with reasonable defaults
    my $config = {
        concurrent_sounds => 2,
        fx_chain_enabled => 1,
        fx_max_concurrent_effects => 2,
    };

    foreach my $row ( @config_rows ) {
        next if ( $row =~ /^(#|\n$)/ );
        chomp $row;
        my ( $key, $value ) = split( '=', $row );
        $config->{$key} = $value;
    }

    $config->{cwd} = cwd();
    close $fh;
    return $config;
}
