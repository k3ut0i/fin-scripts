#!/usr/bin/perl
# SBI exports the file as XLS spreadsheet but it's just a text file.
# This script is to convert the file into a more suitable format.
package SBI::XLS;
use strict;
use warnings;
use Carp qw(carp croak);
use DateTime;
use DateTime::Format::Strptime;
use List::Util qw(all);
use JSON;
use File::Slurp qw(read_file write_file);
use Fcntl qw(SEEK_SET);

our $VERSION = 0.1;

use constant TXN_HEADER => ("Txn Date", "Value Date", "Description",
			    "Ref No./Cheque No.", "Debit", "Credit", "Balance");
our $txn_header = join "\t", TXN_HEADER;

# FIXME: Should i replace these with acutal names? or Just these keys useful?
use constant INFO_HEADER => ("Account Name", "Address", "Date", "Account Number",
			     "Account Description", "Branch", "Drawing Power",
			     "Interest Rate(% p.a.)", "MOD Balance", "CIF No.",
			     "IFS Code", "MICR Code", "Nomination Registered",
			     "Balance on", "Start Date", "End Date");

sub trim{
  my $str = shift;
  $str =~ s/^\s+|\s+$//g;
  return $str;
}
my $strp = DateTime::Format::Strptime->new(pattern => '%d %b %Y',
					   on_error => 'croak');
my $date_blurp = DateTime::Format::Strptime->new(pattern => '%Y-%m-%d',
						on_error=>'croak');
sub dd_mm_yyyy_to_datetime{
  my $dt = $strp->parse_datetime($_[0]);
  $dt->set_formatter($date_blurp);
}

sub slurp_generic{
  my $fh = shift;
  my $header = shift;
  my ($field1, $field2) = split(/:/, <$fh>);
  $header = trim $field1 or
    carp "Can't match \|$header\| with \|$field1\|";
  return trim($field2);
};

sub burp_generic{
  my $obj = shift;
  return $obj;
}

sub slurp_account_name{slurp_generic $_[0], (INFO_HEADER)[0];}
sub burp_account_name{burp_generic($_[0])};

# Should address be an array?
sub slurp_address{
  my $fh = shift;
  my $address = slurp_generic $fh, (INFO_HEADER)[1];
  foreach (1..3) {
    chomp(my $line = <$fh>);
    $address .= ", " . trim($line);
  }
  return $address;
}

sub burp_address{
  my $add_str = shift;
  my @fields = split(/, /, $add_str);
  return \@fields;
}

sub slurp_date{
  my $date_string = slurp_generic $_[0], (INFO_HEADER)[2];
  dd_mm_yyyy_to_datetime($date_string);
}
sub burp_date{
  my $date_obj = shift;
  return $strp->format_datetime($date_obj);
}

sub slurp_account_number{
  my $acc_string = slurp_generic $_[0], (INFO_HEADER)[3];
  if ( $acc_string =~ /_*(\d+)/) {
    return $1;
  }else {
    return undef;
  }
}
sub burp_account_number{burp_generic $_[0]};

sub slurp_account_description{ slurp_generic $_[0], (INFO_HEADER)[4];}
sub burp_account_description{burp_generic $_[0]};

sub slurp_branch{ slurp_generic $_[0], (INFO_HEADER)[5];}
sub burp_branch{burp_generic $_[0]};

sub slurp_drawing_power{ slurp_generic $_[0], (INFO_HEADER)[6];}
sub burp_drawing_power{burp_generic $_[0]};

sub slurp_interest_rate{ slurp_generic $_[0], (INFO_HEADER)[7];}
sub burp_interest_rate{burp_generic $_[0]};

sub slurp_mod_balance{ slurp_generic $_[0], (INFO_HEADER)[8];}
sub burp_mod_balance{burp_generic $_[0]};

sub slurp_cif_no{
  my $code_string = slurp_generic $_[0], (INFO_HEADER)[9];
  if ($code_string =~ /_*(\d+)/) {
    my $code = $1;
    carp "CIF number is not 11 characters" if length $code != 11;
    return $code;
  }else {
    return undef;
  }
}

sub burp_cif_no{burp_generic $_[0]};

