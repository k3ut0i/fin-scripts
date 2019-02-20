package SBI::Store;

use strict;
use warnings;
use DBI;
use SBI::XLS;

use constant SCHEMA => ("txn_date varchar(20)",
			"value_date varchar(20)",
			"description varchar(100)",
			"ref_no varchar(50)",
			"debit float",
			"credit float",
			"balance float");
sub create_db{
  my $dbfile = shift;
  die "file already exists: $dbfile" if (-e $dbfile);
  my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");
  my $schema = join(', ', SCHEMA);
  $dbh->do("create table sbi_txns ($schema)");
  return $dbh;
}

# TODO: How to gracefully handle multiple entries?
sub update_db{
  my $txn = shift;
  my $dbh = shift;
  my $update_stmt =
    $dbh->prepare("insert into sbi_txns values (? , ? , ? , ? , ? , ? , ?)");
  $update_stmt->execute(@{$txn}{SBI::XLS::TXN_HEADER});
}


1;
