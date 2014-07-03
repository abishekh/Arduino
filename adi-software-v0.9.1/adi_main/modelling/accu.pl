my @history;
my $hist_index;

while (1)
{
	my $value = rand(100);
	$hist_index++;
	$hist_index %= 16;
	$history[$hist_index] = $value;

	my $accu = 0;
	for(my $i=0; $i<16; $i++)
	{
		my $j = ($i + $hist_index) % 16;
		print "$j: $history[$j]\n";
		$accu += $history[$j];
	}
	my $avg = $accu / 16;

	print "avg: $avg\n";
}