sub slurp_ifs_code{
  my $code = slurp_generic $_[0], (INFO_HEADER)[10];
  carp "IFSC is not 11 characters." if length $code != 11;
  # Some validation.
  my $bank_code = substr $code, 0, 4;
  my $reserved = substr $code, 4, 1;
  my $branch_code = substr $code, 5;
  carp "IFSC Reserved character is nonzero." if $reserved != 0;
  return {Bank => $bank_code,
	  Branch => $branch_code};
}
sub burp_ifs_code{
  my $obj = shift;
  return $obj->{'Bank'} . '0' . $obj->{'Branch'};
};

sub slurp_micr_code{
  my $code_string = slurp_generic $_[0], (INFO_HEADER)[11];
  if ($code_string =~ /_*(\d+)/) {
    my $code = $1;
    carp "MICR Code is ". length $code . " not 9 characters"
      if length $code != 9;
    return $code;
  }else {
    return undef;
  }
}
sub burp_micr_code{burp_generic $_[0]};

# TODO: Make true or false status boolean
sub slurp_nomination_status{ slurp_generic $_[0], (INFO_HEADER)[12];}
sub burp_nomination_status{burp_generic $_[0]};

sub slurp_balance_on{ slurp_generic $_[0], (INFO_HEADER)[13];}
sub burp_balance_on{burp_generic $_[0]};

sub slurp_start_date{
  my $date_string = slurp_generic $_[0], (INFO_HEADER)[14];
  dd_mm_yyyy_to_datetime($date_string);
}
sub burp_start_date{burp_date $_[0]}

sub slurp_end_date{
  my $date_string = slurp_generic $_[0], (INFO_HEADER)[15];
  dd_mm_yyyy_to_datetime($date_string);
}
sub burp_end_date{burp_date $_[0]}

# Check if transaction header parses correctly
sub slurp_txn_header{
  croak "" unless defined $_[0];
  defined (my $txn_header = readline $_[0]) or carp "Cant read txn_headerb";
  chomp($txn_header);
  return $txn_header;
}

sub burp_txn_header{
  join("\t", TXN_HEADER());
}

sub sanitize_number{
  my $num = shift;
  if ($num =~ /\s/) {
    $num = 0.0;
  }
  else {
    $num =~ s/,//g;
  }
  return $num;
}
sub slurp_txn_field{
  my $txn_line;
  if (defined ($txn_line = readline $_[0])) {
    chomp($txn_line);
    my @fields = split '\t', $txn_line;
    return undef unless @fields == 7;
    my ($txn_date, $value_date, $desc, $ref, $debit, $credit, $balance)
      = @fields;
    my %txn;

    @txn{TXN_HEADER()} = (dd_mm_yyyy_to_datetime($txn_date),
			  dd_mm_yyyy_to_datetime($value_date),
			  $desc,
			  $ref,
			  sanitize_number($debit),
			  sanitize_number($credit),
			  sanitize_number($balance));
    return \%txn;
  } else {
    return undef;
  }
}

sub sanitize_txn_fields{}

# For each field we have a parser(slurp) and printer(burp)
my %handlers =
  (
   'Account Name' => [\&slurp_account_name, \&burp_account_name],
   'Address' => [\&slurp_address, \&burp_address],
   'Date' => [\&slurp_date, \&burp_date],
   'Account Number' => [\&slurp_account_number, \&burp_account_number],
   'Account Description' => [\&slurp_account_description, \&burp_account_description],
   'Branch' => [\&slurp_branch, \&burp_branch],
   'Drawing Power' => [\&slurp_drawing_power, \&burp_drawing_power],
   'Interest Rate(% p.a.)' => [\&slurp_interest_rate, \&burp_interest_rate],
   'MOD Balance' => [\&slurp_mod_balance, \&burp_mod_balance],
   'CIF No.' => [\&slurp_cif_no, \&burp_cif_no],
   'IFS Code' => [\&slurp_ifs_code, \&burp_ifs_code],
   'MICR Code' => [\&slurp_micr_code, \&burp_micr_code],
   'Nomination Registered' => [\&slurp_nomination_status, \&burp_nomination_status],
   'Balance on' => [\&slurp_balance_on, \&burp_balance_on],
   'Start Date' => [\&slurp_start_date, \&burp_start_date],
   'End Date' => [\&slurp_end_date, \&burp_end_date]
  );

