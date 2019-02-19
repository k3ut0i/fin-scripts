package Analysis::Transactions;

use strict;
use warnings;

use DBI;

sub print_txns{
  my ($start_date, $end_date, $dbfile) = @_;
  # Sql access for dates between these parameters
  my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");

  my $select_stmt = $dbh->prepare
    (qq{SELECT * FROM txns WHERE txn_date BETWEEN ? AND ?});

  $select_stmt->execute($start_date, $end_date);

  while (my @row = $select_stmt->fetchrow_array) {
    print "@row\n";
  }
};

sub verify_txns{
  my ($start_date, $end_date, $dbfile) = @_;
  my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");
  my $stmt = $dbh->prepare
    (qq{SELECT * FROM txns WHERE txn_date BETWEEN ? AND ?});
  $stmt->execute($start_date, $end_date);
  my $balance = $stmt->fetchrow_hashref->{'balance'};
  while (my $row = $stmt->fetchrow_hashref) {
    if ($balance + $row->{'credit'} == $row->{'balance'} + $row->{'debit'}){
      $balance = $row->{'balance'};
    }else {
      return 0;
    }
  }
  return 1;
}
1;
