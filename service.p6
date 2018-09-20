use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;

my $host = '0.0.0.0';
my $port = 20000;

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => $host ||
        die("Missing SERVICES_HOST in environment"),
    port => $port ||
        die("Missing SERVICES_PORT in environment"),
    application => routes(),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);
$http.start;
say "Listening at http://$host:$port";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