sub get_personal_info{
  my $xls = shift;
  seek $xls, 0, SEEK_SET
    or die "Can't seek to beginning of XLS file.";
  my $personal_info;
  $personal_info =
    {
     'Account Name' => slurp_account_name($xls),
     'Address' => slurp_address($xls),
     'Date' => slurp_date($xls),
     'Account Number' => slurp_account_number($xls),
     'Account Description' => slurp_account_description($xls),
     'Branch' => slurp_branch($xls),
     'Drawing Power' => slurp_drawing_power($xls),
     'Interest Rate(% p.a.)' => slurp_interest_rate($xls),
     'MOD Balance' => slurp_mod_balance($xls),
     'CIF No.' => slurp_cif_no($xls),
     'IFS Code' => slurp_ifs_code($xls),
     'MICR Code' => slurp_micr_code($xls),
     'Nomination Registered' => slurp_nomination_status($xls),
     'Balance on' => slurp_balance_on($xls),
     'Start Date' => slurp_start_date($xls),
     'End Date' => slurp_end_date($xls)
    };
  return $personal_info;
}

sub DateTime::TO_JSON{
  my $dt_obj = shift;
  return $strp->format($dt_obj);
}
# Write personal info to JSON file
sub write_personal_info{
  my ($xls_fh, $output_file) = @_;
  my $pinfo = get_personal_info($xls_fh);
  my %json_info = map {$_ => $handlers{$_}[1]($pinfo->{$_})}INFO_HEADER;
  write_file($output_file, encode_json \%json_info);
};

## Tests if the given data file is the one we want.
sub validate_input{
  (my $input_data_file, my $personal_file) = @_;
  open(my $inp_fh, '<', $input_data_file) or
    croak "Can't open $input_data_file for reading. $!";
  my $xls_info = get_personal_info($inp_fh);
  my $saved_json_info = decode_json read_file $personal_file;
  # TODO: Compare the two hashes and verify if equal.
  # This function to all is very convoluted. It started
  # as a simple predicate to check validitiy for each key
  # but just ran out of control.
  all {
    my $equality = 0;
    if (ref $xls_info->{$_} eq 'DateTime') {
      my $dt_ord = DateTime->compare($xls_info->{$_},
				     dd_mm_yyyy_to_datetime($saved_json_info->{$_}));
      $equality = $dt_ord == 0;
    }elsif ($_ eq 'Address') {
      $equality = $xls_info->{$_} eq join(', ', @{$saved_json_info->{$_}});
    } elsif ($_ eq 'IFS Code') {
      #TODO : What goes here?
      my $ifs_code = $xls_info->{$_};
      $equality = ($ifs_code->{'Bank'} . '0' . $ifs_code->{'Branch'})
	eq $saved_json_info->{$_};
    }elsif ($_ eq 'MOD Balance' || $_ eq 'Drawing Power') {
      $equality = $xls_info->{$_} == $saved_json_info->{$_};
    }else {
      $equality = $xls_info->{$_} eq $saved_json_info->{$_};
    }
    if (not $equality) {
      carp "Not matched $_ : $xls_info->{$_} with $saved_json_info->{$_}";
    }
    $equality;
  }  (keys %$xls_info);
}

1;

__END__
=head1 NAME

SBI::XLS - Process XLS transaction logs from State Bank of India(SBI) statements.

=head1 SYNOPSIS

 use SBI::XLS;

 # make sure the transaction data file matches the current account.
 validate_input("NNNNNN_xls.dat", "jane_doe.json");

 # get the transaction list.
 get_transactions("NNNNNN_xls.dat");

 # write the sanatized transaction logs to a persistant database.
 write_transactions($transaction_list, "database_file.db");

=head1 DESCRIPTION

This module helps process XLS data files provided by SBI that logs bank transactions.
Currently the only responsibility of this module is to update the transaction logs to
another persistant database. 

=head1 AUTHOR

Keutoi (k3tu0isui@gmail.com)

=head1 BUGS

Any activity involving parsing a text which is not standardized has Bugs.
I've tried extensive testing, but getting all the bugs not possible.

=head1 LICENCE

This project is under 0BSD license. Look at the LICENSE file in the
distribution.

=cut
