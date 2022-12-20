use NetAddr::IP::Lite;
use Test::More;

my @pairs =
    (
     [ '::/0', '0', '0' ],
     [ '::/128', '0', '340282366920938463463374607431768211455' ],
     [ 'cafe:cafe::/64',
       '269827015721314068804783158349174669312',
       '340282366920938463444927863358058659840' ],
     [ 'cafe:cafe::1/64',
       '269827015721314068804783158349174669313',
       '340282366920938463444927863358058659840' ],
     [ 'dead:beef::/100',
       '295990755014133383690938178081940045824',
       '340282366920938463463374607431499776000' ],
     [ 'dead:beef::1/100',
       '295990755014133383690938178081940045825',
       '340282366920938463463374607431499776000' ],
     );

my @scale =
qw(
 0000:0000:0000:0000:0000:0000:0000:0000
 0000:0000:0000:0000:0000:0000:0000:0001
 0000:0000:0000:0000:0000:0000:0000:0010
 0000:0000:0000:0000:0000:0000:0000:0100
 0000:0000:0000:0000:0000:0000:0000:1000
 0000:0000:0000:0000:0000:0000:0001:0000
 0000:0000:0000:0000:0000:0001:0000:0000
 0000:0000:0000:0000:0000:0010:0000:0000
 0000:0000:0000:0000:0000:0100:0000:0000
 0000:0000:0000:0000:0000:1000:0000:0000
 0000:0000:0000:0000:0001:0000:0000:0000
 0000:0000:0000:0001:0000:0000:0000:0000
 0000:0000:0000:0010:0000:0000:0000:0000
 0000:0000:0000:0100:0000:0000:0000:0000
 0000:0000:0000:1000:0000:0000:0000:0000
 0000:0000:0001:0000:0000:0000:0000:0000
 0000:0001:0000:0000:0000:0000:0000:0000
 0000:0010:0000:0000:0000:0000:0000:0000
 0000:0100:0000:0000:0000:0000:0000:0000
 0000:1000:0000:0000:0000:0000:0000:0000
 0001:0000:0000:0000:0000:0000:0000:0000
 0010:0000:0000:0000:0000:0000:0000:0000
 0100:0000:0000:0000:0000:0000:0000:0000
 1000:0000:0000:0000:0000:0000:0000:0000
   );

my $tests = 4 * @pairs + @scale ** 2;
plan tests => $tests;

for my $p (@pairs)
{
    my $a = new NetAddr::IP::Lite $p->[0];
    isa_ok($a, 'NetAddr::IP::Lite', "$p->[0]");
    is($a->numeric, $p->[1], "$p->[0] Scalar numeric ok");
    is(($a->numeric)[0], $p->[1], "$p->[0] Array numeric ok for network");
    is(($a->numeric)[1], $p->[2], "$p->[0] Array numeric ok for mask");
}

@ip_scale = map { new NetAddr::IP::Lite $_ } @scale;

isa_ok($_, 'NetAddr::IP::Lite', $_->addr) for @ip_scale;

for my $i (0 .. $#ip_scale)
{
    for my $l (0 .. $i - 1)
    {
	next if $l >= $i;
	unless (ok($ip_scale[$i]->numeric > $ip_scale[$l]->numeric,
		   "[$i, $l] $scale[$i] > $scale[$l]"))
	{
	    diag "assertion [$i]: " . $ip_scale[$i]->numeric .
		" > " . $ip_scale[$l]->numeric;
	}
    }

    next if $i == $#ip_scale;

    for my $l ($i + 1 .. $#ip_scale)
    {
	next if $l <= $i;
	unless (ok($ip_scale[$i]->numeric < $ip_scale[$l]->numeric,
		   "[$i, $l] $scale[$i] < $scale[$l]"))
	{
	    diag "assertion [$i]: " . $ip_scale[$i]->numeric .
		" < " . $ip_scale[$l]->numeric;
	}
    }
}
