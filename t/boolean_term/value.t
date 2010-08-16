use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::SQL::Builder::Util qw(test_boolean_term);

test_boolean_term(
    desc    => 'single key-value pair',
    input   => +{ args => +{ id => 10, }, },
    expects => +{
        stmt => 'id = ?',
        bind => [ 10, ],
    },
);

test_boolean_term(
    desc    => 'two key-value pairs',
    input   => +{ args => +{ id => 10, name => 'bob' }, },
    expects => +{
        stmt => 'id = ? AND name = ?',
        bind => [ 10, 'bob' ],
    },
);

test_boolean_term(
    desc    => 'tree key-value pairs',
    input   => +{ args => +{ id => 10, name => 'bob', status => 1, }, },
    expects => +{
        stmt => 'id = ? AND name = ? AND status = ?',
        bind => [ 10, 'bob', 1 ],
    },
);

done_testing;
