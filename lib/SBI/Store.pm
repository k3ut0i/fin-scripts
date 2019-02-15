package SBI::Store;

use strict;
use warnings;
use DBI;
use SBI::XLS;

sub create_db{
  my $dbfile = shift;
  my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");
  my $txn_header = "txn_date, value_date, description, ref_no, debit, credit, balance";
  $dbh->do("create table txns ($txn_header)");
  return $dbh;
}

sub update_db{
  my $txn = shift;
  my $dbh = shift;
  my $update_stmt =
    $dbh->prepare("insert into txns values (? , ? , ? , ? , ? , ? , ?)");
  $update_stmt->execute(@{$txn}{SBI::XLS::TXN_HEADER});
}


1;
