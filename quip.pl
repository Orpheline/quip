#! /usr/bin/env perl
use strict;
use warnings;

our $VERSION = "0.001_002";
$VERSION = eval $VERSION;

=head1 NAME

quip.pl - A simple cli note-taking app

=head1 SYNOPSIS

=head1 DESCRIPTION

Quip is a command line tool to capture short notes and tasks.  The goal is to
capture ad hoc thoughts quickly and with as small an interruption to ones'
workflow as possible.

Quip assumes the first word following its' call ( C<$0> ) is the note type 
(ex, note, TODO, etc.) and that all following text is the associated message.

Quip stores its' notes under C<~/quip/>; however, this can be tuned by editing
C<~/.quiprc>

NOTE: I have many, many interruptions and digressions in my life, and projects
may sit idle for weeks or months until I come back to them.  Because of this,
and because this script is early in development, it is very heavily commented.
As work progresses and the design and functionality are refined, commentary will
be cleaned up to something resonably documentary without excessive verbosity.

Yes, that includes this description ;).

=over 4

=cut

use Carp;
use File::Path qw(make_path );
use File::Spec;
use POSIX( 'strftime' );
use Time::HiRes( 'time' );
use YAML qw( LoadFile DumpFile );

#-------------------------------------------------------------------------------

# Get the quip config.  If the config does not load, something quite serious is
# wrong.
my $config = get_config();
croak "Error: no config found!" unless $config;

# Process the input line.  The first 'word' indicates the operation; any
# following content is assumed to be a message for that operation.  If the
# usage evolves towards a more complicated syntax, I may rewrite this to use
# standard command option syntax.
if ( scalar @ARGV == 0 ) {
    print "Error: no command or message provided.\n";
    usage();
    exit 1;
}
my $op = shift @ARGV;

# If $op = 'usage', display usage and exit
if ( $op eq 'usage' ) {
    usage();
    exit 0;
}

# If no content after operation, warn and exit.
if ( scalar @ARGV == 0 ) {
    print "Error: no message body for operation!\n";
    usage();
    exit 1;
}

# Now we're processing messages...
my $page = File::Spec->catfile( $config->{notebook}, $op );
if ( ! -e $page ) {
    print "Could not find notebook page $op; creating it.\n";
    DumpFile( $page, { $op =>[] } );
}

my $page_content = LoadFile( $page );

push @{ $page_content->{ $op } },
    POSIX::strftime( "%Y-%m-%d_%H:%M:%S", localtime )  # Record timestamp
    . ' - '                                            # Field separator
    . join ' ', @ARGV;                                 # friendly message format

DumpFile( $page, $page_content );

exit 0;

#-------------------------------------------------------------------------------
=item C<get_config>

Reads the quip.yaml config file.  If the config doesn't exist, create one and 
the default notebook.

---
notebook: ~/quip/notebook
quiprc: ~/.quiprc


Presently the config contains two values: the location of the config file, and
the path to the default notebook.

returns a hashref of the config.

=cut
#-------------------------------------------------------------------------------
sub get_config {
    # Check for the config file; create if it doesn't exist
    my $config_file = File::Spec->catfile( $ENV{HOME}, '.quiprc' );

    if ( not -e $config_file ) {
        print "First use; creating default config.\n";

        my $notebook = File::Spec->catdir( $ENV{HOME}, qw( quip notebook ) );
        my $config = {
            quiprc   => $config_file,
            notebook => $notebook,
        };
        DumpFile( $config_file, $config );

        # Create default notebook
        make_path( $notebook ) or croak "Could not create $notebook: $!";

        # Create default pages
        my @pages = (
            { name  => 'note', },
            { name  => 'log',  },
            { name  => 'todo', },
        );

        for my $page ( @pages ) {
            my $content = { $page->{name} => [] };
            DumpFile( File::Spec->catfile( $notebook, $page->{name} ), $content );
        }
    }

    return LoadFile( $config_file );
}

#-------------------------------------------------------------------------------
=item C<usage>

Returns the command usage.

=cut
#-------------------------------------------------------------------------------
sub usage {
    my $usage = <<"USAGE_END";

    quip.pl 
    version: $VERSION

    USAGE:
        quip [note type] [note text]   Adds a note of the specified note type.
        quip help|h|usage              Print help.


        Example:
            quip todo Buy coffee at the store
            quip note Learn more about cats
USAGE_END

    print $usage;

    return;
}

=back

=head1 AUTHOR

Liam McNerney

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2018, Liam McNerney. All rights reserved.
 
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
