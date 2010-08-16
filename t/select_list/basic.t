use strict;
use warnings;

use Test::More;
use Data::Util qw(neat);
use SQL::Builder;

sub test_select_list {
    my %specs = @_;
    my ( $input, $expects, $desc ) = @specs{qw/input expects desc/};

    subtest $desc => sub {
        my $sql = SQL::Builder->new;
        $sql->compact( $input->{compact} );
        my ( $stmt, @bind ) = $sql->_select_list( $input->{args} );
        is( $stmt, $expects->{stmt},
            'expected statement: ' . $expects->{stmt} );
        is_deeply( \@bind, $expects->{bind},
            'expected bind: ' . neat( $expects->{bind} ) );
        done_testing;
    };
}

test_select_list(
    desc  => 'inputed basic array ref',
    input => +{
        compact => 0,
        args    => [qw/id name created_on updated_on/],
    },
    expects => +{
        stmt => 'id, name, created_on, updated_on',
        bind => [],
    },
);

test_select_list(
    desc  => 'inputed basic array ref with compact',
    input => +{
        compact => 1,
        args    => [qw/id name created_on updated_on/],
    },
    expects => +{
        stmt => 'id,name,created_on,updated_on',
        bind => [],
    },
);

test_select_list(
    desc  => 'single reference of array reference',
    input => +{
        compact => 0,
        args    => [ \[ 'COALESCE(price, ?) AS price', 0 ] ],
    },
    expects => +{
        stmt => 'COALESCE(price, ?) AS price',
        bind => [0],
    },
);

test_select_list(
    desc  => 'single hash reference',
    input => +{
        compact => 0,
        args    => [
            +{
                -value      => 'updated_on - created_on',
                -as         => 'duration',
                -with_paren => 1,
            }
        ],
    },
    expects => +{
        stmt => '( updated_on - created_on ) AS duration',
        bind => [],
    },
);

test_select_list(
    desc  => 'single hash reference with compact',
    input => +{
        compact => 1,
        args    => [
            +{
                -value      => 'updated_on - created_on',
                -as         => 'duration',
                -with_paren => 1,
            }
        ],
    },
    expects => +{
        stmt => '(updated_on - created_on) AS duration',
        bind => [],
    },
);

test_select_list(
    desc  => 'complex array ref',
    input => +{
        compact => 0,
        args    => [
            qw/name/,
            \[ 'COALESCE(price, ?) AS price', 0 ],
            +{
                -value      => 'updated_on - created_on',
                -as         => 'duration',
                -with_paren => 1
            },
        ]
    },
    expects => +{
        stmt =>
'name, COALESCE(price, ?) AS price, ( updated_on - created_on ) AS duration',
        bind => [0],
    },
);

test_select_list(
    desc  => 'complex array ref with compact',
    input => +{
        compact => 1,
        args    => [
            qw/name/,
            \[ 'COALESCE(price, ?) AS price', 0 ],
            +{
                -value      => 'updated_on - created_on',
                -as         => 'duration',
                -with_paren => 1
            },
        ]
    },
    expects => +{
        stmt =>
'name,COALESCE(price, ?) AS price,(updated_on - created_on) AS duration',
        bind => [0],
    },
);

done_testing;
