#!/usr/bin/perl

## This testing module verifies that the parsing sbi xls files.

use strict;
use warnings;
use Test::More;

use Scalar::Util qw(looks_like_number);

BEGIN:{use_ok("sbi_xls")};

my $sbi_xls_file = "resources/sample_xls.dat";
my $personal_info_file = "resources/sample_info.dat";

my $xls_fh;
my $info_fh;
# Most of them are written as a bunch in a subtest to facilitate future
# tests for further validation.


subtest 'SBI XLS file' => sub {
  ok(-e $sbi_xls_file, "SBI XLS file found.");
  open($xls_fh, '<', $sbi_xls_file) or die "File $sbi_xls_file : $!";
};

subtest 'PERSONAL Info file' => sub{
  ok(-e $personal_info_file, "PERSONAL INFO file found.");
  open($info_fh, '<', $personal_info_file) or
  die "File $personal_info_file : $!";
};

## Here I'll be trying to iterate over both files in parallel and
## Check for any inconsistencies in processing of sbi files.

subtest 'Account Name' => sub{
  chomp(my $account_name = <$info_fh>);
  is(slurp_account_name($xls_fh), $account_name);
};


subtest 'Address' => sub{
  chomp(my $address = <$info_fh>);
  for (1..3) {
    #      print $address;
    chomp(my $line = <$info_fh>);
    $address .= ", " . $line;
  }
  is(slurp_address($xls_fh), $address);
};

subtest 'Date' => sub{
  <$info_fh>; # Ignore value.
  ok(slurp_date($xls_fh)->isa('DateTime'));
};

<$info_fh> ; #Ignore Value.
ok(looks_like_number(slurp_account_number($xls_fh)), "Account Number");

subtest 'Account Desc' => sub{
  chomp(my $desc = <$info_fh>);
  is(slurp_account_description($xls_fh), $desc, "Account description match");
};


subtest 'Branch' => sub{
  chomp(my $branch = <$info_fh>);
  is(slurp_branch($xls_fh), $branch, 'Branch Name');
};

chomp(my $drawing_power = <$info_fh>);
is(slurp_drawing_power($xls_fh), $drawing_power, 'Drawing Power');

chomp(my $interest_rate = <$info_fh>);
is(slurp_interest_rate($xls_fh), $interest_rate, 'Interest Rate');

chomp(my $mod_balance = <$info_fh>);
is(slurp_mod_balance($xls_fh), $mod_balance, 'MOD Balance');

chomp(my $cif_no = <$info_fh>);
is(slurp_cif_no($xls_fh), $cif_no, 'CIF No.');

chomp(my $ifs_code = <$info_fh>);
my $ifs_hash = slurp_ifs_code($xls_fh);
my $ifs_code_from_xls = $ifs_hash->{Bank} . '0' . $ifs_hash->{Branch};
is($ifs_code_from_xls, $ifs_code, 'IFS Code.');

chomp(my $micr_code = <$info_fh>);
is(slurp_micr_code($xls_fh), $micr_code, 'MICR Code');

chomp(my $nomination_status = <$info_fh>);
is(slurp_nomination_status($xls_fh), $nomination_status, 'Nomination Status');

chomp(my $current_balance = <$info_fh>);
is(slurp_balance_on($xls_fh), $current_balance, 'Balance on date.');

subtest 'Start Date' => sub{
  <$info_fh>;
  ok(slurp_start_date($xls_fh)->isa('DateTime'));
};

subtest 'End Date' => sub{
  <$info_fh>;
  ok(slurp_end_date($xls_fh)->isa('DateTime'));
};


Todo :{
  local $TODO = "Un implemented features";

};
# TODO Continue writing tests for rest of the INFO_HEADER fields

done_testing();
