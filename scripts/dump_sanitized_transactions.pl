#!/usr/bin/perl
use strict;
use warnings;
use SBI::XLS;
use Term::Table;


sub dump_txns_from_file{
  my $file_name = shift;
  open(my $fh, "<", $file_name)
    or die "Can't open $file_name for reading: $!";
  #Ignore personal Info
  my $pinfo = SBI::XLS::get_personal_info($fh);
  my $txn_header = SBI::XLS::slurp_txn_header($fh);
  my @txns;
  while (defined( my $txn = SBI::XLS::slurp_txn_field($fh))) {
    # What's wrong here? Debugg goes haywire here.
    my @txn_fields = values %{$txn};
    push @txns,  \@txn_fields;
  }
  my @header = SBI::XLS::TXN_HEADER;
  my $table = Term::Table->new(
			       header => \@header,
			       rows => \@txns,
			      );
  print "$_\n" for $table->render;
};

dump_txns_from_file($ARGV[0]);
