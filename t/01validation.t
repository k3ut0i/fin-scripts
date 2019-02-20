# -*- mode: perl -*-

## This module tests validation of sbi xls files.

use strict;
use warnings;
use Test::More;
use JSON;
use File::Slurp qw(read_file);
BEGIN:{
  use_ok("SBI::XLS");
};

use constant XLS_DATA_FILE => "resources/sample_xls.dat";
use constant PERSONAL_JSON_FILE => "resources/sample_info.json";

my $info_hash;

ok(-e XLS_DATA_FILE, "xls data file found");
ok(-e PERSONAL_JSON_FILE, "personal JSON file found.");
ok(SBI::XLS::validate_input(XLS_DATA_FILE, PERSONAL_JSON_FILE),
   'XLS and JSON data matching');

my $json_fname = `mktemp -u`;
chomp($json_fname);
open (my $xls_fh, '<', XLS_DATA_FILE);
SBI::XLS::write_personal_info($xls_fh, $json_fname);
my $personal_json_info = decode_json read_file PERSONAL_JSON_FILE;
my $rewritten_json_info = decode_json read_file $json_fname;
is_deeply($personal_json_info, $rewritten_json_info,
	  'Rewritten JSON Invariance');
#unlink $json_fname;

done_testing();

