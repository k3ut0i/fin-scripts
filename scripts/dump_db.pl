#!/usr/bin/perl
use strict;
use warnings;

use Analysis::Transactions;

Analysis::Transactions::verify_txns('2017-01-01T00:00:00',
				    '2020-01-01T00:00:00',
				    $ARGV[0])
  or die "Cannot verify transactions in database";

Analysis::Transactions::print_txns('2017-01-01T00:00:00',
				   '2020-01-01T00:00:00',
				   $ARGV[0]);

