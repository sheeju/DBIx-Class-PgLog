#!/usr/bin/env perl

# Developed by Sheeju Alex
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# Changelog:
# 2014-08-18 - created

use FindBin;
use Getopt::Std;
use Data::Dumper;
use Test::More;

use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/lib";

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

BEGIN {use_ok( 'PgLogTest::Schema' ) };
BEGIN {use_ok( 'PgLogTest::Schema::Result::User' ) };
done_testing();
