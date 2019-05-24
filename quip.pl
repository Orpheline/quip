#! /usr/bin/env perl

use strict;
use warnings;

our $VERSION = "0.000_002";
$VERSION = eval $VERSION;

use Carp;
use File::Path qw( make_path );
use File::Spec;
use Getopt::Long qw( :config gnu_compat );
use POSIX ( 'strftime' );
use Time::HiRes( 'time' );
use YAML::XS qw( DumpFile LoadFile );

# Process the command args
my $opts = parse_cmd_args();

# Check whether the notes file is available
my $file = $ENV{QUIP_NOTES};
if ( not defined $file ) {
    croak 'No QUIP_NOTES path defined!';
}
if ( not -f $file ) {
    print "$file does not seem to exist; I'll try creating it\n";
}

# Read in the file
my $records = LoadFile( $file );

# Format the note
my $rec = {
    timestamp => get_timestamp(),
    note => $opts->{note},
};

if ( $opts->{tag} ) {
    for my $tag ( @{ $opts->{tag} } ) {
        push @{ $rec->{tags} }, $tag;
    } 
}

push @{ $records->{$opts->{category} } }, $rec;

DumpFile( $file, $records );

exit 0;

## Returns a millisecond-accurate date/time stamp
sub get_timestamp {
    my ( $t ) = @_; 

    # If a timestamp was not supplied, use the system time
    if ( not $t ) { 
        $t = time;
    }   
    my $ts = POSIX::strftime( "%Y-%m-%dT%H:%M:%S", localtime $t );

    # Append milliseconds
    $ts .= sprintf ".%03d", ( $t - int( $t ) ) * 1000;

    return $ts;
}

sub parse_cmd_args {
    my $opts = {};  # hashref for processed command options

    my @options = qw(
        version|v
        usage|u|help|h
		category|c=s
        tag|t=s@
        note|n=s
    );
    GetOptions( $opts, @options );

    if ( $opts->{version} ) {
        print "$VERSION\n";
        exit 0;
    }

    if ( $opts->{usage} ) {
        print usage();
        exit 0;
    }

    # If no category was provided, default to 'general'
    $opts->{category} = 'general' if not defined $opts->{category};

    return $opts;
}

sub usage {
    my $usage = <<"USAGE_END";

quip.pl
version: $VERSION

SYNOPSIS

Quip is a simple tool for capturing timestamped, tagged notes from
the command line.

Notes are saved as YAML, making them human-readable and easily parsable

USAGE:
    quip [-category] [-tags] -n note     Add a note.
    quip -h                              Print help.

FLAGS:
    -c, --category string    Descriptive category for note
    -h, --help               Displays usage
    -n, --note string        Note content
    -t, --tag string(s)      Associated tags (allows multiple tags)    
    -u, --usage              Displays usage
    -v, --version            Displays version

REQUIREMENTS:
    Aside from the necessary Perl CPAN modules, quip's only requirement
    is the creation of a target file for notes.  It takes the path from
    the QUIP_NOTES environment variable.

EXAMPLES:

    quip -h
        Prints this help

    quip -n "The quick brown fox"

        ---
        general:
        - note: The quick brown fox
          timestamp: 2019-05-22T04:48:03.741

    quip -c idea -n 'Have lunch with Jed' -t lunch -t colleague

        ---
        idea:
        - note: Have lunch with Jed
          tags:
          - lunch
          - colleague
          timestamp: 2019-05-22T06:10:25.095

USAGE_END

    print $usage;

    return;
}

1;
# __END__

=head1 NAME

quip.pl - A simple cli note-taking app

=head1 VERSION

Version 0.000001

=head1 SYNOPSIS

 ./quip.pl -n "Here is a note"

=head1 DESCRIPTION

Quip is a simple CLI for quickly capturing one-line notes.

=head1 AUTHOR

Liam McNerney

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2019, Liam McNerney. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
