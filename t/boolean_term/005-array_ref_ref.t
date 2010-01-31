use strict;
use warnings;

use Test::More;
use Tie::Hash::Sorted;

use SQL::Builder;

subtest '_boolean_term() array_ref_ref' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_boolean_term( +{ id => \['& ? = ?', 2, 0], } );

        is( $stmt, 'id & ? = ?', 'array_ref_ref stmt simple' );
        is_deeply( \@bind, [2, 0], 'array_ref_ref bind simple' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_boolean_term( +{ id => \['& ? = ?', 2, 0], name => \['LIKE ?', '%bob%'] } );

        is( $stmt, 'id & ? = ? AND name LIKE ?', 'array_ref_ref stmt multi' );
        is_deeply( \@bind, [2, 0, '%bob%'], 'array_ref_ref bind multi' );
    }

    done_testing;
};

done_testing;
