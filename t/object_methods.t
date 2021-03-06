use strict;
use warnings;

use Test::Exception;
use Test::More tests => 50;
use Test::NoWarnings;
use Date::Utility;

my $baseline = 1278382486;
my $base_date = Date::Utility->new({epoch => $baseline});
my $later_date =
    Date::Utility->new({epoch => $baseline + (86400 * 2) + (3600 * 3) + (60 * 8) + 14});    # Two days, 3 hours, 8 minutes and 14 seconds later.
my $earlier_date =
    Date::Utility->new({epoch => $baseline - (86400 * 6) + (3600 * 1) + (60 * 12) + 22});   # 6 days, 1 hour,  12 minutes and 22 seconds earlier.

is($base_date->days_between($base_date),     0,  'base to base days_between');
is($base_date->days_between($earlier_date),  6,  'base to earlier days_between');
is($base_date->days_between($later_date),    -2, 'base to later days_between');
is($earlier_date->days_between($base_date),  -6, 'earlier to base days_between');
is($earlier_date->days_between($later_date), -8, 'earlier to later days_between');
is($later_date->days_between($base_date),    2,  'later to base days_between');
is($later_date->days_between($earlier_date), 8,  'later to later days_between');

# months_ahead can take both positive and negative numbers...
# And returns a crazy string.  This should likely be
# reconsidered later.. with a Factory!
my $jul08 = Date::Utility->new('1-Jul-08');
my $jan08 = Date::Utility->new('15-Jan-08');
my $dec00 = Date::Utility->new('25-Dec-00');
my $jan00 = Date::Utility->new('6-Jan-00');
my $oct99 = Date::Utility->new('31-Oct-99');

is($jul08->months_ahead(0),   'Jul-08', 'Jul-08: Same month check');
is($jul08->months_ahead(-1),  'Jun-08', 'Jul-08: Recent month check');
is($jan08->months_ahead(-1),  'Dec-07', 'Jan-08: Wrap to previous year check');
is($dec00->months_ahead(-1),  'Nov-00', 'Dec-00: Check that Dec works as it iss the last month in the year');
is($jan00->months_ahead(-1),  'Dec-99', 'Jan-00: Wrap to previous century');
is($oct99->months_ahead(-1),  'Sep-99', 'Oct-99: Ordinary date in previous century');
is($jul08->months_ahead(-2),  'May-08', 'Jul-08: 2 months back');
is($jul08->months_ahead(-12), 'Jul-07', 'Jul-08: 12 months back');
is($jan08->months_ahead(-13), 'Dec-06', 'Jan-08: 13 months back, which means spanning 2 years');
is($dec00->months_ahead(-12), 'Dec-99', 'Dec-00: 12 months back, which means spanning 1 century');
is($oct99->months_ahead(-24), 'Oct-97', 'Oct-99: 2 years back');
is($oct99->months_ahead(1),   'Nov-99', 'Oct-99: Ordinary date in previous century');
is($jul08->months_ahead(2),   'Sep-08', 'Jul-08: 2 months forward');
is($jul08->months_ahead(12),  'Jul-09', 'Jul-08: 12 months forward');
is($jan08->months_ahead(13),  'Feb-09', 'Jan-08: 13 months forward');
is($dec00->months_ahead(12),  'Dec-01', 'Dec-00: 12 months forward');
is($oct99->months_ahead(24),  'Oct-01', 'Oct-99: 2 years forward');

# before
is($jul08->is_before($jul08), undef, '1-Jul-08 is not before 1-Jul-08');
is($jul08->is_before($jan08), undef, '1-Jul-08 is not before 15-Jan-08');
is($jan00->is_before($dec00), 1,     '15-Jan-00 is before 25-Dec-00');
is($jan00->is_before($oct99), undef, '15-Jan-00 is not before 31-Oct-99');
is($oct99->is_before($jan08), 1,     '31-Oct-99 is before 15-Jan-08');

# after
is($jul08->is_after($jul08), undef, '1-Jul-08 is not after 1-Jul-08');
is($jul08->is_after($jan08), 1,     '1-Jul-08 is after 15-Jan-08');
is($jan00->is_after($dec00), undef, '15-Jan-00 is not after 25-Dec-00');
is($jan00->is_after($oct99), 1,     '15-Jan-00 is after 31-Oct-99');
is($oct99->is_after($jan08), undef, '31-Oct-99 is not after 15-Jan-08');

# same_as
is($jul08->is_same_as($jul08), 1,     '1-Jul-08 is same_as 1-Jul-08');
is($jul08->is_same_as($jan08), undef, '1-Jul-08 is not same_as 15-Jan-08');
is($jan00->is_same_as($dec00), undef, '15-Jan-00 is not same_as 25-Dec-00');
is($jan00->is_same_as($oct99), undef, '15-Jan-00 is not same_as 31-Oct-99');
is($oct99->is_same_as($jan08), undef, '31-Oct-99 is not same_as 15-Jan-08');

#truncate_to_day
my $datetime1 = Date::Utility->new('2011-12-13 07:03:01');
my $datetime2 = Date::Utility->new('2011-12-13 19:30:10');
my $datetime3 = Date::Utility->new('2011-12-14 19:30:10');
is($datetime1->truncate_to_day->datetime_iso8601, "2011-12-13T00:00:00Z", "Truncates time correctly");
is($datetime1->truncate_to_day->is_same_as($datetime2->truncate_to_day), 1, "is_same_as for truncated objects on the same day");
is($datetime2->truncate_to_day->is_same_as($datetime3->truncate_to_day), undef, "is_same_as for truncated objects on the different days");

# plus_time_interval, minus_time_interval
is($datetime2->plus_time_interval('1d')->is_same_as($datetime3),   1,          'plus_time_interval("1d") yields one day ahead.');
is($datetime1->plus_time_interval(0),                              $datetime1, 'plus_time_interval(0) yields the same object');
is($datetime3->plus_time_interval('-1d')->is_same_as($datetime2),  1,          'plus_time_interval("-1d") yields one day back.');
is($datetime3->minus_time_interval('1d')->is_same_as($datetime2),  1,          'minus_time_interval("1d") yields one day back.');
is($datetime1->minus_time_interval(0),                             $datetime1, 'minus_time_interval(0) yields the same object');
is($datetime2->minus_time_interval('-1d')->is_same_as($datetime3), 1,          'minus_time_interval("-1d") yields one day ahead.');
throws_ok { $datetime3->minus_time_interval("one") } qr/Bad format/, 'minus_time_interval("one") is not a mind-reader..';
