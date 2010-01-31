use strict;
use warnings;

use Test::More;
use Tie::Hash::Sorted;

use SQL::Builder;

subtest '_boolean_term() hash_ref comparison predicate' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -equals => 10 } } );

        is( $stmt, 'id = ?', 'hash_ref stmt simple' );
        is_deeply( \@bind, [10], 'hash_ref bind simple' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_boolean_term( +{ id => +{ '=' => 10 } } );

        is( $stmt, 'id = ?', 'hash_ref stmt simple, direct op' );
        is_deeply( \@bind, [10], 'hash_ref bind simple, direct op' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_boolean_term(
            +{ id => +{ -greater_than_or_equals => 10, -less_than => 20 } } );

        is(
            $stmt,
            'id >= ? AND id < ?',
            'hash_ref stmt multi boolean factor in same predicate'
        );
        is_deeply(
            \@bind,
            [ 10, 20 ],
            'hash_ref bind multi boolean factor in same predicate'
        );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ '>=' => 10, '<' => 20 } } );

        is(
            $stmt,
            'id < ? AND id >= ?',
            'hash_ref stmt multi boolean factor in same predicate, direct op'
        );
        is_deeply(
            \@bind,
            [ 20, 10 ],
            'hash_ref bind multi boolean factor in same predicate, direct op'
        );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_boolean_term(
            +{
                id     => +{ -greater_than => 10, -less_than_or_equals => 20 },
                status => +{ -not_equals   => 3 }
            }
        );

        is(
            $stmt,
            'id > ? AND id <= ? AND status <> ?',
'hash_ref stmt multi boolean factor in same predicate, multi predicate'
        );
        is_deeply(
            \@bind,
            [ 10, 20, 3 ],
'hash_ref bind multi boolean factor in same predicate, multi predicate'
        );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_boolean_term(
            +{ id => +{ '>' => 10, '<=' => 20 }, status => +{ '<>' => 3 } } );

        is(
            $stmt,
            'id <= ? AND id > ? AND status <> ?',
'hash_ref stmt multi boolean factor in same predicate, multi predicate, direct op'
        );
        is_deeply(
            \@bind,
            [ 20, 10, 3 ],
'hash_ref bind multi boolean factor in same predicate, multi predicate, direct op'
        );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -equals => [10, 20, 30] } } );

        is( $stmt, 'id IN (?, ?, ?)', 'hash_ref stmt multi equals as IN' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind multi equals as IN' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ '=' => [10, 20, 30] } } );

        is( $stmt, 'id IN (?, ?, ?)', 'hash_ref stmt multi equals as IN, direct op' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind multi equals as IN, direct op' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -not_equals => [10, 20, 30] } } );

        is( $stmt, 'id NOT IN (?, ?, ?)', 'hash_ref stmt multi not equals as NOT IN' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind multi not equals as NOT IN' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ '<>' => [10, 20, 30] } } );

        is( $stmt, 'id NOT IN (?, ?, ?)', 'hash_ref stmt multi not equals as NOT IN, direct op' );
        is_deeply( \@bind, [10, 20, 30], 'hash_ref bind multi not equals as NOT IN, direct op' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -equals => \'MAX(id)' } } );

        is( $stmt, 'id = MAX(id)', 'hash_ref stmt scalar ref' );
        is_deeply( \@bind, [], 'hash_ref bind scalar ref' );
    }

    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) = $sql->_boolean_term( +{ id => +{ '=' => \'MAX(id)' } } );

        is( $stmt, 'id = MAX(id)', 'hash_ref stmt scalar ref, direct op' );
        is_deeply( \@bind, [], 'hash_ref bind scalar ref, direct op' );
    }

    done_testing;
};

subtest '_boolean_term() hash_ref between predicate' => sub {
    {
        my $sql = SQL::Builder->new;
        my ( $stmt, @bind ) =
          $sql->_boolean_term( +{ id => +{ -between => [10, 20] } } );

        is( $stmt, 'id BETWEEN (?, ?)', 'hash_ref stmt between' );
        is_deeply( \@bind, [10, 20], 'hash_ref bind between' );
    }

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
