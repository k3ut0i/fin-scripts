# -*- mode: perl -*-

## This module tests validation of sbi xls files.

use strict;
use warnings;
use Test::More;

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


done_testing();

