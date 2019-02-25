#!/usr/bin/perl
use strict;
use warnings;

use Term::ReadLine;
use Term::ANSIColor qw(:constants);

use GnuCash::Store;

my ($sbi_db, $gc_db) = @ARGV;
my $gc_dbh = create_db($gc_db, 'sbi_txns');
(my $sbi_dbh = DBI->connect("dbi:SQLite:dbname=$sbi_db", '', ''))
  or die "Could not connect to the database file $sbi_db : $DBI::errstr";

my $sbi_stmt = $sbi_dbh->prepare("SELECT * FROM sbi_txns");
$sbi_stmt->execute();
while (my $row = $sbi_stmt->fetchrow_hashref) {
  #After fetching appropriated fields of the transaction, ask for the
  #data required for Gnucash database and call update_db for gc_dbh
}
