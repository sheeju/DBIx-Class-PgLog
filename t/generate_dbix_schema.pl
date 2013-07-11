#!/usr/bin/env perl

use FindBin;
use Getopt::Std;
use Data::Dumper;

use lib "$FindBin::Bin/../lib";

use DBIx::Class::Schema::Loader 'make_schema_at';

our ($opt_F, $opt_d);
getopts('Fd');

make_schema_at('PgLogTest::Schema',
	       {
			   debug => !!($opt_d), 
			   really_erase_my_files => !!($opt_F),
			   dump_directory=>"$FindBin::Bin/lib",
			   overwrite_modifications=>1,
               preserve_case=>1,
		   },
	       ['dbi:Pg:dbname=pg_log_test','sheeju','sheeju', {'quote_char' => '"', 'quote_field_names' => '0', 'name_sep' => '.' }],
	      );
