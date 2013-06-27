#/usr/bin/env perl

use Modern::Perl;

use Data::Printer;
use Try::Tiny;

use lib '../lib';
use AuditTestPg::Schema;
use DBIx::Class::PgLog;
use Data::Dumper;

my $schema = AuditTestPg::Schema->connect( "DBI:Pg:dbname=pg_log_test",
    "sheeju", "sheeju", { RaiseError => 1, PrintError => 1, 'quote_char' => '"', 'quote_field_names' => '0', 'name_sep' => '.' } ) || die("cant connect");;

#['dbi:Pg:dbname=audit_test','sheeju','sheeju', {'quote_char' => '"', 'quote_field_names' => '0', 'name_sep' => '.' }],

my $pgl_schema;

# deploy the audit log schema if it's not installed
try {
	print "trying............\n";
    $pgl_schema = $schema->pg_log_schema;
	print "trying............\n";
    my $changesets = $pgl_schema->resultset('PgLogLog')->all;
	print "trying............\n";
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
                Email => 'jsample@sample.com',
                PasswordSalt => 'sheeju',
                PasswordHash => 'sheeju',
                PasswordHashType => 'MD5',
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

exit;

$schema->txn_do(
    sub {
        $user_01->phone('111-222-3333');
        $user_01->update();
    },
    {   description => "updating phone of JohnSample",
        user        => "TestAdminUser",
    },
);


$schema->txn_do(
    sub {
        $user_01->delete;
    },
    {   description => "delete user: JohnSample",
        user_id     => "YetAnotherAdminUser",
    },
);

$schema->txn_do(
    sub {
        $schema->resultset('User')->create(
            {   name  => "TehPnwerer",
                email => 'jeremy@purepwnage.com',
                phone => '999-888-7777',
            }
        );
    },
    { description => "adding new user: TehPwnerer -- no admin user", },
);

my $superman;
my $spiderman;
$schema->txn_do(
    sub {
        $superman = $schema->resultset('User')->create(
            {   name  => "Superman",
                email => 'ckent@dailyplanet.com',
                phone => '123-456-7890',
            }
        );
        $superman->update(
            {   name  => "Superman",
                email => 'ckent@dailyplanet.com',
                phone => '123-456-7890',
            }
        );
        $spiderman = $schema->resultset('User')->create(
            {   name  => "Spiderman",
                email => 'ppaker@dailybugle.com',
                phone => '987-654-3210',
            }
        );
        $schema->resultset('User')->search( { name => "Spiderman" } )
            ->first->update(
            {   name  => "Spiderman",
                email => 'pparker@dailybugle.com',
                phone => '987-654-3210',
            }
            );
        $schema->resultset('User')->search( { name => "TehPnwerer" } )
            ->first->update(
            { name => 'TehPwnerer', phone => '416-123-4567' } );
    },
    {   description => "multi-action changeset",
        user_id     => "ioncache",
    },
);

$schema->resultset('User')->create(
    {   name  => "NonChangesetUser",
        email => 'ncu@oanda.com',
        phone => '987-654-3210',
    }
);

$schema->txn_do(
    sub {
        $schema->resultset('User')->create(
            {   name  => "Drunk Hulk",
                email => 'drunkhulk@twitter.com',
                phone => '123-456-7890',
            }
        );
        $schema->resultset('User')->search( { name => "Drunk hulk" } )
            ->first->update( { email => 'drunkhulk@everywhere.com' } );
    },
    { user_id => "markj", },
);

$schema->resultset('User')->search( { name => "NonChangesetUser" } )
    ->first->update( { phone => '543-210-9876' } );

my $atbdu = $schema->resultset('User')->create(
    {   name  => "AboutToBeDeletedUser",
        email => 'atbdu@oanda.com',
        phone => '987-654-3210',
    }
);

$atbdu->delete;


1;
