package DBIx::Class::PgLog;

=head1 NAME

DBIx::Class::PgLog - The great new DBIx::Class::PgLog!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use DBIx::Class::PgLog;

    my $foo = DBIx::Class::PgLog->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

# local $DBIx::Class::AuditLog::enabled = 0;
# can be set to temporarily disable audit logging
our $enabled = 1;

sub insert {
    my $self = shift;

    return $self->next::method(@_) if !$enabled || $self->in_storage;

    my $result = $self->next::method(@_);

	my $action = "INSERT";

	my %column_data = $result->get_columns;
	$self->_store_changes( $action, $result, {}, \%column_data );

    return $result;
}

sub update {
    my $self = shift;

    return $self->next::method(@_) if !$enabled;

    my $stored_row      = $self->get_from_storage;
    my %new_data        = $self->get_columns;
    my @changed_columns = keys %{ $_[0] || {} };

    my $result = $self->next::method(@_);

    return unless $stored_row; # update on deleted row - nothing to log

    my %old_data = $stored_row->get_columns;

    if (@changed_columns) {
        @new_data{@changed_columns} = map $self->get_column($_),
            @changed_columns;
    }

=pod

    foreach my $col ( $self->columns ) {
        if ( $self->_force_audit($col) ) {
            $old_data{$col} = $stored_row->get_column($col)
                unless defined $old_data{$col};
            $new_data{$col} = $self->get_column($col)
                unless defined $new_data{$col};
        }
    }

    # remove unwanted columns
    foreach my $key ( keys %new_data ) {
        next if $self->_force_audit($key);    # skip forced cols
        if (   defined $old_data{$key}
            && defined $new_data{$key}
            && $old_data{$key} eq $new_data{$key}
            || !defined $old_data{$key} && !defined $new_data{$key} )
        {
            delete $new_data{$key};           # remove unchanged cols
        }
    }

=cut
    if ( keys %new_data ) {
		my $action = "UPDATE";
		$self->_store_changes( $action, $result, \%old_data, \%new_data );
    }

    return $result;
}

sub delete {
    my $self = shift;

    return $self->next::method(@_) if !$enabled;

    my $stored_row = $self->get_from_storage;

    my $result = $self->next::method(@_);

	my $action = "DELETE";
	my %old_data = $stored_row->get_columns;
	$self->_store_changes( $action, $result, \%old_data, {} );

    return $result;
}

sub _pg_log_schema {
    my $self = shift;
    return $self->result_source->schema->pg_log_schema;
}

sub _store_changes {
    my $self       = shift;
    my $action	   = shift;
    my $row		   = shift;
    my $old_values = shift;
    my $new_values = shift;

	my $table = $row->result_source_instance->name; 
	my $log_data = {};

	foreach my $column (
		keys %{$new_values} ? keys %{$new_values} : keys %{$old_values} )
	{
		if ( $self->_do_pg_log($column) ) {
			push(@{$log_data->{Columns}}, $column);
			if ( $self->_do_modify_pg_log_value($column) ) {
				push(@{$log_data->{NewValues}}, $self->_modify_pg_log_value( $column, $new_values->{$column} ));
				push(@{$log_data->{OldValues}}, $self->_modify_pg_log_value( $column, $old_values->{$column} ));
			} else {
				push(@{$log_data->{NewValues}}, $new_values->{$column});
				push(@{$log_data->{OldValues}}, $old_values->{$column});
			}

		}

	}
	
	$log_data->{Table} = $table;
	$log_data->{TableId} = $row->can(Id)?$row->Id:$row->id;
	$log_data->{TableAction} = $action;

	$self->_pg_log_schema->pg_log_create_log($log_data);

}

sub _do_pg_log {
    my $self   = shift;
    my $column = shift;

    my $info = $self->column_info($column);
    return defined $info->{pg_log_column}
        && $info->{pg_log_column} == 0 ? 0 : 1;
}

sub _do_modify_pg_log_value {
    my $self   = shift;
    my $column = shift;

    my $info = $self->column_info($column);

    return $info->{modify_pg_log_value} ? 1 : 0;
}

sub _modify_pg_log_value {
    my $self   = shift;
    my $column = shift;
    my $value  = shift;

    my $info = $self->column_info($column);
    my $meth = $info->{modify_pg_log_value};
    return $value
        unless defined $meth;

    return &$meth( $self, $value )
        if ref($meth) eq 'CODE';

    $meth = "modify_pg_log_$column"
        unless $self->can($meth);

    return $self->$meth($value)
        if $self->can($meth);

    die "unable to find modify_pg_log_method ($meth) for $column in $self";

}


=head1 AUTHOR

Sheeju Alex, C<< <sheeju at exceleron.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dbix-class-pglog at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-Class-PgLog>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBIx::Class::PgLog


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-Class-PgLog>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-Class-PgLog>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-Class-PgLog>

=item * Search CPAN

L<http://search.cpan.org/dist/DBIx-Class-PgLog/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Sheeju Alex.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of DBIx::Class::PgLog
