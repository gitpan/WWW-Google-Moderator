#!perl

use strict; use warnings;
use WWW::Google::Moderator;
use Test::More tests => 2;

my ($api_key, $moderator);
$api_key   = 'Your_API_Key';
$moderator = WWW::Google::Moderator->new($api_key);

eval { $moderator->get_series_detail(); };
like($@, qr/0 parameters were passed to WWW\:\:Google\:\:Moderator\:\:get_series_detail/);

eval { $moderator->get_series_detail('abcde'); };
like($@, qr/Parameter \#1 \(\"abcde\"\) to WWW\:\:Google\:\:Moderator\:\:get_series_detail did not pass/);