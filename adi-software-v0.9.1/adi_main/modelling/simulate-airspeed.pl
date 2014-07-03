#!/usr/bin/perl -w
# vi:set shiftwidth=4 tabstop=4 ai sm wm=0

# converting PSI to airspeed in knots, from
# http://diydrones.com/forum/topics/705844:Topic:23389?commentId=705844%3AComment%3A23399

use strict;

my $max_volts = $ARGV[0] || 5;

my $speed_unit = "mph";
my $pressure_unit = "kPa";
#my $max_volts = 2.5;

my %sealevel_sound = ( 
			knots => 661.4788, 
			mph => 767.7165,
		     );
my %sealevel_pressure = (
			psi => 14.6959,
			kPa => 101.325,
			);

my %speeds;
for(my $i=(1024/$max_volts); $i<=1024; $i++)
{
	print_speed($i);
}

for(my $i=0; $i<=110; $i++)
{
	print "$i: 0\n" if !($speeds{$i});
}

sub print_speed()
{
	my $sensor = shift;

	my $kPa = (($sensor / 1024) * $max_volts) - 1;
	my $speed = $sealevel_sound{$speed_unit} * 
		sqrt ( 5 * ( ( 
			( ( ( $kPa/$sealevel_pressure{$pressure_unit} ) +1) ** 
			(2/7) ) - 1) ) );

	$speed = sprintf("%d", $speed);
	$speeds{$speed}++;
	print "$sensor ADC value == $kPa $pressure_unit == speed of $speed $speed_unit\n";
}
