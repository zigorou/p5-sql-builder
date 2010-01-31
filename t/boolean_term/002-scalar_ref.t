use strict;
use warnings;

use Test::More;
use SQL::Builder;

subtest '_boolean_term() scalar_ref' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => \'community_member.guid' } );

        is( $stmt, 'id = community_member.guid', 'scalar_ref stmt simple' );
        is_deeply( \@bind, [], 'scalar_ref bind simple' );
    }

    {
        my $sql = SQL::Builder->new;

        my ( $stmt, @bind ) = $sql->_boolean_term(
            +{
                id         => \'community_member.guid',
                created_on => \'UNIX_TIMESTAMP()'
            }
        );

        is(
            $stmt,
            'created_on = UNIX_TIMESTAMP() AND id = community_member.guid',
            'scalar_ref stmt multi'
        );
        is_deeply( \@bind, [], 'scalar_ref bind multi' );
    }

    done_testing;
};

done_testing;
