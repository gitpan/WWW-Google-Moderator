#!perl

use strict; use warnings;
use WWW::Google::Moderator;
use Test::More tests => 6;

my ($api_key, $moderator);
$api_key   = 'Your_API_Key';
$moderator = WWW::Google::Moderator->new($api_key);

eval { $moderator->get_topics(); };
like($@, qr/Mandatory parameter 'series-id' missing in call to WWW\:\:Google\:\:Moderator\:\:get_topics/);

eval { $moderator->get_topics('abcde'); };
like($@, qr/The 'series-id' parameter \("abcde"\) to WWW\:\:Google\:\:Moderator\:\:get_topics did not pass/);

eval { $moderator->get_topics('series-id' => 'abcde'); };
like($@, qr/The 'series-id' parameter \("abcde"\) to WWW\:\:Google\:\:Moderator\:\:get_topics did not pass/);

eval { $moderator->get_topics('series-id' => 12345, 'max-results' => 101); };
like($@, qr/The 'max-results' parameter \("101"\) to WWW\:\:Google\:\:Moderator\:\:get_topics did not pass/);

eval { $moderator->get_topics('series-id' => 12345, 'max-results' => -1); };
like($@, qr/The 'max-results' parameter \("-1"\) to WWW\:\:Google\:\:Moderator\:\:get_topics did not pass/);

eval { $moderator->get_topics('series-id' => 12345, 'max-results' => 100, 'start-index' => -1); };
like($@, qr/The 'start-index' parameter \("-1"\) to WWW\:\:Google\:\:Moderator\:\:get_topics did not pass/);