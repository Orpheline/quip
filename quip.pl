#! /usr/bin/env perl
use strict;
use warnings;

our $VERSION = "0.001_001";
$VERSION = eval $VERSION;

=head1 NAME

quip.pl - A simple cli note-taking app

=head1 SYNOPSIS

This rev. of quip uses Vimwiki for storage, mostly because I'm using Vimwiki and 
keeping everything in one place appeals to me.

At present there are two uses for quip in Vimwiki:
    - Recording todo items
    - Recording short notes and reminders

More use cases may present themselves; for now, I'm limiting this to these two
pages.

=head1 DESCRIPTION



=over 4

=cut

use Carp;
use Data::Dumper;
use File::Spec;
use Getopt::Long qw( :config gnu_compat );
use POSIX( 'strftime' );
use Storable;
use Time::HiRes( 'time' );

use Data::Dumper;

#--------------------------------------------------------------------------#

# Get the call options.
my $opts = _parse_cmd_args();

# print Dumper $opts;

# At this point we can save either a TODO item or a note.
my $result;

$result = _save_note();

sub _save_note {
    my $note = $opts->{note};

    # Does the note page exist?  If not, create it and update index.wiki
    my $page_name = ( $opts->{page} ) ? $opts->{page} : ( $opts->{action} ) ? 'todo' : 'note';

    my $note_page = _get_wiki_page( $page_name );    
    # Format note
    my $ts        = POSIX::strftime( "%Y-%m-%d", localtime );
    $note         = "[$ts] - $note\n";

    # Add checkbox for TODO items
    if ( $opts->{action} ) {
        $note = '[ ] ' . $note;
    }

    open my $nh, '>>', $note_page or croak( "Could not open $note_page: $! | $@" );
    print $nh "    * $note";
    close $nh;

    return;
}

sub _get_wiki_page {
    my ( $page ) = @_;

    my $wiki_dir  = '';
    my $page_name = $page . '.wiki';

    if ( ! -d $wiki_dir ) {
        croak( "Could not find Vimwiki directory; exiting!\n" );
    }

    # Check for page; if it doesn't exist, create it and update index.wiki
    my $page_file = File::Spec->catfile( $wiki_dir, $page_name );
    if ( ! -e $page_file ) {
        print "$page_file does not exist; creating\n";

        open my $fh, '>', $page_file or croak( "Could not create $page_file: $! | $@" );
        print $fh "= Quip Notes =\n";
        close $fh;

        # Update index.wiki
        my $index_file = File::Spec->catfile( $wiki_dir, 'index.wiki' );
        open $fh, '>>', $index_file or croak( "Could not open $index_file: $! | $@" );
        print $fh "* [[$page]] - Quip file\n";
        close $fh;
    }

    return $page_file;
}

sub _parse_cmd_args {
    my $opts = {};  # hashref for processed command options
    my @options = qw(
        action|a
        note|n=s
        page|p=s
        usage|help|h|u
    );

    GetOptions( $opts, @options );

    # If usage option is present, display usage and exit
    if ( $opts->{usage} ) {
        print _usage();
        exit 0;
    }

    # If the note option is NOT present, return an error, display usage, and exit.
    if ( not $opts->{note} ) {
        print "Whoops!  You didn't give me a note to save!\n";
        print _usage();
        exit 1;
    }

    return $opts;
}

sub _usage {
    my $usage = <<"USAGE_END";

quip.pl 
version: $VERSION

USAGE:
    quip --note note             Add a note.
         [--action]              Optionally make the note an action item. 
         [--page page]           Optionally specify a page.  If this is not set,
                                 this will default to 'note' for a note, or 'todo'
                                 for an action item.  
    quip help|h|usage            Print help.

USAGE_END

    print $usage;

    return;
}

=back

=head1 AUTHOR

Liam McNerney

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2017, Liam McNerney. All rights reserved.
 
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
