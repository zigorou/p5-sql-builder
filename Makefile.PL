use inc::Module::Install;
name 'SQL-Builder';
all_from 'lib/SQL/Builder.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
