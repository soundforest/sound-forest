package SoundForest::Mode::Ambient;
use base SoundForest::Mode;
use Data::Dump qw(dump);

sub new {
    my ( $class, $config ) = @_;
    my $self = {};
    bless $self, $class;
    $self->{config} = $config;
    $self->{play_files} = $self->get_files_list( $config->{play_sounds_path} );

    my $count = 0;

    while ( $count < $config->{play_sounds} ) {
        my $filename = pop @{ $self->{play_files} };
        print "playSound playing $filename\n";
        system( "$config->{chuck_path} + lib/Modes/Ambient/playSound.ck:" . '"' . $filename . '"');
        $count++;
    }

    if ( $config->{fx_chain_enabled} ) {
        system( "$config->{chuck_path} + lib/Modes/Ambient/playFxChain.ck" );
    }
    return $self;
}

sub process_osc_notifications {
    my ( $self, $sender, $message ) = @_;
    my $config = $self->{config};

    if ( $ending ) {
        if ( $message->[0] eq 'fadeOutComplete' ) {
            $count = 0;

            if ( $config->{endless_play} ) {
                print "REINITIALISING\n";
                reinitialise();
            }
        }
        else {
            print "WAITING FOR FADEOUT\n";
            # do nothing; wait for fadeMix.ck to return an OSC signal

            return;
        }
    }

    if ( $self->end_check() ) {
        # don't do whatever you were going to do, fade out and reinitialise
        # program
        $ending = 1;
        print "FADING OUT\n";
        system( "$config->{chuck_path} + fadeMix.ck" );
        return;
    }

    # if we aren't already in a restart process or we've
    # discovered we need to kick off a restart process, carry on...
    if ( $message->[0] eq 'playSound' ) {
        chdir $cwd;

        if ( ! @play_sound_files ) {
            $ending = 1;
            system( "$config->{chuck_path} + fadeMix.ck" );
        }
        else {
            my $filename = pop @play_sound_files;
            print "Got playSound notification, playing $filename\n";
            system( "$config->{chuck_path} + playSound.ck:" . '"' . $filename . '"');
        }
    }

    if ( $message->[0] eq 'playFxChain' ) {
        print "Got playFxChain notification, regenerating\n";
        system( "$config->{chuck_path} + playFxChain.ck" );
    }
}


1;
