use strict;
use warnings;

use Test::More;
use SQL::Builder;

subtest '_boolean_term() value' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_boolean_term( +{ id => 10, } );

        is( $stmt, 'id = ?', 'value stmt simple' );
        is_deeply( \@bind, [10], 'value bind simple' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => 10, name => 'bob' }, );

        is( $stmt, 'id = ? AND name = ?', 'value stmt multi' );
        is_deeply( \@bind, [ 10, 'bob' ], 'value bind multi' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => 10, name => 'bob', status => 1 }, );

        is( $stmt, 'id = ? AND name = ? AND status = ?', 'value stmt multi 2' );
        is_deeply( \@bind, [ 10, 'bob', 1 ], 'value bind multi 2' );
    }

    done_testing;
};

done_testing;
