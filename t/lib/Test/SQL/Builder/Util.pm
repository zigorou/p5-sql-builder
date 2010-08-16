package Test::SQL::Builder::Util;

use strict;
use warnings;
use Exporter qw(import);
use Data::Util qw(neat);
use Test::More;
use SQL::Builder;

our $VERSION   = '0.01';
our @EXPORT_OK = qw(test_boolean_term);

sub test_boolean_term {
    my %specs = @_;
    my ( $input, $expects, $desc ) = @specs{qw/input expects desc/};

    $input->{new_args} ||= +{};

    subtest $desc => sub {
        my $sql = SQL::Builder->new( %{ $input->{new_args} } );
        my ( $stmt, @bind ) = $sql->_boolean_term( $input->{args} );
        is( $stmt, $expects->{stmt},
            'expected statement: ' . $expects->{stmt} );
        is_deeply( \@bind, $expects->{bind},
            'expected bind: ' . neat( $expects->{bind} ) );
        done_testing;
    };
}

1;

__END__

=head1 NAME

Test::SQL::Builder::Util - 

=head1 SYNOPSIS

  use Test::SQL::Builder::Util;

=head1 DESCRIPTION

Test::SQL::Builder::Util is 

=head1 METHODS

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# Local Variables:
# mode: perl
# perl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8-unix
# End:
#
# vim: expandtab shiftwidth=4:
