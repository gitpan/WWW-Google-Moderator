#!perl

use strict; use warnings;
use WWW::Google::Moderator;
use Test::More tests => 4;

my ($api_key, $moderator);
$api_key   = 'Your_API_Key';
$moderator = WWW::Google::Moderator->new($api_key);

eval { $moderator->get_topic_detail(); };
like($@, qr/0 parameters were passed to WWW\:\:Google\:\:Moderator\:\:get_topic_detail/);

eval { $moderator->get_topic_detail('abcde'); };
like($@, qr/Parameter \#1 \(\"abcde\"\) to WWW\:\:Google\:\:Moderator\:\:get_topic_detail did not pass/);

eval { $moderator->get_topic_detail(12345, 'abcde'); };
like($@, qr/Parameter \#2 \(\"abcde\"\) to WWW\:\:Google\:\:Moderator\:\:get_topic_detail did not pass/);

eval { $moderator->get_topic_detail('abcde', 12345); };
like($@, qr/Parameter \#1 \(\"abcde\"\) to WWW\:\:Google\:\:Moderator\:\:get_topic_detail did not pass/);