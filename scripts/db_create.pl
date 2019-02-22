#!/usr/bin/perl
use strict;
use warnings;

use SBI::Store;
use SBI::XLS;


open(my $fh, "<", $ARGV[0])
  or die "Can't open $ARGV[0] for reading: $!";
my $pinfo = SBI::XLS::get_personal_info($fh);
my $txn_header = SBI::XLS::slurp_txn_header($fh);
my $dbh = SBI::Store::create_db($ARGV[1]);
while (defined(my $txn = SBI::XLS::slurp_txn_field($fh))) {
  SBI::Store::update_db($txn, $dbh);
}

__END__
=head1 NAME

db_create - Create a transaction database from SBI XLS file.

=head1 SYNOPSIS

  db_create.pl sbi_xls_file database_file

=head2 Examples

The following creates a sample_info.db sqlite3 database file from
transaction report of sample_info.xls file.
  db_create.pl resources/sample_info.xls /tmp/sample_info.db

=head1 DESCRIPTION

Create a sqlite3 database from of SBI transaction report file. This is
a simple db creater which does not do any checks.


=cut

