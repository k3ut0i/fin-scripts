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
