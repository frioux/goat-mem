#!/usr/bin/perl

use strict;
use warnings;

use 5.10.0;

# libtemplate-perl
use Template;
# libjson-xs-perl
use JSON::XS;
use FindBin;
# liblist-moreutils-perl
use List::MoreUtils 'natatime';

open my $fh, '<', "$FindBin::Bin/../verses.json";

my $data = decode_json(join '', <$fh>);

my $tt = Template->new({ INCLUDE_PATH => "$FindBin::Bin/../tt" });

my @weekdays = qw(
   Monday\vspace{1.75cm}
   Tuesday\vspace{1.75cm}
   Wednesday\vspace{1.75cm}
   Thursday\vspace{1.75cm}
   Friday\vspace{1.75cm}
   Saturday\vspace{1.75cm}
   Sunday\vspace{0.2cm}
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

my @new_results;
my $iter = natatime 8, @results;

while (my ($a, $b, $c, $d, $e, $f, $g, $h) = $iter->()) {
   push @new_results,
      $a, $c,
      $e, $g,

      $b, $d,
      $f, $h
}

@results = @new_results;

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
