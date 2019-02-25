package GnuCash::Store;

use strict;
use warnings;
use DBI;
#use List::Util qw(reduce);
use Carp;

my %schema = {'date' => 'varchar(10)',
	      'transfer_reconcile_date' => 'varchar(10)',
	      'account' => 'varchar(30)',
	      'transfer_account' => 'varchar(30)',
	      'withdrawl' => 'varchar(15)',
	      'deposit' => 'varchar(15)',
	      'description' => 'varchar(100)'};

sub create_db{
  my $db_file = shift;
  my $tb_name = shift;
  die "file already exists: $db_file" if (-e $db_file);
  my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file", "", "");
  my @schema_fields;
  for (keys %schema) {
    push @schema_fields, "$_ $schema{$_}";
  }
  my $schema_string = join ', ', @schema_fields;
  $dbh->do("CREATE TABLE $tb_name ($schema_string)");
  return $dbh;
}

sub update_db{
  my ($dbh, $txn) = @_;
  
}

1;
