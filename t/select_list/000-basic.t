use strict;
use warnings;

use Test::More;
use SQL::Builder;

subtest '_select_list() with array_ref' => sub {
    {
        my $sql = SQL::Builder->new;
        $sql->compact(0);

        my ($stmt, @bind) = $sql->_select_list(
            [ qw/id name created_on updated_on/ ],
        );
        is( $stmt, 'id, name, created_on, updated_on', 'array_ref stmt simple' );
        is_deeply( \@bind, [], 'array_ref bind simple' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->compact(1);

        my ($stmt, @bind) = $sql->_select_list(
            [ qw/id name created_on updated_on/ ],
        );
        is( $stmt, 'id,name,created_on,updated_on', 'array_ref stmt simple with compact option' );
        is_deeply( \@bind, [], 'array_ref bind simple with compact option' );
    }

    {
        my $sql = SQL::Builder->new;

        my ($stmt, @bind) = $sql->_select_list(
            [ qw/name/, [ 'COALESCE(price, ?) AS price', 0 ], +{ -value => 'updated_on - created_on', -as => 'duration', -with_paren => 1 }, ],
        );
        
        is( $stmt, 'name, COALESCE(price, ?) AS price, ( updated_on - created_on ) AS duration', 'array_ref stmt with various value_expressions' );
        is_deeply( \@bind, [ 0 ], 'array_ref bind with various value_expressions' );
    }

    done_testing;
};

done_testing;
