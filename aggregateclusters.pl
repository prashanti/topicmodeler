#!/usr/bin/perl

my $inputfile=$ARGV[0];
my $clusterfile=$ARGV[1];


open(IN,"<$inputfile") or die "Cannot create file";
open(CL,"<$clusterfile") or die "Cannot create file";



while (my $line =<CL>)
{
	#11	1	0.279633	inputFiles/WOSCorpus(11)
	my @data = split(/\t/,$line);
	my $lineno=$data[3];
	@tmp =split(/WOSCorpus/,$lineno);
	$lineno= $tmp[1];
	#print"$lineno\n";
	$lineno=~ s/\Q)//;
	#print"$lineno\n";
	$lineno=~ s/\Q(//;
	$clusterno=$data[1];
	$conf=$data[2];	
	$clusterno=trim($clusterno);
	$conf=trim($conf);
	$lineno=trim($lineno);
	#print "lineno $lineno\t\tCluster No $clusterno\n";
	$cluster{$lineno} = $clusterno;
	$confidence{$lineno}=$conf;

}

sub trim
	{
	my $line=shift;
	$line=~ s/^\s+//; 
    $line=~ s/\s+$//;
    return($line);
	}
open(OUT,">ClusteredDocuments_NoAbstract.xls") or die "Cannot create file";
print OUT"Row ID\tTitle\tKeywords1\tKeywords2\tAbstract\tCluster ID\tConfidence\n";
my $count=1;
while (my $line =<IN>)
{
	#TITLE:	SOURCE:	KEYWORDS:	KEYWORDS2:	ABSTRACT:	DATE:
	my @data=split(/\r/,$line);
	foreach $line(@data)
	{
	$line=~ s/^\s+//; 
    $line=~ s/\s+$//;
    my @tmp = split(/\t/,$line);

	print OUT"$count\t$tmp[0]\t$tmp[2]\t$tmp[3]\t$tmp[4]\t$cluster{$count}\t$confidence{$count}\n";
	#print "this $cluster{$count}\t$confidence{$count}";
	$count++;
	}
	
}

print "COUNT $count\n";