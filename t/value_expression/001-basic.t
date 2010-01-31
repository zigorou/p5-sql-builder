use strict;
use warnings;

use Test::More;
use SQL::Builder;

subtest "_value_expression() with scalar" => sub {
    my $sql = SQL::Builder->new;
    my ( $stmt, @bind );
    ( $stmt, @bind ) = $sql->_value_expression('name');
    is( $stmt, 'name', 'scalar stmt' );
    is_deeply( \@bind, [], 'scalar bind' );
    done_testing;
};

subtest "_value_expression() with array_ref_ref" => sub {
    my $sql = SQL::Builder->new;
    my ( $stmt, @bind );
    ( $stmt, @bind ) = $sql->_value_expression(
        \[ 'UNIX_TIMESTAMP(?) - created_on AS duration', '2010-01-31 00:00:00' ]
    );
    is( $stmt, 'UNIX_TIMESTAMP(?) - created_on AS duration', 'array_ref_ref stmt' );
    is_deeply( \@bind, ['2010-01-31 00:00:00'], 'array_ref_ref bind' );
    done_testing;
};

subtest "_value_expression() with hash_ref" => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_value_expression( +{ -value => 'name' } );

        is( $stmt, 'name', 'hash_ref stmt simple' );
        is_deeply( \@bind, [], 'hash_ref bind simple' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->upper_case(1);
        my ( $stmt, @bind ) =
          $sql->_value_expression( +{ -value => 'nickname', -as => 'displayName' } );
        is( $stmt, 'nickname AS displayName', 'hash_ref stmt with as cause' );
        is_deeply( \@bind, [], 'hash_ref bind with as cause' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->upper_case(0);
        my ( $stmt, @bind ) =
          $sql->_value_expression( +{ -value => 'nickname', -as => 'displayName' } );
        is(
            $stmt,
            'nickname as displayName',
            'hash_ref stmt with as cause, lower case option'
        );
        is_deeply( \@bind, [],
            'hash_ref bind with as cause, lower case option' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->upper_case(1);

        my ( $stmt, @bind ) = $sql->_value_expression(
            +{
                -value =>
                  \[ 'UNIX_TIMESTAMP(?) - created_on', '2010-01-31 00:00:00' ],
                -as => 'duration',
            }
        );
        is(
            $stmt,
            'UNIX_TIMESTAMP(?) - created_on AS duration',
            'hash_ref stmt with as cause, array_ref_ref value, upper_case option'
        );
        is_deeply( \@bind, ['2010-01-31 00:00:00'],
            'hash_ref bind with as cause, array_ref_ref bind, upper_case option' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->upper_case(0);

        my ( $stmt, @bind ) = $sql->_value_expression(
            +{
                -value =>
                  \[ 'UNIX_TIMESTAMP(?) - created_on', '2010-01-31 00:00:00' ],
                -as => 'duration',
            }
        );
        is(
            $stmt,
            'UNIX_TIMESTAMP(?) - created_on as duration',
            'hash_ref stmt with as cause, array_ref_ref value, lower case option'
        );
        is_deeply( \@bind, ['2010-01-31 00:00:00'],
            'hash_ref bind with as cause, array_ref_ref bind, lower case option' );
    }

    {
        my $sql = SQL::Builder->new;
        
        my ( $stmt, @bind ) = $sql->_value_expression(
            +{
                -value =>
                  \[ 'SELECT COUNT(guid) FROM peoples WHERE gender = ? AND status = ?', 'female', '2' ],
                -as => 'total_results',
                -with_paren => 1,
            }
        );

        is(
            $stmt,
            '( SELECT COUNT(guid) FROM peoples WHERE gender = ? AND status = ? ) AS total_results',
            'hash_ref stmt with as cause, array_ref_ref bind, with_paren'
        );
        is_deeply( \@bind, ['female', 2],
            'hash_ref bind with as cause, array_ref_ref bind, with_parent' );
    }

    done_testing;
};

done_testing;

