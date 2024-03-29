use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'WWW::Google::Moderator',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/WWW/Google/Moderator.pm',
    ABSTRACT_FROM => 'lib/WWW/Google/Moderator.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'WWW-Google-Moderator-*' },
    PREREQ_PM     => {
        'Test::More'  => 0,
        'Readonly'    => '1.03',
        'Moose'       => '2.0006',
        'JSON'        => '2.15',
        'URI::Escape'      => '3.29',
        'HTTP::Request'    => '1.40',
        'LWP::UserAgent'   => '2.33',
        'namespace::clean' => '0.20',
        'MooseX::Params::Validate'     => '0.16',
        'Moose::Util::TypeConstraints' => '2.0006',
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);