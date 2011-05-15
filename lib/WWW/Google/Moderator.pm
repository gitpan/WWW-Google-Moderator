package WWW::Google::Moderator;

use Moose;
use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use namespace::clean;

use Carp;
use Data::Dumper;

use JSON;
use Readonly;
use URI::Escape;
use HTTP::Request;
use LWP::UserAgent;

=head1 NAME

WWW::Google::Moderator - Interface to Google Moderator API.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
Readonly my $API_VERSION => 'v1';
Readonly my $BASE_URL    => "https://www.googleapis.com/moderator/$API_VERSION";

=head1 DESCRIPTION

This module is intended for anyone who wants to write applications that can  interact with the
Google Moderator API using REST.  Google  Moderator is a tool for collecting ideas, questions,
and  recommendations  from audiences of any size. Courtesy limit is 1,000,000 queries per day.
Currently it supports version v1.

Important:The version v1 of the Google Moderator API is in Labs, and its features might change
unexpectedly until it graduates.

=cut

type 'SortType'    => where { $_ =~ m(^\bRANK_DESCENDING\b
                                       |
                                       \bRANK_ASCENDING\b
                                       |
                                       \bHOT_DESCENDING\b
                                       |
                                       \bDATE_SUBMITTED_DESCENDING\b
                                       |
                                       \bDATE_SUBMITTED_ASCENDING\b$)ix };
type 'DataFormat'  => where { $_ =~ m(^\bjson\b$)i };
type 'TrueFalse'   => where { $_ =~ m(^\btrue\b|\bfalse\b$)i };
subtype 'MaxResult',   as 'Int', where { $_ > 0 && $_ <= 100 };
subtype 'PositiveInt', as 'Int', where { $_ > 0 };
has  'api_key'     => (is => 'ro', isa => 'Str', required => 1);
has  'browser'     => (is => 'rw', isa => 'LWP::UserAgent', default => sub { return LWP::UserAgent->new(); });
has  'prettyprint' => (is => 'rw', isa => 'TrueFalse',  default => 'true');
has  'alt'         => (is => 'rw', isa => 'DataFormat', default => 'json');

around BUILDARGS => sub
{
    my $orig  = shift;
    my $class = shift;

    if (@_ == 1 && ! ref $_[0])
    {
        return $class->$orig(api_key => $_[0]);
    }
    else
    {
        return $class->$orig(@_);
    }
};

=head1 CONSTRUCTOR

The constructor expects your application API Key at the least, which you can get it for FREE from Google.

    +-------------+----------------------------------------------------------------------------------------+
    | Parameter   | Meaning                                                                                |
    +-------------+----------------------------------------------------------------------------------------+
    | alt         | Alternative data representation format. If you don't specify an alt parameter, the     |
    |             | Moderator server returns data in the JSON format. This is equivalent to alt=json. The  |
    |             | The Moderator API currently supports only the JSON data format.                        |
    | api_key     | Your application API key. You should supply a valid API key with all requests. Get a   |
    |             | key from the Google APIs console.                                                      |
    | prettyprint | Returns a response with indentations and line breaks. If prettyprint=true, the results |
    |             | returned by the server will be human readable (pretty printed).                        |
    +-------------+----------------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Moderator;

    my $api_key   = 'Your_API_Key';
    my $moderator = WWW::Google::Moderator->new($api_key);

=cut

=head1 METHODS

=head2 get_series_detail()

Retrieve series details for the given series id.

    use strict; use warnings;
    use WWW::Google::Moderator;

    my $api_key   = 'Your_API_Key';
    my $moderator = WWW::Google::Moderator->new($api_key);
    my $detail    = $moderator->get_series_detail(25173);

=cut

