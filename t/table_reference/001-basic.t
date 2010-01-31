use strict;
use warnings;

use Test::More;
use SQL::Builder;

subtest 'table scalar' => sub {
    {
        my $sql = SQL::Builder->new;

        my ( $stmt, @bind ) = $sql->_table_reference('world');
        is( $stmt, 'world', 'scalar stmt simple' );
        is_deeply( \@bind, [], 'scalar bind simple' );
    }

    done_testing;
};

subtest 'table array_ref' => sub {
    {
        my $sql = SQL::Builder->new;

        my ( $stmt, @bind ) = $sql->_table_reference(
            [
'country INNER JOIN city ON country.id = city.country_id AND city.population > ?',
                1000000
            ]
        );
        is(
            $stmt,
'country INNER JOIN city ON country.id = city.country_id AND city.population > ?',
            'array_ref stmt simple'
        );
        is_deeply( \@bind, [1000000], 'array_ref bind simple' );
    }

    done_testing;
};

subtest 'table hash_ref' => sub {
    {
        my $sql = SQL::Builder->new;

        my ( $stmt, @bind ) = $sql->_table_reference( +{ -table => 'world' } );
        is( $stmt, 'world', 'hash_ref stmt simple' );
        is_deeply( \@bind, [], 'hash_ref bind simple' );
    }

    {
        my $sql = SQL::Builder->new;

        my ( $stmt, @bind ) =
          $sql->_table_reference( +{ -table => 'world', -as => 'w' } );
        is( $stmt, 'world w', 'hash_ref stmt with as cause' );
        is_deeply( \@bind, [], 'hash_ref bind with as cause' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->strict(1);

        my ( $stmt, @bind ) =
          $sql->_table_reference( +{ -table => 'world', -as => 'w' } );
        is( $stmt, 'world AS w', 'hash_ref stmt with as cause, strict option' );
        is_deeply( \@bind, [], 'hash_ref bind with as cause, strict option' );
    }

    {
        my $sql = SQL::Builder->new;

        my ( $stmt, @bind ) = $sql->_table_reference(
            +{
                -table => 'world',
                -as    => 'w',
                -cols  => [qw/id name population/]
            }
        );
        is(
            $stmt,
            'world w ( id, name, population )',
            'hash_ref stmt with as cause, cols cause'
        );
        is_deeply( \@bind, [], 'hash_ref bind with as cause, cols cause' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->strict(1);

        my ( $stmt, @bind ) = $sql->_table_reference(
            +{
                -table => [
'SELECT * FROM country INNER JOIN city ON country.id = city.country_id WHERE city.population > ? AND city.type = ?',
                    1000000,
                    3
                ],
                -as   => 'c',
                -cols => [qw/id name population/]
            }
        );
        is(
            $stmt,
'( SELECT * FROM country INNER JOIN city ON country.id = city.country_id WHERE city.population > ? AND city.type = ? ) AS c ( id, name, population )',
'hash_ref stmt with array_ref table, as cause, cols cause, strict option'
        );
        is_deeply(
            \@bind,
            [ 1000000, 3 ],
'hash_ref stmt with array_ref table, as cause, cols cause, strict option'
        );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->strict(1);

        my ( $stmt, @bind ) = $sql->_table_reference(
            +{
                -table => +{
                    -table =>
'SELECT * FROM country INNER JOIN city ON country.id = city.country_id',
                },
                -as   => 'c',
                -cols => [qw/id name population/]
            }
        );
        is(
            $stmt,
'( SELECT * FROM country INNER JOIN city ON country.id = city.country_id ) AS c ( id, name, population )',
'hash_ref stmt with hash_ref table, as cause, cols cause, strict option'
        );
        is_deeply( \@bind, [],
'hash_ref stmt with hash_ref table, as cause, cols cause, strict option'
        );
    }

    done_testing;
};

done_testing;
