package SoundForest::Mode;

use 5.10.0;
use strict;
use warnings;
use List::Util;
use Data::Dump qw(dump);
use List::Util;
use Cwd;
use Net::OpenSoundControl::Server;
use Sys::Statistics::Linux::MemStats;
use Sys::Statistics::Linux::Processes;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;

    $self->initialise;

    return $self;
}

sub initialise {
    my $self = shift;
    my $config = $self->get_config('conf/global.conf');

    # determine if we have minimum settings to kick things off
    if (
        not defined $config->{chuck_path}
        or not defined $config->{mode}
    ) {
        die "Insufficient settings to run program. Does config file exist and contain settings? See sample-config for details";
    }

    my $mconfig = $self->get_config( qq{conf/$config->{mode}.conf} );

    foreach my $key ( keys %{ $mconfig } ) {
        $config->{ $key } = $mconfig->{ $key };
    }

    $config->{cwd} = cwd();
    $self->{config} = $config;

    # first initialise chuck environment
    my $bufsize = $config->{bufsize} || 4096;
    my $srate = $config->{srate} || 32000;


    system( "$config->{chuck_path} --loop --srate$srate --bufsize$bufsize &" );
print "YIKES\n";
    # sleeps give time for chuck to initliaise
    # sleep 1;
    my $mode = ucfirst( $config->{mode} );

    system( qq{ $config->{chuck_path} + lib/Modes/$mode/$mode.ck:"$config->{bpm}":"$srate" & });
print "DOUBLE YIKES\n";

    # as above
    # sleep 1;
    my $mod_name = "SoundForest::Mode::$mode";
    my $req_name = "perllib/SoundForest/Modes/$mode.pm";
    require "$req_name"; 1;
    $obj = $mod_name->new( $config );
    $self->{mode} = $obj;
    $self->start_osc_server;
}

sub start_osc_server {
    my $self = shift;

    $self->{osc_server} = Net::OpenSoundControl::Server->new(
        Port => 3141,
        Handler => $self->{mode}->can('process_osc_notifications'),
    ) or die "Could not start OSC server: $@\n";

    # $self->{osc_server}->readloop();
}

sub reinitialise {
    kill_master_pid();

    initialise();
}

sub kill_master_pid {
    my $self = shift;
    print "Reinitialising sound forest\n";

    my $chuck_master_pid = $self->get_chuck_master_pid();

    my $result = `kill $chuck_master_pid`;

    # killing should happen silently
    if ( $result ) {
        die "Could not stop chuck process: $!";
    }
}

sub get_files_list {
    my ( $self, $path ) = @_;
    my $glob_target = $path . '/*.wav';
    my @source_files = glob( $glob_target );
    @source_files = List::Util::shuffle( @source_files );
    return \@source_files;
}

sub get_config {
    my ( $self, $path ) = @_;
    my $config = {};

    open( my $fh, $path ) or die "Cannot open config file";
    my @config_rows = <$fh>;

    foreach my $row ( @config_rows ) {
        next if ( $row =~ /^(#|\n$)/ );
        chomp $row;
        my ( $key, $value ) = split( '=', $row );
        $config->{ $key } = $value;
    }

    close $fh;
    return $config;
}

sub end_check {
    my $self = shift;

    my $lxsm  = Sys::Statistics::Linux::MemStats->new;
    my $mem_stats = $lxsm->get;

    # need to get values to common factor for comparison
    # easiest seems to be choose k(ibi)bytes, even if mem_stats
    # are originally calculated as mega rather than mibi bytes
    my $realfree = $mem_stats->{realfree} * 1024;
    my $memtotal = $mem_stats->{memtotal} * 1024;

    my $page_size = `getconf PAGE_SIZE`;

    my $chuck_master_pid = $self->get_chuck_master_pid();

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
    # manage memory leakage
    #
    # One of the primary goals of Sound Forest is for it to run indefinitely, so
    # we need to ensure that the memory leakage doesn't bring down the system.
    #
    # There are three scenarios in which Sound Forest should be restarted:
    # 1. The sample queue has been exhausted (as a polite housekeeping
    #   exercise, not managed here)
    # 2. The chuck process itself has used more than 50% of system memory
    # 3. More than 80% of memory has been utilised (all processed), to stop
    # chuck bringing down the system.
    #
    # Sound Forest is intended as a single use device (ie, nothing other than
    # system processes should be utilising resources) but it seems polite
    # nontheless to assume a limit of 50% of total resources, in the case
    # where a user decides to utilise some other software on their system - it is
    # their system. 50% memory equates to 256M on a Model B Pi, and 128M on a Model A. Unfortunately restarts are more
    # likely with longer samples, as samples lengths plus leakage are more likely
    # to tip the threshold.

    # Scenario no.2
    if ( $memtotal / 2 < $chuck_resident_mem_used ) {
        print "ending sound forest (free memory below 20%)\n";
        return 1;
    }

    # Scenario no. 3
    if ( $realfree * 5 < $memtotal ) {
        print "ending sound forest (chuck process using more than 50% system memory)\n";
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

1;
