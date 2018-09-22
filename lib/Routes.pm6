use Cro::HTTP::Router;
use Cro::HTTP::Router::WebSocket;

sub routes() is export {
    route {
        get -> {
            static 'static/index.html';
        }

        get -> 'sound_system' {
            static 'static/sound_system.html';
        }

        #get -> 'sound_system/info' {
        #    content json
        #    MAYBE INSTEAD OF THIS MAKE IT A TCP CONNECTION
        #}
        #

        #TODO: this only tracks right speaker volume
        get -> 'sound_system', 'info' {
            my %info = artist => 'Unknown', title => 'Unknown', volume => 'Unknown';
            my $output = q:x/cmus-remote -Q/;
            %info{"artist"} = $0.Str if ($output ~~ /tag \s* artist \s* (.*?)\n/);
            %info{"title"} = $0.Str if ($output ~~ /tag\s*title\s*(.*?)\n/);
            $output = q:x/pactl -- list sinks/;
            if ($output ~~ /Volume\: \s* front\-left\: \s*\d*\s* \/\s* (\d+)/) {
                my $vol = $0.Num;
                %info{"volume"} = $0.Str if ($vol <= 100 && $vol >= 0);
            }
            content 'application/json', %info;            
        }

        post -> 'sound_system', 'sound_control', Str $command, *@args {
            my $output = 'Bad control';
            given $command
            {
                when 'NEXT'          {$output = q:x/cmus-remote -n/;}
                when 'PREV'          {$output = q:x/cmus-remote -r/;}
                when 'PAUSE_PLAY'    {$output = q:x/cmus-remote -u/;}
                when 'CHANGE_VOLUME' {
                    my $vol = @args[0];
                    $output = qq:x/pactl -- set-sink-volume 0 $vol%/ if $vol ~~ /^(\d\d|100)$/;
                }
            }
        }

        get -> 'css', *@path {
            static 'static/css', @path
        }

        get -> 'js', *@path {
            static 'static/js', @path
        }
        my $chat = Supplier.new;
        get -> 'chat' {
            web-socket -> $incoming {
                supply {
                    whenever $incoming -> $message {
                        $chat.emit(await $message.body-text);
                    }
                    whenever $chat -> $text {
                        emit $text;
                    }
                }
            }
        }
    }
}
