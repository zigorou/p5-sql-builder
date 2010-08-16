package SQL::Builder;

use strict;
use warnings;
use parent qw(Class::Accessor::Fast);

use Carp::Clan;
use List::Util qw(first);
use Data::Util qw(:check neat);

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw/upper_case compact strict/);

our %SYMBOLED_COMP_OP = (
    -equals                 => '=',
    -not_equals             => '<>',
    -greater_than           => '>',
    -greater_than_or_equals => '>=',
    -less_than              => '<',
    -less_than_or_equals    => '<=',
);

our %COMP_OP = map { ( $_ => undef ) } values %SYMBOLED_COMP_OP;

sub new {
    my ( $class, %args ) = @_;

    $args{upper_case} = 1 unless ( exists $args{upper_case} );
    $args{compact}    = 0 unless ( exists $args{compact} );
    $args{strict} = 0 if ( $args{compact} == 1 );
    $args{strict} = 0 unless ( exists $args{strict} );

    return $class->SUPER::new( \%args );
}

# http://savage.net.au/SQL/sql-99.bnf.html#select list
sub _select_list {
    my ( $self, $select_list ) = @_;

    my ( $stmt, @bind ) = @_;

    if ( is_array_ref $select_list ) {
        ( $stmt, @bind ) = $self->_select_list_array_ref($select_list);
    }
    else {
        croak(
            sprintf( 'Not supported data type for _select_list() : (%s)',
                neat($select_list) )
        );
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
    elsif ( ref $value_expression eq 'REF' && is_array_ref $$value_expression )
    {
        ( $stmt, @bind ) =
          $self->_value_expression_array_ref_ref($value_expression);
    }
    elsif ( is_hash_ref $value_expression ) {
        ( $stmt, @bind ) = $self->_value_expression_hash_ref($value_expression);
    }
    else {
        croak(
            sprintf( 'Not supported data type for _value_expression() : (%s)',
                neat($value_expression) )
        );
    }

    return ( $stmt, @bind );
}

sub _value_expression_array_ref_ref {
    my ( $self, $value_expression ) = @_;
    my ( $stmt, @bind )             = @$$value_expression;
    return ( $stmt, @bind );
}

sub _value_expression_hash_ref {
    my ( $self, $value_expression ) = @_;

    my ( $stmt, @bind ) =
      $self->_value_expression( $value_expression->{-value} );

    if ( $value_expression->{-with_paren} ) {
        $stmt = $self->_paren($stmt);
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
    elsif ( ref $table_reference && is_array_ref $$table_reference ) {
        ( $stmt, @bind ) =
          $self->_table_reference_array_ref_ref($table_reference);
    }
    elsif ( is_hash_ref $table_reference ) {
        ( $stmt, @bind ) = $self->_table_reference_hash_ref($table_reference);
    }
    else {
        croak(
            sprintf( 'Not supported data type for _table_reference() : (%s)',
                neat($table_reference) )
        );
    }
}

sub _table_reference_array_ref_ref {
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
        $stmt = $self->_paren($stmt);
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
        croak(
            sprintf( 'Not supported join type for _joined_table() : (%s)',
                neat($join_type) )
        );
    }
}

# http://savage.net.au/SQL/sql-99.bnf.html#search condition
sub _qualified_join {
    my ( $self, $joined_table ) = @_;
}

# http://savage.net.au/SQL/sql-99.bnf.html#search condition
sub _search_condition {
    my ( $self, $boolean_value_expression ) = @_;

    if ( is_hash_ref $boolean_value_expression ) {
    }
    elsif ( is_array_ref $boolean_value_expression ) {
    }
    else {
        croak(
            sprintf( 'Not supported data type for _search_condition() : (%s)',
                neat($boolean_value_expression) )
        );
    }
}

# http://savage.net.au/SQL/sql-99.bnf.html#boolean%20term
sub _boolean_term {
    my ( $self, $boolean_term ) = @_;

    my ( $stmt, @bind );
    my @boolean_factors;

    for my $row_value_expression ( sort { $a cmp $b } keys %$boolean_term ) {
        my $predicate = $boolean_term->{$row_value_expression};

        my ( $boolean_factor_stmt, @boolean_factor_bind );

        if ( is_value $predicate ) {
            ( $boolean_factor_stmt, @boolean_factor_bind ) =
              $self->_boolean_factor_op( $row_value_expression, '=',
                $predicate );

            push( @boolean_factors, $boolean_factor_stmt );
            push( @bind,            @boolean_factor_bind );
        }
        elsif ( !defined $predicate ) {
            push( @boolean_factors,
                sprintf( '%s IS NULL', $row_value_expression ) );
        }
        elsif ( ref $predicate eq 'REF' && is_array_ref $$predicate ) {
            ( $boolean_factor_stmt, @boolean_factor_bind ) =
              $self->_boolean_factor_array_ref_ref( $row_value_expression,
                $predicate );
            push( @boolean_factors, $boolean_factor_stmt );
            push( @bind,            @boolean_factor_bind );
        }
        elsif ( is_scalar_ref $predicate ) {
            ( $boolean_factor_stmt, @boolean_factor_bind ) =
              $self->_boolean_factor_op( $row_value_expression, '=',
                $predicate );

            push( @boolean_factors, $boolean_factor_stmt );
        }
        elsif ( is_array_ref $predicate ) {
            ( $boolean_factor_stmt, @boolean_factor_bind ) =
              $self->_boolean_factor_function( $row_value_expression, 'IN',
                @$predicate );
            push( @boolean_factors, $boolean_factor_stmt );
            push( @bind,            @boolean_factor_bind );
        }
        elsif ( is_hash_ref $predicate ) {
            ( $boolean_factor_stmt, @boolean_factor_bind ) =
              $self->_boolean_factor_hash_ref( $row_value_expression,
                $predicate );
            push( @boolean_factors, $boolean_factor_stmt );
            push( @bind,            @boolean_factor_bind );
        }
        else {
            croak(
                sprintf( 'Not supported data type for _boolean_term() : (%s)',
                    neat($predicate) )
            );
        }
    }

    $stmt = join( $self->_case(' AND '), @boolean_factors );

    return ( $stmt, @bind );
}

sub _boolean_factor_array_ref_ref {
    my ( $self, $row_value_expression, $predicate ) = @_;

    my ( $statement, @bind ) = @{$$predicate};
    my $stmt = sprintf( '%s %s', $row_value_expression, $statement );

    return ( $stmt, @bind );
}

sub _boolean_factor_hash_ref {
    my ( $self, $row_value_expression, $predicate ) = @_;

    my ( $stmt, @bind );
    my @op_stmts;

    for my $op ( sort { $a cmp $b } keys %$predicate ) {
        my ( $op_stmt, @op_bind );

        if ( first { $op eq $_ } ( keys %COMP_OP, keys %SYMBOLED_COMP_OP ) ) {
            my $predicate_value = $predicate->{$op};
            $op = $self->_normalize_op($op);

            if ( is_value $predicate_value ) {
                ( $op_stmt, @op_bind ) =
                  $self->_boolean_factor_op( $row_value_expression, $op,
                    $predicate_value, );

                push( @bind, @op_bind );
            }
            elsif ( is_scalar_ref $predicate_value ) {
                ($op_stmt) =
                  $self->_boolean_factor_op( $row_value_expression, $op,
                    $predicate_value, );
            }
            elsif ( is_array_ref $predicate_value ) {
                if ( $op eq '=' || $op eq '<>' ) {
                    ( $op_stmt, @op_bind ) =
                      $self->_boolean_factor_function( $row_value_expression,
                        $op eq '=' ? 'IN' : 'NOT IN',
                        @{$predicate_value}, );
                    push( @bind, @op_bind );
                }
                else {
                    my @or_stmts;

                    for (@$predicate_value) {
                        my ( $or_stmt, @op_bind ) =
                          $self->_boolean_factor_op( $row_value_expression, $op,
                            $_ );
                        push( @or_stmts, $or_stmt );
                        push( @bind,     @op_bind );
                    }

                    $op_stmt = join( $self->_case(' OR '), @or_stmts );
                    $op_stmt = $self->_paren($op_stmt);
                }
            }
            elsif ( is_hash_ref $predicate_value ) {
                if (
                    my $quantifier = first { exists $predicate_value->{$_} } (
                        qw/-any -some -all/,
                        ( map { ( $_, lc $_ ) } qw(ANY SOME ALL) )
                    )
                  )
                {
                    my $quantifier_value = $predicate_value->{$quantifier};
                    $quantifier = $self->_normalize_op($quantifier);

                    if ( is_value $quantifier_value ) {
                        $op_stmt =
                          $self->_boolean_factor_quantified(
                            $row_value_expression, $op, $quantifier,
                            $quantifier_value, );
                    }
                    elsif ( ref $quantifier_value eq 'REF'
                        && is_array_ref $$quantifier_value )
                    {
                        ( $op_stmt, @op_bind ) = @$$quantifier_value;
                        $op_stmt =
                          $self->_boolean_factor_quantified(
                            $row_value_expression, $op, $quantifier, $op_stmt,
                          );
                    }
                    else {
                    }
                }
            }
            else {
            }
        }
        elsif (
            first { $op eq $_ } (
                qw/-between -not_between/,
                ( map { $_, lc $_ } ( 'BETWEEN', 'NOT BETWEEN' ) )
            )
          )
        {
            my @predicate_value = @{ $predicate->{$op} };
            $op = $self->_normalize_op($op);

            ( $op_stmt, @op_bind ) =
              $self->_boolean_factor_function( $row_value_expression, $op,
                splice( @predicate_value, 0, 2 ),
              );

            push( @bind, @op_bind );
        }
        elsif ( first { $op eq $_ }
            ( qw/-in -not_in/, ( map { $_, lc $_ } ( 'IN', 'NOT IN' ) ) ) )
        {
            my @predicate_value = @{ $predicate->{$op} };
            $op = $self->_normalize_op($op);

            ( $op_stmt, @op_bind ) =
              $self->_boolean_factor_function( $row_value_expression, $op,
                @predicate_value, );

            push( @bind, @op_bind );
        }
        elsif (
            first { $op eq $_ } (
                qw/-like -not_like/,
                ( map { $_, lc $_ } ( 'LIKE', 'NOT LIKE' ) )
            )
          )
        {
            my $predicate_value = $predicate->{$op};
            $op = $self->_normalize_op($op);

            ( $op_stmt, @op_bind ) =
              $self->_boolean_factor_op( $row_value_expression, $op,
                $predicate_value, );

            push( @bind, @op_bind );
        }
        elsif (
            first { $op eq $_ } (
                qw/-is_null -is_not_null/,
                ( map { $_, lc $_ } ( 'IS NULL', 'IS NOT NULL' ) )
            )
          )
        {
            $op = $self->_normalize_op($op);
            $op_stmt = sprintf( '%s %s', $row_value_expression, $op );
        }

        push( @op_stmts, $op_stmt );
    }

    $stmt = join( $self->_case(' AND '), @op_stmts );

    return ( $stmt, @bind );
}

sub _boolean_factor_op {
    my ( $self, $row_value_expression, $op, $bind ) = @_;

    my ( $stmt, @bind );

    if ( is_value $bind ) {
        $stmt = sprintf(
            ( exists $COMP_OP{$op} && $self->compact ) ? '%s%s?' : '%s %s ?',
            $row_value_expression, $self->_case($op), );
        push( @bind, $bind );
    }
    elsif ( is_scalar_ref $bind ) {
        $stmt = sprintf(
            ( exists $COMP_OP{$op} && $self->compact ) ? '%s%s%s' : '%s %s %s',
            $row_value_expression, $self->_case($op), $$bind );
    }

    return ( $stmt, @bind );
}

sub _boolean_factor_function {
    my ( $self, $row_value_expression, $function, @args ) = @_;

    my ( $stmt, @bind );

    $stmt = sprintf(
        $self->compact ? '%s %s(%s)' : '%s %s (%s)',
        $row_value_expression,
        $self->_case($function),
        join(
            $self->compact ? ',' : ', ',
            ( map { ref $_ ? $$_ : '?' } @args )
        )
    );

    push( @bind, grep { !ref $_ } @args );

    return ( $stmt, @bind );
}

sub _boolean_factor_quantified {
    my ( $self, $row_value_expression, $op, $quantified, $query ) = @_;

    my ($stmt);

    $stmt = sprintf( ( exists $COMP_OP{$op} && $self->compact )
        ? '%s%s%s(%s)'
        : '%s %s %s ( %s )',
        $row_value_expression, $op, $self->_case($quantified), $query, );

    return ($stmt);
}

sub _normalize_op {
    my ( $self, $op ) = @_;

    return $SYMBOLED_COMP_OP{$op} if ( exists $SYMBOLED_COMP_OP{$op} );
    return $op unless ( $op =~ m/^-(.*)$/ );
    return $self->_case( join( ' ', split( /_/, $1 ) ) );
}

sub _paren {
    my ( $self, $sql ) = @_;
    return $self->compact ? '(' . $sql . ')' : '( ' . $sql . ' )';
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
