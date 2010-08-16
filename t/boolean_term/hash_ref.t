use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::SQL::Builder::Util qw(test_boolean_term);

subtest 'comparison predicate' => sub {

    test_boolean_term(
        desc    => 'using -equals, single key-value pair',
        input   => +{ args => +{ id => +{ -equals => 10 }, }, },
        expects => +{
            stmt => 'id = ?',
            bind => [10],
        },
    );

    test_boolean_term(
        desc    => 'using =, single key-value pair',
        input   => +{ args => +{ id => +{ '=' => 10 }, }, },
        expects => +{
            stmt => 'id = ?',
            bind => [10],
        },
    );

    test_boolean_term(
        desc =>
          'using -greater_than_or_equals and -less_than, single key-value pair',
        input => +{
            args =>
              +{ id => +{ -greater_than_or_equals => 10, -less_than => 20, }, },
        },
        expects => +{
            stmt => 'id >= ? AND id < ?',
            bind => [ 10, 20 ],
        },
    );

    test_boolean_term(
        desc    => 'using >= and <, single key-value pair',
        input   => +{ args => +{ id => +{ '>=' => 10, '<' => 20, }, }, },
        expects => +{
            stmt => 'id < ? AND id >= ?',
            bind => [ 20, 10 ],
        },
    );

    test_boolean_term(
        desc =>
'using -greater_than_or_equals and -less_than, -not_equals, two key-value pairs',
        input => +{
            args => +{
                id     => +{ -greater_than_or_equals => 10, -less_than => 20, },
                status => +{ -not_equals             => 3 }
            },
        },
        expects => +{
            stmt => 'id >= ? AND id < ? AND status <> ?',
            bind => [ 10, 20, 3 ],
        },
    );

    test_boolean_term(
        desc  => 'using >= and <, <>, two key-value pairs',
        input => +{
            args =>
              +{ id => +{ '>=' => 10, '<' => 20, }, status => +{ '<>' => 3 } },
        },
        expects => +{
            stmt => 'id < ? AND id >= ? AND status <> ?',
            bind => [ 20, 10, 3 ],
        },
    );

    test_boolean_term(
        desc =>
          'using -equals with array reference value, single key-value pair',
        input   => +{ args => +{ id => +{ -equals => [ 10, 20, 30 ], }, }, },
        expects => +{
            stmt => 'id IN (?, ?, ?)',
            bind => [ 10, 20, 30 ],
        },
    );

    test_boolean_term(
        desc =>
'using -equals with array reference value, single key-value pair, compact option',
        input => +{
            new_args => +{ compact => 1, },
            args     => +{ id      => +{ -equals => [ 10, 20, 30 ], }, },
        },
        expects => +{
            stmt => 'id IN(?,?,?)',
            bind => [ 10, 20, 30 ],
        },
    );

    test_boolean_term(
        desc    => 'using = with array reference value, single key-value pair',
        input   => +{ args => +{ id => +{ '=' => [ 10, 20, 30 ], }, }, },
        expects => +{
            stmt => 'id IN (?, ?, ?)',
            bind => [ 10, 20, 30 ],
        },
    );

    test_boolean_term(
        desc =>
'using = with array reference value, single key-value pair, compact option',
        input => +{
            new_args => +{ compact => 1, },
            args     => +{ id      => +{ '=' => [ 10, 20, 30 ], }, },
        },
        expects => +{
            stmt => 'id IN(?,?,?)',
            bind => [ 10, 20, 30 ],
        },
    );

    test_boolean_term(
        desc =>
          'using -not_equals with array reference value, single key-value pair',
        input => +{ args => +{ id => +{ -not_equals => [ 10, 20, 30 ], }, }, },
        expects => +{
            stmt => 'id NOT IN (?, ?, ?)',
            bind => [ 10, 20, 30 ],
        },
    );

    test_boolean_term(
        desc =>
'using -not_equals with array reference value, single key-value pair, compact option',
        input => +{
            new_args => +{ compact => 1, },
            args     => +{ id      => +{ -not_equals => [ 10, 20, 30 ], }, },
        },
        expects => +{
            stmt => 'id NOT IN(?,?,?)',
            bind => [ 10, 20, 30 ],
        },
    );

    test_boolean_term(
        desc    => 'using <> with array reference value, single key-value pair',
        input   => +{ args => +{ id => +{ '<>' => [ 10, 20, 30 ], }, }, },
        expects => +{
            stmt => 'id NOT IN (?, ?, ?)',
            bind => [ 10, 20, 30 ],
        },
    );

    test_boolean_term(
        desc =>
'using <> with array reference value, single key-value pair, compact option',
        input => +{
            new_args => +{ compact => 1, },
            args     => +{ id      => +{ '<>' => [ 10, 20, 30 ], }, },
        },
        expects => +{
            stmt => 'id NOT IN(?,?,?)',
            bind => [ 10, 20, 30 ],
        },
    );

    test_boolean_term(
        desc =>
          'using -equals with scalar reference value, single key-value pair',
        input => +{ args => +{ dt => +{ -equals => \'FROM_UNIXTIME(ts)' }, }, },
        expects => +{
            stmt => 'dt = FROM_UNIXTIME(ts)',
            bind => [],
        },
    );

    test_boolean_term(
        desc    => 'using = with scalar reference value, single key-value pair',
        input   => +{ args => +{ dt => +{ '=' => \'FROM_UNIXTIME(ts)' }, }, },
        expects => +{
            stmt => 'dt = FROM_UNIXTIME(ts)',
            bind => [],
        },
    );
    done_testing;
};

