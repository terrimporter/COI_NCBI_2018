#!/usr/bin/perl
#June 25, 2018 by Teresita M. Porter
#Script parses through text formatted CO1 genbank records contained in one or several directories
#The directories are listed in the dirlist.txt, one folder per file, ex. genbank_records_year/
#The output is a tab delimited text file with the following fields: species, GenBank accession, Organism name, country, latlon, as well as the binary fields (1=yes, 0=no) for 500bp+, country metadata present, latlon present
#USAGE perl quick_filter_gb_country_latlon_CO1_organism.plx dirlist.txt

use strict;
use warnings;
use Bio::DB::EUtilities;
use Bio::SeqIO;

#declare var
my $taxid;
my $j=0;
my $dir;
my $year;
my $i=0;
my $file;
my $filepath;
my $outfilename;
my $seqin;
my $seq;
my $gb;
my $feat_object;
my $organism="nil";
my $country="nil";
my $latlon="nil";
my $sequence_fragment;
my $COI_seq;
my $gi;
my $length;
my $minlength=500;
my $value_gene;
my $value;
my $name;

#declare array
my @dirlist;
my @dirarray;
my @taxid;
my @files;
my @COI_seq;
my @value_country;
my @feat_object;
my @country;
my @value_gene;

#declare hash
my %taxid;

open (DIRLIST,"<",$ARGV[0]) || die "Error reading dirlist.txt: $!\n";
@dirlist = <DIRLIST>;
close DIRLIST;

foreach $dir (@dirlist) {
	chomp $dir;

	@dirarray = split('_',$dir);
	$year = $dirarray[2];
	$year =~ s/\///g;

	opendir (DIR, $dir) || die "Error opening dir $dir\n";
	@files = readdir DIR;
	closedir DIR;

	while ($files[$i]) {
		$file = $files[$i];

		if ($file =~ /^\./) {
			$i++;
			next;
		}
		else {

			$filepath = $dir.$file;

			$seqin = Bio::SeqIO -> new(	-file	=> $filepath,
									-format	=> 'genbank');

			$outfilename = 'organism_'.$year.'.txt';

			open (OUT,">>",$outfilename) || die "Error cannot write to $outfilename: $!\n";

			while ($seq = $seqin -> next_seq) {
				$gb = $seq -> id;
				@feat_object = $seq -> get_SeqFeatures;
				foreach $feat_object (@feat_object) {
					if ($feat_object -> primary_tag eq "source") {
						if ($feat_object -> has_tag('organism')) {
							for $value ($feat_object -> get_tag_values('organism')) {
								$organism = $value;
							}
						}
						else {
							$organism = "nil";
						}
						if ($feat_object -> has_tag('country')) {
							for $value ($feat_object -> get_tag_values('country')){
								$country = $value;
							}
						}
						else {
							$country="nil";
						}
						if ($feat_object -> has_tag('lat_lon')) {
							for $value ($feat_object -> get_tag_values('lat_lon')){
								$latlon = $value;
							}
						}
						else {
							$latlon="nil";
						}
					}
					if ($feat_object -> primary_tag eq "CDS") {
						$sequence_fragment = $feat_object -> spliced_seq -> seq; #grab COI nt seq
						if ($feat_object -> has_tag('gene')) {
							@value_gene = $feat_object -> get_tag_values('gene');
							foreach $value_gene (@value_gene) {
								if ($value_gene =~ /^(cox1|coxI|CO1|COI)$/i) { #double check product
									$COI_seq = $sequence_fragment;
									@COI_seq = split(//,$COI_seq);
									$length = scalar(@COI_seq);
									if ($length >= $minlength) { #only count if 500bp+
										if ($country eq "nil") {
											if ($latlon eq "nil") {
												print OUT "species\t$gb\t$year\t$organism\t$country\t$latlon\t1\t0\t0\n";
											}
											else {
												print OUT "species\t$gb\t$year\t$organism\t$country\t$latlon\t1\t0\t1\n";
											}
										}
										else {
											if ($latlon eq "nil") {
												print OUT "species\t$gb\t$year\t$organism\t$country\t$latlon\t1\t1\t0\n";
											}
											else {
												print OUT "species\t$gb\t$year\t$organism\t$country\t$latlon\t1\t1\t1\n";
											}
										}
									}
									else {
										if ($country eq "nil") {
											if ($latlon eq "nil") {
												print OUT "species\t$gb\t$year\t$organism\t$country\t$latlon\t0\t0\t0\n";
											}
											else {
												print OUT "species\t$gb\t$year\t$organism\t$country\t$latlon\t0\t0\t1\n";
											}
										}
										else {
											if ($latlon eq "nil") {
												print OUT "species\t$gb\t$year\t$organism\t$country\t$latlon\t0\t1\t0\n";
											}
											else {
												print OUT "species\t$gb\t$year\t$organism\t$country\t$latlon\t0\t1\t1\n";
											}
										}
									}
								}
							}
						}
					}
				}
				$gb=();
				$organism="nil";
				$country="nil";
				$latlon="nil";
				$feat_object=();
				$value_gene=();
				$sequence_fragment=();
				$COI_seq=();
				$seq=();
				@feat_object=();
				@value_gene=();
			}
			$seqin=();
			close OUT;
		}
		$i++;
		$file=();
	}
	$i=0;
	@files=();
}
