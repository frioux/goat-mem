#!/usr/bin/perl

use strict;
use warnings;

use 5.10.0;

# libtemplate-perl
use Template;
# libjson-xs-perl
use JSON::XS;
use FindBin;

open my $fh, '<', "$FindBin::Bin/../verses.json";

my $data = decode_json(join '', <$fh>);

my $tt = Template->new({ INCLUDE_PATH => "$FindBin::Bin/../tt" });

my @weekdays = qw(
   Sunday
   Monday
   Tuesday
   Wednesday
   Thursday
   Friday
   Saturday
);

my @results;

for my $day (@{$data->{days}}) {
   state $i = 0;
   my $week_idx = $i % @weekdays;
   push @results, [] if $week_idx == 0;

   my $weekday = $weekdays[$i % @weekdays];

   push @{$results[-1]}, {
      day => $weekday,
      verse => $day,
   };

   $i++;
}

my @page;

for my $week (@results) {
   state $i = 0;

   push @page, [] if $i % 4 == 0;

   push @{$page[-1]}, $week;

   $i++;
}

# process input template, substituting variables
$tt->process('template.tt', {
   pages => \@page
}) || die $tt->error();