subtest 'between predicate' => sub {
    test_boolean_term(
        desc    => 'using -between, single key-value pair',
        input   => +{ args => +{ id => +{ -between => [ 10, 20 ] }, }, },
        expects => +{
            stmt => 'id BETWEEN (?, ?)',
            bind => [ 10, 20 ],
        },
    );

    test_boolean_term(
        desc  => 'using -between, single key-value pair with compact',
        input => +{
            new_args => +{ compact => 1, },
            args     => +{ id      => +{ -between => [ 10, 20 ] }, },
        },
        expects => +{
            stmt => 'id BETWEEN(?,?)',
            bind => [ 10, 20 ],
        },
    );

    done_testing;
};

done_testing;

__END__

subtest '_boolean_term() hash_ref between predicate' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ 'BETWEEN' => [10, 20] } } );

        is( $stmt, 'id BETWEEN (?, ?)', 'hash_ref stmt between, direct op' );
        is_deeply( \@bind, [10, 20], 'hash_ref bind between, direct op' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -not_between => [10, 20] } } );

        is( $stmt, 'id NOT BETWEEN (?, ?)', 'hash_ref stmt between' );
        is_deeply( \@bind, [10, 20], 'hash_ref bind not between' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ 'NOT BETWEEN' => [10, 20] } } );

        is( $stmt, 'id NOT BETWEEN (?, ?)', 'hash_ref stmt between, direct op' );
        is_deeply( \@bind, [10, 20], 'hash_ref bind not between, direct op' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->compact(1);
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -between => [10, 20] } } );

        is( $stmt, 'id BETWEEN(?,?)', 'hash_ref stmt between, compact option' );
        is_deeply( \@bind, [10, 20], 'hash_ref bind between, compact option' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->compact(1);
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ 'BETWEEN' => [10, 20] } } );

        is( $stmt, 'id BETWEEN(?,?)', 'hash_ref stmt between, direct op, compact option' );
        is_deeply( \@bind, [10, 20], 'hash_ref bind between, direct op, compact option' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->compact(1);
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -not_between => [10, 20] } } );

        is( $stmt, 'id NOT BETWEEN(?,?)', 'hash_ref stmt between, compact option' );
        is_deeply( \@bind, [10, 20], 'hash_ref bind not between, compact option' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->compact(1);
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ 'NOT BETWEEN' => [10, 20] } } );

        is( $stmt, 'id NOT BETWEEN(?,?)', 'hash_ref stmt between, direct op, compact option' );
        is_deeply( \@bind, [10, 20], 'hash_ref bind not between, direct op, compact option' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ created_on => +{ -between => [\'MIN(updated_on)', \'MAX(updated_on)'] } } );

        is( $stmt, 'created_on BETWEEN (MIN(updated_on), MAX(updated_on))', 'hash_ref stmt between' );
        is_deeply( \@bind, [], 'hash_ref bind between, include scalar_ref' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ created_on => +{ 'BETWEEN' => [\'MIN(updated_on)', \'MAX(updated_on)'] } } );

        is( $stmt, 'created_on BETWEEN (MIN(updated_on), MAX(updated_on))', 'hash_ref stmt between, direct op' );
        is_deeply( \@bind, [], 'hash_ref bind between, include scalar_ref, direct op' );
    }


    done_testing;
};