sub get_series_detail
{
    my $self     = shift;
    my ($series) = pos_validated_list(\@_,
                   { isa => 'Int', required => 1 },
                   MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my $browser  = $self->browser;
    my $url      = sprintf("%s/series/%d?key=%s", $BASE_URL, $series, $self->api_key);
    $url .= sprintf("&alt=%s", $self->alt);
    $url .= sprintf("&prettyprint=%s", $self->prettyprint);
    my $request  = HTTP::Request->new(GET => $url);
    my $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    my $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return from_json($content);
}

=head2 get_topic_detail()

Retrieve given topic details of given topic id of the given series id.

    use strict; use warnings;
    use WWW::Google::Moderator;

    my $api_key   = 'Your_API_Key';
    my $moderator = WWW::Google::Moderator->new($api_key);
    my $detail    = $moderator->get_topic_detail(25173, 64);

=cut

sub get_topic_detail
{
    my $self = shift;
    my ($series, $topic) = pos_validated_list(\@_,
                           { isa => 'Int', required => 1 },
                           { isa => 'Int', required => 1 },
                           MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my $browser  = $self->browser;
    my $url      = sprintf("%s/series/%d/topics/%d?key=%s", $BASE_URL, $series, $topic, $self->api_key);
    $url .= sprintf("&alt=%s", $self->alt);
    $url .= sprintf("&prettyprint=%s", $self->prettyprint);
    my $request  = HTTP::Request->new(GET => $url);
    my $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    my $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return from_json($content);
}

=head2 get_submission_detail()

Retrieve submission detail of the given submission id of the given series id.

    use strict; use warnings;
    use WWW::Google::Moderator;

    my $api_key   = 'Your_API_Key';
    my $moderator = WWW::Google::Moderator->new($api_key);
    my $detail    = $moderator->get_submission_detail(25173, 175182);

=cut

sub get_submission_detail
{
    my $self = shift;
    my ($series, $submission) = pos_validated_list(\@_,
                                { isa => 'Int', required => 1 },
                                { isa => 'Int', required => 1 },
                                MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my $browser  = $self->browser;
    my $url      = sprintf("%s/series/%d/submissions/%d?key=%s", $BASE_URL, $series, $submission, $self->api_key);
    $url .= sprintf("&alt=%s", $self->alt);
    $url .= sprintf("&prettyprint=%s", $self->prettyprint);
    my $request  = HTTP::Request->new(GET => $url);
    my $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    my $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return from_json($content);
}

=head2 get_topics()

Retrieve all topics in the given series id.

    +-------------+----------------------------------------------------------------------------------------+
    | Parameter   | Meaning                                                                                |
    +-------------+----------------------------------------------------------------------------------------+
    | series-id   | Series Id                                                                              |
    |             |                                                                                        |
    | max-results | The maximum number of elements to return with this request. Default: max-results=20;   |
    |             | Maximum allowable value: max-results=100.                                              |
    |             |                                                                                        |
    | start-index | The position in the collection at which to start the list of results. The index of the |
    |             | first item is 1.                                                                       |
    +-------------+----------------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Moderator;

    my ($api_key, $moderator, $topics);
    $api_key   = 'Your_API_Key';
    $moderator = WWW::Google::Moderator->new($api_key);
    $topics    = $moderator->get_topics(25173);
    # or
    $topics    = $moderator->get_topics('series-id' => 25173);

=cut

around 'get_topics' => sub
{
    my $orig  = shift;
    my $class = shift;

    if (@_ == 1 && ! ref $_[0])
    {
        return $class->$orig('series-id' => $_[0]);
    }
    else
    {
        return $class->$orig(@_);
    }
};

sub get_topics
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'series-id'   => { isa => 'Int', required => 1 },
                'max-results' => { isa => 'MaxResult',   default => 20},
                'start-index' => { isa => 'PositiveInt', default => 1 },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my $browser  = $self->browser;
    my $url      = sprintf("%s/series/%d/topics?key=%s", $BASE_URL, $param{'series-id'}, $self->api_key);
    $url .= sprintf("&alt=%s", $self->alt);
    $url .= sprintf("&prettyprint=%s", $self->prettyprint);
    $url .= sprintf("&max-results=%d", $param{'max-results'});
    $url .= sprintf("&start-index=%d", $param{'start-index'});
    my $request  = HTTP::Request->new(GET => $url);
    my $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    my $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return from_json($content);
}

=head2 get_series_submissions()

Retrieve all submissions in the given series id.

    +------------------+-----------------------------------------------------------------------------------------+
    | Parameter        | Meaning                                                                                 |
    +------------------+-----------------------------------------------------------------------------------------+
    | series-id        | Series Id                                                                               |
    |                  |                                                                                         |
    | q                | Full-text query string                                                                  |
    |                  |                                                                                         |
    | hasAttachedVideo | Restricts the submissions returned to those that have attached videos. You can restrict |
    |                  | the returned submissions to those with video attachments by specifying                  |
    |                  | hasAttachedVideo=true. Ignored if the q query parameter is specified.                   |
    |                  |                                                                                         |
    | sort             | You can change the ordering by setting the sort parameter to be one of these values:    |
    |                  | RANK_DESCENDING - The most popular to least popular votes (this is the default).        |
    |                  | RANK_ASCENDING  - The least popular to most popular votes.                              |
    |                  | HOT_DESCENDING  - Those that have gained the most popularity recently.                  |
    |                  | DATE_SUBMITTED_DESCENDING - The newest creation time to the oldest.                     |
    |                  | DATE_SUBMITTED_ASCENDING  - The oldest creation time to the newest.                     |
    |                  |                                                                                         |
    | max-results      | The maximum number of elements to return with this request. Default: max-results=20;    |
    |                  | Maximum allowable value: max-results=100.                                               |
    |                  |                                                                                         |
    | start-index      | The position in the collection at which to start the list of results. The index of the  |
    |                  | first item is 1.                                                                        |
    +------------------+-----------------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Moderator;

    my ($api_key, $moderator, $submissions);
    $api_key     = 'Your_API_Key';
    $moderator   = WWW::Google::Moderator->new($api_key);
    $submissions = $moderator->get_series_submissions(25173);
    # or
    $submissions = $moderator->get_series_submissions('series-id' => 25173);

=cut

around 'get_series_submissions' => sub
{
    my $orig  = shift;
    my $class = shift;

    if (@_ == 1 && ! ref $_[0])
    {
        return $class->$orig('series-id' => $_[0]);
    }
    else
    {
        return $class->$orig(@_);
    }
};

sub get_series_submissions
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'series-id'        => { isa => 'Int', required => 1  },
                'q'                => { isa => 'Str', default  => '' },
                'max-results'      => { isa => 'MaxResult',   default => 20 },
                'start-index'      => { isa => 'PositiveInt', default => 1  },
                'hasAttachedVideo' => { isa => 'TrueFalse',   default => 'true' },
                'sort'             => { isa => 'SortType',    default => 'RANK_DESCENDING' },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my $browser  = $self->browser;
    my $url      = sprintf("%s/series/%d/submissions?key=%s", $BASE_URL, $param{'series-id'}, $self->api_key);
    $url .= sprintf("&alt=%s", $self->alt);
    $url .= sprintf("&q=%s", uri_escape($param{q}));
    $url .= sprintf("&prettyprint=%s", $self->prettyprint);
    $url .= sprintf("&max-results=%d", $param{'max-results'});
    $url .= sprintf("&start-index=%d", $param{'start-index'});
    $url .= sprintf("&hasAttachedVideo=%s", $param{'hasAttachedVideo'});
    $url .= sprintf("&sort=%s", $param{'sort'});
    my $request  = HTTP::Request->new(GET => $url);
    my $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    my $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return from_json($content);
}

=head2 get_topic_submissions()

Retrieve all submissions in the given topic id of the given series id.

    +------------------+-----------------------------------------------------------------------------------------+
    | Parameter        | Meaning                                                                                 |
    +------------------+-----------------------------------------------------------------------------------------+
    | series-id        | Series Id                                                                               |
    |                  |                                                                                         |
    | topic-id         | Topic Id                                                                                |
    |                  |                                                                                         |
    | q                | Full-text query string                                                                  |
    |                  |                                                                                         |
    | hasAttachedVideo | Restricts the submissions returned to those that have attached videos. You can restrict |
    |                  | the returned submissions to those with video attachments by specifying                  |
    |                  | hasAttachedVideo=true. Ignored if the q query parameter is specified.                   |
    |                  |                                                                                         |
    | sort             | You can change the ordering by setting the sort parameter to be one of these values:    |
    |                  | RANK_DESCENDING - The most popular to least popular votes (this is the default).        |
    |                  | RANK_ASCENDING  - The least popular to most popular votes.                              |
    |                  | HOT_DESCENDING  - Those that have gained the most popularity recently.                  |
    |                  | DATE_SUBMITTED_DESCENDING - The newest creation time to the oldest.                     |
    |                  | DATE_SUBMITTED_ASCENDING  - The oldest creation time to the newest.                     |
    |                  |                                                                                         |
    | max-results      | The maximum number of elements to return with this request. Default: max-results=20;    |
    |                  | Maximum allowable value: max-results=100.                                               |
    |                  |                                                                                         |
    | start-index      | The position in the collection at which to start the list of results. The index of the  |
    |                  | first item is 1.                                                                        |
    +------------------+-----------------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Moderator;

    my ($api_key, $moderator, $submissions);
    $api_key     = 'Your_API_Key';
    $moderator   = WWW::Google::Moderator->new($api_key);
    $submissions = $moderator->get_topic_submissions(25173, 64);
    # or
    $submissions = $moderator->get_topic_submissions('series-id' => 25173, 'topic-id' => 64);

=cut

around 'get_topic_submissions' => sub
{
    my $orig  = shift;
    my $class = shift;

    if (@_ == 2 && ! ref $_[0])
    {
        return $class->$orig('series-id' => $_[0], 'topic-id' => $_[1]);
    }
    else
    {
        return $class->$orig(@_);
    }
};

sub get_topic_submissions
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'series-id'        => { isa => 'Int', required => 1  },
                'topic-id'         => { isa => 'Int', required => 1  },
                'q'                => { isa => 'Str', default  => '' },
                'max-results'      => { isa => 'MaxResult',   default => 20 },
                'start-index'      => { isa => 'PositiveInt', default => 1  },
                'hasAttachedVideo' => { isa => 'TrueFalse',   default => 'true' },
                'sort'             => { isa => 'SortType',    default => 'RANK_DESCENDING' },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my $browser  = $self->browser;
    my $url      = sprintf("%s/series/%d/topics/%d/submissions?key=%s", $BASE_URL, $param{'series-id'}, $param{'topic-id'}, $self->api_key);
    $url .= sprintf("&alt=%s", $self->alt);
    $url .= sprintf("&q=%s", uri_escape($param{q}));
    $url .= sprintf("&prettyprint=%s", $self->prettyprint);
    $url .= sprintf("&max-results=%d", $param{'max-results'});
    $url .= sprintf("&start-index=%d", $param{'start-index'});
    $url .= sprintf("&hasAttachedVideo=%s", $param{'hasAttachedVideo'});
    $url .= sprintf("&sort=%s", $param{'sort'});
    my $request  = HTTP::Request->new(GET => $url);
    my $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    my $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return from_json($content);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report  any  bugs or feature requests to C<bug-www-google-moderator at rt.cpan.org>, or
through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Google-Moderator>.
I will be notified and then you'll automatically be notified of progress on your bug as I make
changes.

=head1 TODO

=over 6

=item * Creating a user's vote.

=item * Creating a new topic in a series.

=item * Creating a submission for a topic.

=item * Updating a vote for the user.

=item * Retrieving all votes for the authenticated user.

=item * Retrieving the user's vote for a specific submission.

=back

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Google::Moderator

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Google-Moderator>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Google-Moderator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Google-Moderator>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Google-Moderator/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  distributed  in  the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed in the hope that it will be useful,  but  WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

__PACKAGE__->meta->make_immutable;
no Moose; # Keywords are removed from the WWW::Google::Moderator package

1; # End of WWW::Google::Moderator