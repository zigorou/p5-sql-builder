package SQL::Builder;

use strict;
use warnings;

our $VERSION = '0.01';

use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw/upper_case compact strict/);

use Carp::Clan;
use List::Util qw(first);
use Data::Util qw(:check neat);

sub new {
    my ( $class, %args ) = @_;

    $args{upper_case} = 1 unless ( exists $args{upper_case} );
    $args{compact}    = 0 unless ( exists $args{compact} );
    $args{strict} = 0 if ( $args{compact} == 1 );
    $args{strict} = 0 unless ( exists $args{strict} );

    return $class->SUPER::new( \%args );
}

# http://savage.net.au/SQL/sql-99.bnf.html#select%20list
sub _select_list {
    my ( $self, $select_list ) = @_;

    my ( $stmt, @bind ) = @_;

    if ( is_array_ref $select_list ) {
        ( $stmt, @bind ) = $self->_select_list_array_ref($select_list);
    }
    else {
        croak(sprintf('Not supported data type for _select_list() : (%s)', neat($select_list)));
    }

    return ( $stmt, @bind );
}

sub _select_list_array_ref {
    my ( $self, $select_list ) = @_;

    my ( $stmt, @bind );
    my @list;

    for my $sub_list (@$select_list) {
        my ( $sub_stmt, @sub_bind ) = $self->_value_expression($sub_list);
        push( @list, $sub_stmt );
        push( @bind, @sub_bind );
    }

    $stmt = join( $self->compact ? ',' : ', ', @list );

    return ( $stmt, @bind );
}

# http://savage.net.au/SQL/sql-99.bnf.html#value%20expression
sub _value_expression {
    my ( $self, $value_expression ) = @_;

    my ( $stmt, @bind ) = @_;

    if ( is_string($value_expression) ) {
        ( $stmt, @bind ) = ($value_expression);
    }
    elsif ( is_array_ref $value_expression ) {
        ( $stmt, @bind ) =
          $self->_value_expression_array_ref($value_expression);
    }
    elsif ( is_hash_ref $value_expression ) {
        ( $stmt, @bind ) = $self->_value_expression_hash_ref($value_expression);
    }
    else {
        croak(sprintf('Not supported data type for _value_expression() : (%s)', neat($value_expression)));
    }

    return ( $stmt, @bind );
}

sub _value_expression_array_ref {
    my ( $self, $value_expression ) = @_;
    my ( $stmt, @bind )             = @$value_expression;
    return ( $stmt, @bind );
}

sub _value_expression_hash_ref {
    my ( $self, $value_expression ) = @_;

    my ( $stmt, @bind ) =
      $self->_value_expression( $value_expression->{-value} );

    if ( $value_expression->{-with_paren} ) {
        $stmt = ( $self->compact ) ? '(' . $stmt . ')' : '( ' . $stmt . ' )';
    }

    if ( exists $value_expression->{-as} && length $value_expression->{-as} ) {
        $stmt .= $self->_case(' AS ') . $value_expression->{-as};
    }

    return ( $stmt, @bind );
}

# http://savage.net.au/SQL/sql-99.bnf.html#table%20reference
sub _table_reference {
    my ( $self, $table_reference ) = @_;

    my ( $stmt, @bind );

    if ( is_string $table_reference ) {
        $stmt = $table_reference;
    }
    elsif ( is_array_ref $table_reference ) {
        ( $stmt, @bind ) = $self->_table_reference_array_ref($table_reference);
    }
    elsif ( is_hash_ref $table_reference ) {
        ( $stmt, @bind ) = $self->_table_reference_hash_ref($table_reference);
    }
}

sub _table_reference_array_ref {
    my ( $self, $table_reference ) = @_;
    my ( $stmt, @bind )            = @$table_reference;
    return ( $stmt, @bind );
}

sub _table_reference_hash_ref {
    my ( $self, $table_reference ) = @_;

    my ( $stmt, @bind ) = $self->_table_reference( $table_reference->{-table} );

    unless ( is_string $table_reference->{-table} ) {
        $table_reference->{-with_paren} = 1;
    }

    if ( $table_reference->{-with_paren} ) {
        $stmt = ( $self->compact ) ? '(' . $stmt . ')' : '( ' . $stmt . ' )';
    }

    if ( exists $table_reference->{-as} ) {
        unless ( $self->strict ) {
            $stmt .= ' ' . $table_reference->{-as};
        }
        else {
            $stmt .= $self->_case(' AS ') . $table_reference->{-as};
        }
    }

    if ( exists $table_reference->{-cols} ) {
        $stmt .=
          ( $self->compact )
          ? ' (' . $self->_column_name_list( $table_reference->{-cols} ) . ')'
          : ' ( '
          . $self->_column_name_list( $table_reference->{-cols} ) . ' )';
    }

#     if ( exists $table_reference->{-join} ) {
#         my ( $joined_stmt, @joined_bind ) =
#           $self->_joined_table( $self, $table_reference->{-join} );
#     }

    return ( $stmt, @bind );
}

# http://savage.net.au/SQL/sql-99.bnf.html#column%20name%20list
sub _column_name_list {
    my ( $self, $column_name_list ) = @_;
    return join( $self->compact ? ',' : ', ', @$column_name_list );
}

# http://savage.net.au/SQL/sql-99.bnf.html#joined%20table
sub _joined_table {
    my ( $self, $joined_table ) = @_;

    my $join_type = $joined_table->{type};

    if ( first { $join_type eq $_ } qw/inner left right full/ ) {
    }
    elsif ( $join_type eq 'cross' ) {
    }
    elsif ( $join_type eq 'natural' ) {
    }
    elsif ( $join_type eq 'union' ) {
    }
    else {
        croak(sprintf('Not supported join type for _joined_table() : (%s)', neat($join_type)));
    }
}

# http://savage.net.au/SQL/sql-99.bnf.html#search condition
sub _qualified_join {
    my ($self, $joined_table) = @_;
}

# http://savage.net.au/SQL/sql-99.bnf.html#search condition
sub _search_condition {
    my ( $self, $boolean_value_expression ) = @_;

    if ( is_hash_ref $boolean_value_expression ) {
    }
    elsif ( is_array_ref $boolean_value_expression ) {
    }
    else {
        croak(sprintf('Not supported data type for _search_condition() : (%s)', neat($boolean_value_expression)));
    }
}

# http://savage.net.au/SQL/sql-99.bnf.html#boolean%20term
sub _boolean_term {
    my ($self, $boolean_term) = @_;

    my ($stmt, @bind) = @_;
    my @boolean_factors;

    for my $row_value_expression ( keys %$boolean_term ) {
        my $predicate = $boolean_term->{$row_value_expression};

        if ( is_value $predicate ) {
            push( @boolean_factors, sprintf('%s = ?', $row_value_expression) );
            push( @bind, $predicate );
        }
        elsif ( is_scalar_ref $predicate ) {
            push( @boolean_factors, sprintf('%s %s', $row_value_expression, $$predicate) );
        }
        elsif ( is_array_ref $predicate ) {
            my ( $predicate_stmt, @predicate_bind) =  @$predicate;
            push( @boolean_factors, sprintf('%s %s', $row_value_expression, $predicate_stmt) );
            push( @bind, @predicate_bind );
        }
        elsif ( is_hash_ref $predicate ) {
        }
    }
}

sub _case {
    my ( $self, $sql ) = @_;
    return ( $self->upper_case ) ? uc($sql) : lc($sql);
}

1;
__END__

=head1 NAME

SQL::Builder -

=head1 SYNOPSIS

  use SQL::Builder;

=head1 DESCRIPTION

SQL::Builder is

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
