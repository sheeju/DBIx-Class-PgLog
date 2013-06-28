#/usr/bin/env perl

use Modern::Perl;

use Data::Printer;
use Try::Tiny;

use lib '../lib';
use DBIx::Class::PgLog;
use lib 'lib';
use PgLogTestPg::Schema;
use Data::Dumper;

my $schema = PgLogTestPg::Schema->connect( "DBI:Pg:dbname=pg_log_test",
    "sheeju", "sheeju", { RaiseError => 1, PrintError => 1, 'quote_char' => '"', 'quote_field_names' => '0', 'name_sep' => '.' } ) || die("cant connect");;

#['dbi:Pg:dbname=audit_test','sheeju','sheeju', {'quote_char' => '"', 'quote_field_names' => '0', 'name_sep' => '.' }],

my $pgl_schema;

# deploy the audit log schema if it's not installed
try {
    $pgl_schema = $schema->pg_log_schema;
    my $changesets = $pgl_schema->resultset('PgLogLog')->all;
	print Dumper($changesets);
}
catch {
	print "deploying............\n";
	$pgl_schema->deploy;
};

my $user_01;
$schema->txn_do(
    sub {
        $user_01 = $schema->resultset('User')->create(
            {   
				Name => 'JohnSample',
                Email => 'jsample@sample.com',
                PasswordSalt => 'sheeju',
                PasswordHash => 'sheeju',
                Status => 'Active',
                Type => 'Admin',
            }
        );
    },
    {   
		Description => "adding new user: JohnSample",
        UserId => 1, 
        ShardId => 10, 
    },
);


$schema->txn_do(
    sub {
        $user_01->update({Email => 'sheeju@exceleron.com'});
    },
    {   
		Description => "Updating User JohnSample",
        UserId => 1, 
        ShardId => 10, 
    },
);

$schema->txn_do(
    sub {
        $user_01->delete;
    },
    {   
		Description => "Deleteing User JohnSample",
        UserId => 1, 
        ShardId => 10, 
    },
);

$schema->txn_do(
    sub {
        $schema->resultset('User')->create(
            {   Name  => "TehPnwerer",
                Email => 'jeremy@purepwnage.com',
				PasswordSalt => 'sheeju',
                PasswordHash => 'sheeju',
                Status => 'Active',
                Type => 'User',
            }
        );
    },
    { 
		Description => "adding new user: TehPwnerer -- no admin user", 
        UserId => 1, 
        ShardId => 10, 
	},
);

my $superman;
my $spiderman;
$schema->txn_do(
    sub {
        $superman = $schema->resultset('User')->create(
            {   Name  => "Superman",
                Email => 'ckent@dailyplanet.com',
				PasswordSalt => 'sheeju',
                PasswordHash => 'sheeju',
                Status => 'Active',
                Type => 'Super',
            }
        );
        $superman->update(
            {   Name  => "Superman",
                Email => 'ckent@dailyplanet.com',
            }
        );
        $spiderman = $schema->resultset('User')->create(
            {   Name  => "Spiderman",
                Email => 'ppaker@dailybugle.com',
				PasswordSalt => 'sheeju',
                PasswordHash => 'sheeju',
                Status => 'Active',
                Type => 'Admin',
            }
        );
        $schema->resultset('User')->search( { Name => "Spiderman" } )
            ->first->update(
            {   
				Name  => "Spiderman",
                Email => 'pparker@dailybugle.com',
            }
            );
        $schema->resultset('User')->search( { Name => "TehPnwerer" } )
            ->first->update(
            { Name => 'TehPwnerer' } );
    },
    {   
		Description => "multi-action changeset",
        UserId => 1, 
        ShardId => 10, 
    },
);

$schema->resultset('User')->create(
    {   
		Name  => "NonLogsetUser",
        Email => 'ncu@oanda.com',
		PasswordSalt => 'sheeju',
		PasswordHash => 'sheeju',
		Status => 'Active',
		Type => 'Admin',
    }
);

$schema->txn_do(
    sub {
        $schema->resultset('User')->create(
            {   
				Name  => "Drunk Hulk",
                Email => 'drunkhulk@twitter.com',
				PasswordSalt => 'sheeju',
				PasswordHash => 'sheeju',
				Status => 'Active',
				Type => 'Admin',
            }
        );
        $schema->resultset('User')->search( { Name => "Drunk hulk" } )
            ->first->update( { Email => 'drunkhulk@everywhere.com' } );
    },
    { 
        UserId => 1, 
        ShardId => 10, 
	},
);

1;
