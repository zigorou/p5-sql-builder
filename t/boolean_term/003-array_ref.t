use strict;
use warnings;

use Test::More;
use Tie::Hash::Sorted;

use SQL::Builder;

subtest '_boolean_term() array_ref' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_boolean_term( +{ id => [ 1, 5, 7 ], } );

        is( $stmt, 'id IN (?, ?, ?)', 'array_ref stmt simple' );
        is_deeply( \@bind, [1, 5, 7], 'array_ref bind simple' );
    }

    done_testing;
};

done_testing;
