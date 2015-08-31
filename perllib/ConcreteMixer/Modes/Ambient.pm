package SoundForest::Mode::Ambient;
use base SoundForest::Mode;
use strict;
use warnings;
use 5.10.0;
use List::Util;
use Data::Dump qw(dump);
my $data = {};

sub new {
    my ( $class, $config ) = @_;
    my $self = {};
    bless $self, $class;
    $self->{config} = $config;

    # do a bit of dying if config is nonsensical
    die "play_sounds value not specified" if not $config->{play_sounds};
    die "play_sounds_main_path not specified" if not $config->{play_sounds_main_path};

    if ( $config->{play_sounds_alt_path} and $config->{play_sounds} == 1 ) {
        $config->{play_sounds} = 2;
        say "Setting play_sounds to 2 as play_sounds_alt_path specified";
    }

    $self->{play_files_main} = $self->get_files_list( $config->{play_sounds_main_path} );
    die 'No main files present' if not scalar $self->{play_files_main};

    if ( $config->{play_sounds_alt_path} ) {
        $self->{play_files_alt} = $self->get_files_list( $config->{play_sounds_alt_path} );
        die 'No alt files present' if not scalar $self->{play_files_alt};
    }

    $self->{libpath} = 'lib/Modes/Ambient';
    $self->{fxChains} = $self->build_fxchains;
    $self->{playing_count} = 0;

    my $count = 0;

    while ( $count < $config->{play_sounds} ) {
        $count++;

        if ( $self->{play_files_alt} and $count == $config->{play_sounds} ) {
            $self->play_sound( 'alt' );
            next;
        }

        $self->play_sound;
    }

    if ( $config->{fx_chain_enabled} ) {
        my $fxChain = $self->get_fxchain;
        system( "$config->{chuck_path} + $self->{libpath}/playFxChain.ck:$fxChain" );
    }

    $data = $self;
    return $self;
}

# the OSC server callback
# processes messages back from playSound.ck and playFx.ck and respawns
# those processes until no sounds are left to play
sub process_osc_notifications {
    my ( $sender, $message ) = @_;
    my $self = $data;

    # first consider if we should serve the request or if there's
    # * a memory usage issue requiring process to end
    # * no more sounds to play and the last sound has finished playing
    if (
        $self->end_check # check for excess memory use
        # or if there's no sounds left to play
        or ( not $self->sounds_left and not $self->{playing_count} )
    ) {
        # don't do whatever you were going to do, fade out and either
        # end or reinitialise program
        $self->end;
    }

    # if we aren't already in a restart process or we've
    # discovered we need to kick off a restart process, carry on...
    if ( $message->[0] eq 'playSound' ) {
        my $type = $message->[2]; # should be 'main' or 'alt

        # decrement playing count as we know file has finished playing
        $self->{playing_count}--;

        if ( $self->sounds_left ) {
            $self->play_sound( $type );
        }
    }

    if ( $message->[0] eq 'playFxChain' ) {
        print "Got playFxChain notification, regenerating\n";
        my $fxChain = $self->get_fxchain;
        system( qq{$self->{config}{chuck_path} + $self->{libpath}/playFxChain.ck:$fxChain});
    }
}

sub sounds_left {
    my ( $self ) = @_;

    # determine how many files are left
    my $count = scalar @{ $self->{play_files_main} };

    if ( defined $self->{play_files_alt} and scalar @{ $self->{play_files_alt} } ) {
        $count += scalar @{ $self->{play_files_alt} };
    };

    return $count;
}

sub end {
    my ( $self ) = @_;

    if ( $self->{config}{endless_play} ) {
        say "REINITIALISING\n";
        $self->reinitialise();
    }
    else {
        $self->kill_master_pid();
        say "EXITING";
        exit;
    }
}

sub build_fxchains {
    my $self = shift;
    my @arr;

    if ( $self->{config}{rpi} ) {
        @arr = ( 1..16 );
    }
    else {
        @arr = ( 1..25 );
    }

    @arr = List::Util::shuffle @arr;

    return \@arr;
}

sub get_fxchain {
    my $self = shift;

    if ( not scalar @{ $self->{fxChains} } ) {
        $self->{fxChains} = $self->build_fxchains;
    }

    return pop @{ $self->{fxChains} };
}

sub play_sound {
    my ( $self, $type) = @_;

    $type //= 'main';
    say $type;
    chdir $self->{config}{cwd};
    my $filename;

    # get file to play
    # in the normal run of things, play_sound only gets called
    # when we know there's at least one file to play
    if ( $type eq 'alt' ) {
        $filename = pop @{ $self->{play_files_alt} };

        # if we've run out of files, try the 'main' pool
        if ( not $filename ) {
            $self->play_sound;
            return;
        }
    }
    else {
        $filename = pop @{ $self->{play_files_main} };

        # if we've run out of files, try the 'alt' pool
        if ( not $filename ) {
            $self->play_sound('alt');
            return;
        }
    }


    print "playSound playing $filename\n";
    my $command = "$self->{config}{chuck_path} + $self->{libpath}/playSound.ck:" . '"' . $filename . '"';

    if ( $type eq 'alt' ) {
        $command .= ":alt";
    }

    system( $command );
    $self->{playing_count}++;
}

1;