subtest '_boolean_term() hash_ref in predicate' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -in => [10, 20, 30] } } );

        is( $stmt, 'id IN (?, ?, ?)', 'hash_ref stmt in' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind in' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ 'IN' => [10, 20, 30] } } );

        is( $stmt, 'id IN (?, ?, ?)', 'hash_ref stmt in, direct op' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind in, direct op' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -not_in => [10, 20, 30] } } );

        is( $stmt, 'id NOT IN (?, ?, ?)', 'hash_ref stmt in' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind not in' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ 'NOT IN' => [10, 20, 30] } } );

        is( $stmt, 'id NOT IN (?, ?, ?)', 'hash_ref stmt in, direct op' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind not in, direct op' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->compact(1);
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -in => [10, 20, 30] } } );

        is( $stmt, 'id IN(?,?,?)', 'hash_ref stmt in, compact option' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind in, compact option' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->compact(1);
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ 'IN' => [10, 20, 30] } } );

        is( $stmt, 'id IN(?,?,?)', 'hash_ref stmt in, direct op, compact option' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind in, direct op, compact option' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->compact(1);
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -not_in => [10, 20, 30] } } );

        is( $stmt, 'id NOT IN(?,?,?)', 'hash_ref stmt in, compact option' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind not in, compact option' );
    }

    {
        my $sql = SQL::Builder->new;
        $sql->compact(1);
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ 'NOT IN' => [10, 20, 30] } } );

        is( $stmt, 'id NOT IN(?,?,?)', 'hash_ref stmt in, direct op, compact option' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind not in, direct op, compact option' );
    }

    done_testing;
};

subtest '_boolean_term() hash_ref like predicate' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ name => +{ -like => '%bob%' } } );

        is( $stmt, 'name LIKE ?', 'hash_ref stmt like' );
        is_deeply( \@bind, ['%bob%'], 'hash_ref bind like' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ name => +{ LIKE => '%bob%' } } );

        is( $stmt, 'name LIKE ?', 'hash_ref stmt like, direct op' );
        is_deeply( \@bind, ['%bob%'], 'hash_ref bind like, direct op' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ name => +{ -not_like => '%bob%' } } );

        is( $stmt, 'name NOT LIKE ?', 'hash_ref stmt not like' );
        is_deeply( \@bind, ['%bob%'], 'hash_ref bind not like' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ name => +{ 'NOT LIKE' => '%bob%' } } );

        is( $stmt, 'name NOT LIKE ?', 'hash_ref stmt not like, direct op' );
        is_deeply( \@bind, ['%bob%'], 'hash_ref bind not like, direct op' );
    }

    done_testing;
};

subtest '_boolean_term() hash_ref is_null predicate' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ name => +{ -is_null => 1 } } );

        is( $stmt, 'name IS NULL', 'hash_ref stmt is_null' );
        is_deeply( \@bind, [], 'hash_ref bind is_null' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ name => +{ 'IS NULL' => 1 } } );

        is( $stmt, 'name IS NULL', 'hash_ref stmt is_null, direct op' );
        is_deeply( \@bind, [], 'hash_ref bind is_null, direct op' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ name => +{ -is_not_null => 1 } } );

        is( $stmt, 'name IS NOT NULL', 'hash_ref stmt not is_not_null' );
        is_deeply( \@bind, [], 'hash_ref bind is_not_null' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ name => +{ 'IS NOT NULL' => 1 } } );

        is( $stmt, 'name IS NOT NULL', 'hash_ref stmt is_not_null, direct op' );
        is_deeply( \@bind, [], 'hash_ref bind not is_not_null, direct op' );
    }

    done_testing;
};

subtest '_boolean_term() hash_ref qualified predicate' => sub {
    ok(1);
    done_testing;
};

done_testing;
