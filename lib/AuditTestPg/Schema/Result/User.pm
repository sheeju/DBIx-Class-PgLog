use utf8;
package AuditTestPg::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

AuditTestPg::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<User>

=cut

__PACKAGE__->table("User");

=head1 ACCESSORS

=head2 Id

  accessor: 'id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: '"User_Id_seq"'

=head2 LastLoginEpoch

  accessor: 'last_login_epoch'
  data_type: 'integer'
  is_nullable: 1

=head2 Email

  accessor: 'email'
  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 PasswordSalt

  accessor: 'password_salt'
  data_type: 'bytea'
  is_nullable: 0

=head2 PasswordHash

  accessor: 'password_hash'
  data_type: 'bytea'
  is_nullable: 0

=head2 PasswordHashType

  accessor: 'password_hash_type'
  data_type: 'enum'
  extra: {custom_type_name => "passwordhashtype",list => ["MD5","SHA-1","SHA-256"]}
  is_nullable: 0

=head2 Status

  accessor: 'status'
  data_type: 'enum'
  extra: {custom_type_name => "userstatustype",list => ["Inactive","Active"]}
  is_nullable: 0

=head2 Type

  accessor: 'type'
  data_type: 'enum'
  extra: {custom_type_name => "usertypetype",list => ["Admin","Utility","Account","Api"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "Id",
  {
    accessor          => "id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "\"User_Id_seq\"",
  },
  "LastLoginEpoch",
  {
    accessor    => "last_login_epoch",
    data_type   => "integer",
    is_nullable => 1,
  },
  "Email",
  { accessor => "email", data_type => "varchar", is_nullable => 0, size => 255 },
  "PasswordSalt",
  { accessor => "password_salt", data_type => "bytea", is_nullable => 0 },
  "PasswordHash",
  { accessor => "password_hash", data_type => "bytea", is_nullable => 0 },
  "PasswordHashType",
  {
    accessor    => "password_hash_type",
    data_type   => "enum",
    extra       => {
                     custom_type_name => "passwordhashtype",
                     list => ["MD5", "SHA-1", "SHA-256"],
                   },
    is_nullable => 0,
  },
  "Status",
  {
    accessor    => "status",
    data_type   => "enum",
    extra       => {
                     custom_type_name => "userstatustype",
                     list => ["Inactive", "Active"],
                   },
    is_nullable => 0,
  },
  "Type",
  {
    accessor    => "type",
    data_type   => "enum",
    extra       => {
                     custom_type_name => "usertypetype",
                     list => ["Admin", "Utility", "Account", "Api"],
                   },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</Id>

=back

=cut

__PACKAGE__->set_primary_key("Id");


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-06-25 12:24:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Oj1FVNdGzbi+yC24BNJSbQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->load_components(qw/ PgLog /);
1;
