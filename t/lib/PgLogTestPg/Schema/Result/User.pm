use utf8;
package PgLogTestPg::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PgLogTestPg::Schema::Result::User

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

=head2 Name

  accessor: 'name'
  data_type: 'varchar'
  is_nullable: 0
  size: 255

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

=head2 Status

  accessor: 'status'
  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 Type

  accessor: 'type'
  data_type: 'varchar'
  is_nullable: 0
  size: 64

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
  "Name",
  { accessor => "name", data_type => "varchar", is_nullable => 0, size => 255 },
  "Email",
  { accessor => "email", data_type => "varchar", is_nullable => 0, size => 255 },
  "PasswordSalt",
  { accessor => "password_salt", data_type => "bytea", is_nullable => 0 },
  "PasswordHash",
  { accessor => "password_hash", data_type => "bytea", is_nullable => 0 },
  "Status",
  { accessor => "status", data_type => "varchar", is_nullable => 0, size => 64 },
  "Type",
  { accessor => "type", data_type => "varchar", is_nullable => 0, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</Id>

=back

=cut

__PACKAGE__->set_primary_key("Id");


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-06-28 16:25:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:x7uMvywI0RcEXjO2RiFlWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->load_components(qw/ PgLog /);
1;
