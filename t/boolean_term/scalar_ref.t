use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::SQL::Builder::Util qw(test_boolean_term);

test_boolean_term(
    desc    => 'single key-value pair',
    input   => +{ args => +{ id => \'community_member.guid' }, },
    expects => +{
        stmt => 'id = community_member.guid',
        bind => [],
    },
);

test_boolean_term(
    desc => 'two key-value pairs',
    input =>
      +{ args => +{ id => \'community_member.guid', created_on => \'NOW()' }, },
    expects => +{
        stmt => 'created_on = NOW() AND id = community_member.guid',
        bind => [],
    },
);

done_testing;
