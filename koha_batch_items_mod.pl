#!/usr/bin/perl

# koha_batch_items_mod is a utility to modify items attributes
# (notforloan, barcode, ccode...) in a Koha repository. It relies on
# Koha API and is designed for older versions of Koha (eg 3.2) with
# buggy batch modification.

# Copyright (c) 2014 Nicolas Legrand <nicolas.legrand@bulac.fr>
#
# I don't use GPL as default license, but since Koha C4 modules are
# GPLed, let's be contaminated.
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

use strict;
use warnings;

use Getopt::Std;
use File::Basename;
use C4::Items;
use C4::Biblio;
use Koha::Items;

$Getopt::Std::STANDARD_HELP_VERSION = 1;
my %opts;
my $programname = basename($0);

sub HELP_MESSAGE {
    VERSION_MESSAGE();
    print "Usage: $programname [-a] [<itemnumber>] <column> <newvalue> [file]\n";
    print "           -a apply the changes. Dry run otherwise.\n";
    exit 1;
}

sub VERSION_MESSAGE {
    print "$programname version 0.1\n";
}

getopts('a', \%opts);
my $apply = $opts{'a'};
if ($apply) {
    print "Applying changes:\n\n";
} else {
    print "Dry run:\n\n";
}
my $batchjob = "yes";
my $itemnumber;
if ($ARGV[0] =~ /^[0-9]{1,10}$/) {
    $itemnumber = shift @ARGV;
    $batchjob = "no";
}

my $column = shift @ARGV ;
HELP_MESSAGE() if (!defined $column);
my $newvalue = shift @ARGV ;
HELP_MESSAGE() if (!defined $newvalue);

sub ModifyItem {
    my ($itemnumber, $column, $newvalue, $apply) = @_;
    if ($itemnumber !~ /^[0-9]{1,10}$/) {
	die "Bad itemnumber: $itemnumber. Must be of form: [0-9]{1,10}";
    }
    my $item = Koha::Items->find($itemnumber);
    my $biblionumber = $item->biblionumber;
    die "$itemnumber does not map to a bib record" unless (defined $biblionumber);

    my $item = C4::Items::GetItem($itemnumber);

    if (exists $item->{$column}) {
    	my $currentvalue = $item->{$column};
    	print "biblionumber: $biblionumber, itemnumber: $itemnumber, $column: $currentvalue -> $newvalue\n";
	if ($apply) {
	    C4::Items::ModItem({$column => $newvalue}, $biblionumber, $itemnumber);
	}
    } else {
    	die "$column is not a Koha DB column name";
    }
}

$newvalue = undef if ($newvalue eq 'NULL' or $newvalue eq '');

if ($batchjob eq "no") {
    ModifyItem($itemnumber, $column, $newvalue, $apply);
} else {
    while (my $itemnumber = <>) {
	chomp($itemnumber);
	$itemnumber =~ s/\r$//;
	ModifyItem($itemnumber, $column, $newvalue, $apply);
    }
}

1;

__END__

=head1 SYNOPSIS

    koha_batch_items_mod [-a] [<itemnumber>] <column> <newvalue> [file]
                          -a apply the changes. Dry run otherwise

=head1 DESCRIPTION

With older versions of Koha, the batch item modification is buggy,
this program is a workaround to permit batch modification.

Change koha <column> value with <newvalue> for the item with this
<itemnumber> key.

If <itemnumber> is not supplied it can read an item number list
from a file or STDIN.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2014 Nicolas Legrand <nicolas.legrand@bulac.fr>.
License GPLv3+: GNU GPL version 3 or later
<http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

