#!perl

use strict; use warnings;
use WWW::Google::Moderator;
use Test::More tests => 3;

my ($api_key, $moderator);
$api_key = 'Your_API_Key';

eval { $moderator = WWW::Google::Moderator->new(); };
like($@, qr/Attribute \(api_key\) is required/);

eval { $moderator = WWW::Google::Moderator->new({api_key => $api_key, prettyprint => 'trrue'}); };
like($@, qr/Attribute \(prettyprint\) does not pass the type constraint/);

eval { $moderator = WWW::Google::Moderator->new({api_key => $api_key, alt => 'jsoon'}); };
like($@, qr/Attribute \(alt\) does not pass the type constraint/);