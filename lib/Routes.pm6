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

        get -> 'sound_system', 'sound_control_current_playing' {
            my %info = artist => 'Unknown', title => 'Unknown';
            my $output = q:x/cmus-remote -Q/;
            %info{"artist"} = $0.Str if ($output ~~ /tag \s* artist \s* (.*?)\n/);
            %info{"title"} = $0.Str if ($output ~~ /tag\s*title\s*(.*?)\n/);
            content 'application/json', %info;            
        }

        post -> 'sound_system', 'sound_control', Str $command {
            my $output = 'Bad control';
            given $command
            {
                when 'NEXT'         {$output = q:x/cmus-remote -n/;}
                when 'PREV'         {$output = q:x/cmus-remote -r/;}
                when 'PAUSE_PLAY'   {$output = q:x/cmus-remote -u/;}
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
