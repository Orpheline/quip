#! /usr/bin/env perl
use strict;
use warnings;

our $VERSION = "0.001_001";
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
C<~/.quiprc.yaml>

NOTE: I have many, many interruptions and digressions in my life, and projects
may sit idle for weeks or months until I come back to them.  Because of this,
and because this script is early in development, it is very heavily commented.
As work progresses and the design and functionality are refined, commentary will
be cleaned up to something resonably documentary without excessive verbosity.

Yes, that includes this description ;).

=over 4

=cut

use Carp;
use File::Spec;
use POSIX( 'strftime' );
use Storable;
use Time::HiRes( 'time' );
use YAML qw( LoadFile DumpFile );

#--------------------------------------------------------------------------#

# Get the quip config.
my $config = get_config();

# Process the input line.  The first 'word' indicates the operation; any
# following content is assumed to be a message for that operation.  If the
# usage evolves towards a more complicated syntax, I may rewrite this to use
# more traditional command options.
if ( scalar @ARGV == 0 ) {
    print "Error: no command or message provided.\n";
    usage();
    exit 1;
}
my $operation = shift @ARGV;

# Evaluate predefined operations
# If usage option is present, display usage and exit
if ( $operation eq 'usage' ) {
    usage();
    exit 0;
}


# If no content after operation, warn and exit.
if ( scalar @ARGV == 0 ) {
    print "Error: no message body for operation!\n";
    usage();
    exit 1;
}

my $message = join ' ', @ARGV;

my $page = File::Spec->catfile(
    $config->{quip}{path},
    $config->{quip}{pages}{ $operation }{page_name},
);
my $page_title = $config->{quip}{pages}{ $operation }{title};

# if the page exists, read it.
my $content;
if ( -e $page ) {
    $content = LoadFile( $page );
}
else {
    $content = {
        $page_title => [],
    };
}

# Format message
my $ts      = POSIX::strftime("%Y-%m-%d_%H:%M:%S", localtime);
my $message_out;
# Special formatting for TODO items
if ( $operation eq 'todo' ) {
    $message_out = '[ ] ';
}
$message_out .= "$ts - $message";
push @{ $content->{$page_title} }, $message_out;
DumpFile( $page, $content );

#-------------------------------------------------------------------------------
=item C<get_config>

Reads the quip.yaml config file.  If the config doesn't exist, create a default.


---
quip:
  pages:
    log:
      page_name: log.yaml
      title: Log
    note:
      page_name: notes.yaml
      title: Notes
    todo:
      page_name: todo.yaml
      title: TODO
  path: ~/quip/notebook
quiprc: ~/.quiprc


N.B. a future iteration may add an interactive configuration flow.

returns a hashref of the config.

=cut
#-------------------------------------------------------------------------------
sub get_config {
    # Check for the config file; create if it doesn't exist
    my $config_file = File::Spec->catfile( $ENV{HOME}, '.quiprc' );

    my $config = LoadFile( $config_file );

    if ( not $config ) {
        print "First use?  Creating default config...\n";
        $config = {
            quiprc          => $config_file,
            quip => {
                path  => File::Spec->catfile( $ENV{HOME}, 'quip', 'notebook' ),
                pages => {
                    note => {
                        title     => 'Notes',
                        page_name => 'notes.yaml',
                    },
                    todo  => {
                        title     => 'TODO',
                        page_name => 'todo.yaml',
                    },
                    log => {
                        title     => 'Log',
                        page_name => 'log.yaml',
                    },
                },
            },
        };
        save_yaml( $config_file, $config );
    }
    
    return $config;
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
