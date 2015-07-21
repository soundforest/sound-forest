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
    $self->{play_files} = $self->get_files_list( $config->{play_sounds_path} );
    $self->{libpath} = 'lib/Modes/Ambient';
    $self->{fxChains} = $self->build_fxchains;
    $self->{playing_count} = 0;

    my $count = 0;

    while ( $count < $config->{play_sounds} ) {
        $self->play_sound;
        $count++;
    }

    if ( $config->{fx_chain_enabled} ) {
        my $fxChain = $self->get_fxchain;
        system( "$config->{chuck_path} + $self->{libpath}/playFxChain.ck:$fxChain" );
    }

    $data = $self;
    return $self;
}

sub process_osc_notifications {
    my ( $sender, $message ) = @_;
    my $self = $data;
    my $config = $self->{config};

    if ( $self->{ending} ) {
        if ( $message->[0] eq 'fadeOutComplete' ) {
            my $count = 0;

            if ( $config->{endless_play} ) {
                say "REINITIALISING\n";
                $self->reinitialise();
            }
            else {
                $self->kill_master_pid();
                say "EXITING";
                exit;
            }
        }
        else {
            print "WAITING FOR FADEOUT\n";
            # do nothing; wait for fadeMix.ck to return an OSC signal

            return;
        }
    }

    if ( $self->end_check ) {
        # don't do whatever you were going to do, fade out and reinitialise
        # program
        $self->{ending} = 1;
        print "FADING OUT\n";
        system( qq{$config->{chuck_path} + fadeMix.ck} );
        return;
    }

    # if we aren't already in a restart process or we've
    # discovered we need to kick off a restart process, carry on...
    if ( $message->[0] eq 'playSound' ) {
        # decrement playing count as we know file has finished playing
        $self->{playing_count}--;
        say 'After sound finished: ' . $self->{playing_count};

        if ( not @{ $self->{play_files} } ) {
            if ( not $self->{playing_count} ) {
                $self->{ending} = 1;
                system( qq{$config->{chuck_path} + fadeMix.ck} );
            }
        }
        else {
            $self->play_sound;
        }
    }

    if ( $message->[0] eq 'playFxChain' ) {
        print "Got playFxChain notification, regenerating\n";
        my $fxChain = $self->get_fxchain;
        system( qq{$self->{config}{chuck_path} + $self->{libpath}/playFxChain.ck:$fxChain});
    }
}

sub build_fxchains {
    my $self = shift;
    my @arr;

    if ( $self->{config}{rpi} ) {
        @arr = ( 1..24 );
    }
    else {
        @arr = ( 1..14 );
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
    my $self = shift;

    chdir $self->{config}{cwd};
    my $filename = pop @{ $self->{play_files} };
    print "playSound playing $filename\n";
    system( "$self->{config}{chuck_path} + $self->{libpath}/playSound.ck:" . '"' . $filename . '"');
    $self->{playing_count}++;
    say 'After sound play started: ' . $self->{playing_count};
}

1;
