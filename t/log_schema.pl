#/usr/bin/env perl

use Modern::Perl;

use Data::Printer;
use Try::Tiny;

use lib '../lib';
use DBIx::Class::PgLog;
use lib 'lib';
use PgLogTest::Schema;
use Data::Dumper;

my $schema = PgLogTest::Schema->connect( "DBI:Pg:dbname=pg_log_test",
    "sheeju", "sheeju", { RaiseError => 1, PrintError => 1, 'quote_char' => '"', 'quote_field_names' => '0', 'name_sep' => '.' } ) || die("cant connect");;

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
            }
        );
    },
    {   
		Description => "adding new user: JohnSample with No Role",
        UserId => 1, 
    },
);


$schema->txn_do(
    sub {
        $user_01->update({Email => 'sheeju@exceleron.com'});
    },
    {   
		Description => "Updating User JohnSample",
        UserId => 1, 
    },
);

$schema->txn_do(
    sub {
        $user_01->delete;
    },
    {   
		Description => "Deleteing User JohnSample",
        UserId => 1, 
    },
);

$schema->txn_do(
    sub {
        my $user = $schema->resultset('User')->search( { Email => 'jeremy@purepwnage.com' } )->first;
		$user->delete if($user);

        $schema->resultset('User')->create(
            {   Name  => "TehPnwerer",
                Email => 'jeremy@purepwnage.com',
				PasswordSalt => 'sheeju',
                PasswordHash => 'sheeju',
                Status => 'Active',
            }
        );
    },
    { 
		Description => "adding new user: TehPwnerer -- no admin Role", 
        UserId => 1, 
	},
);

$schema->txn_do(
    sub {
        my $user = $schema->resultset('User')->search( { Email => 'admin@test.com' } )->first;
		if($user) {
			$schema->resultset('UserRole')->search( { UserId => $user->id } )->delete_all;
			$user->delete;
		}
        $user = $schema->resultset('User')->create(
            {   Name  => "Admin User",
                Email => 'admin@test.com',
				PasswordSalt => 'sheeju',
                PasswordHash => 'sheeju',
                Status => 'Active',
            }
        );
        my $role = $schema->resultset('Role')->search( { Name => "Admin" } )->first;
        $schema->resultset('UserRole')->create(
            {   
				UserId => $user->id, 
                RoleId => $role->id, 
            }
        );

    },
    { 
		Description => "Multi Action User -- With Admin Role", 
        UserId => 1, 
	},
);

my $user = $schema->resultset('User')->search( { Email => 'nolog@test.com' } )->first;
$user->delete if($user);
$schema->resultset('User')->create(
    {   
		Name  => "NonLogsetUser",
        Email => 'nolog@test.com',
		PasswordSalt => 'sheeju',
		PasswordHash => 'sheeju',
		Status => 'Active',
    }
);

1;
