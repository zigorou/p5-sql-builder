use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::SQL::Builder::Util qw(test_boolean_term);

test_boolean_term(
    desc    => 'single key-value pair',
    input   => +{ args => +{ id => [ 1, 3, 5 ], }, },
    expects => +{
        stmt => 'id IN (?, ?, ?)',
        bind => [ 1, 3, 5 ],
    },
);

test_boolean_term(
    desc => 'single key-value pair with compact',
    input =>
      +{ new_args => +{ compact => 1 }, args => +{ id => [ 1, 3, 5 ], }, },
    expects => +{
        stmt => 'id IN(?,?,?)',
        bind => [ 1, 3, 5 ],
    },
);

test_boolean_term(
    desc    => 'two key-value pairs',
    input   => +{ args => +{ id => [ 1, 3, 5 ], verb => [ 'play', 'post' ] }, },
    expects => +{
        stmt => 'id IN (?, ?, ?) AND verb IN (?, ?)',
        bind => [ 1, 3, 5, 'play', 'post' ],
    },
);

test_boolean_term(
    desc  => 'two key-value pairs',
    input => +{
        new_args => +{ compact => 1, },
        args     => +{ id      => [ 1, 3, 5 ], verb => [ 'play', 'post' ] },
    },
    expects => +{
        stmt => 'id IN(?,?,?) AND verb IN(?,?)',
        bind => [ 1, 3, 5, 'play', 'post' ],
    },
);

done_testing;
