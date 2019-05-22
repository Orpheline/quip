# quip-perl

Quip is a tool for capturing short notes from the command line.  These notes may optionally have a category assigned, and may optionally have one or more descriptive tags.

## Example:

    quip --category weekend --note 'Visit the park on Sunday' --tag outside --tag sunday --tag relax

Quips are saved to a flat file; this is human-readable, but easily parsed as .csv data.

## Sample entry:

    2019-05-22T07:14:06.100,weekend,'Visit the park on Sunday',outside:sunday:relax

# Configuration

The only configuration `quip` requires is setting then evironment variable `QUIP_NOTES` - all quips will be saved to that file.
