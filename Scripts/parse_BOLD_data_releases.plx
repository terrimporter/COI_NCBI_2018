#!/usr/bin/perl

#June 26, 2018 by Teresita M. Porter

#April 30, 2018 parse all the BOLD data releases (tsv) into a FASTA file that contains all Eukaryote records
#Automatically detect the different field names used to contain the same information
### Hardcoded list of files to read in (releases.txt), update these as needed
### Hardcoded, zero-indexed fields (column headers), update as needed
#USAGE perl parse_BOLD_data_releases.plx

use strict;
use warnings;

#declare variables
my $outfile="cat_BOLD_datareleases.fasta";
my $line;
my $i=0;
my $file;
my $fieldlist;
my $j=0;
my $header;
my $seq;
my $sampleID;
my $phylum;
my $counter=0;
my $key;
my $value;
my $field;

#declare array
my @keys;
my @fieldlist;
my @in;
my @data;
my @value;
my @header;

#declare hash
my %headers; #key=data release file name, value=numeric fields to keep and the order to keep them
my %seqs; #key=data release file name, value=numeric fields to keep and the order to keepthem
my %hash_header; #key=sampleID, value=header
my %hash_seq; #key=sampleID, value=seq
my %hash_phyla; #key=phylum

# identify which fields to keep for each data release version, zero-indexed fields
# field order: sampleid[1,2], date[32,37], accession[,35], phylum[8], class[9,10], order[10,12], family[11,14], genus[13,18], species[14,20], bin[,4]
$headers{"CanadianBarcodeNet_ver1.txt"} = "2,37,,8,10,12,14,18,20,"; #inconsistent formatting noted in filename and file headers
$headers{"iBOL_phase_0.50_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_0.75_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_1.00_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_1.25_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_1.50_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_1.75_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_2.0_COI.tsv"}=       "1,32,33,8,9,10,11,13,14,4"; #inconsistent formatting noted in filename and file headers
$headers{"iBOL_phase_2.25_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_2.50_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_2.75_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase3.0_COI.tsv"}=        "1,32,34,8,9,10,11,13,14,4"; #inconsistent formatting noted in filename and file headers
$headers{"iBOL_phase_3.25_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_3.50_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_3.75_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_4.00_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_4.25_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_4.50_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4"; #problem with fields here to look at
$headers{"iBOL_phase_4.75_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_5.00_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_5.25_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_5.50_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_5.75_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_6.00_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_6.25_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";
$headers{"iBOL_phase_6.50_COI.tsv"}=      "1,32,35,8,9,10,11,13,14,4";

# identifiy which field contains the nucleotide sequence
$seqs{"CanadianBarcodeNet_ver1.txt"} = "36"; #inconsistent formatting noted in filename and file headers
$seqs{"iBOL_phase_0.50_COI.tsv"}=      "30";
$seqs{"iBOL_phase_0.75_COI.tsv"}=      "30";
$seqs{"iBOL_phase_1.00_COI.tsv"}=      "30";
$seqs{"iBOL_phase_1.25_COI.tsv"}=      "30";
$seqs{"iBOL_phase_1.50_COI.tsv"}=      "30";
$seqs{"iBOL_phase_1.75_COI.tsv"}=      "30";
$seqs{"iBOL_phase_2.0_COI.tsv"}=       "30"; #inconsistent formatting noted in filename
$seqs{"iBOL_phase_2.25_COI.tsv"}=      "30";
$seqs{"iBOL_phase_2.50_COI.tsv"}=      "30";
$seqs{"iBOL_phase_2.75_COI.tsv"}=      "30";
$seqs{"iBOL_phase3.0_COI.tsv"}=        "30"; #inconsistent formatting noted in filename
$seqs{"iBOL_phase_3.25_COI.tsv"}=      "30";
$seqs{"iBOL_phase_3.50_COI.tsv"}=      "30";
$seqs{"iBOL_phase_3.75_COI.tsv"}=      "30";
$seqs{"iBOL_phase_4.00_COI.tsv"}=      "30";
$seqs{"iBOL_phase_4.25_COI.tsv"}=      "30";
$seqs{"iBOL_phase_4.50_COI.tsv"}=      "30";
$seqs{"iBOL_phase_4.75_COI.tsv"}=      "30";
$seqs{"iBOL_phase_5.00_COI.tsv"}=      "30";
$seqs{"iBOL_phase_5.25_COI.tsv"}=      "30";
$seqs{"iBOL_phase_5.50_COI.tsv"}=      "30";
$seqs{"iBOL_phase_5.75_COI.tsv"}=      "30";
$seqs{"iBOL_phase_6.00_COI.tsv"}=      "30";
$seqs{"iBOL_phase_6.25_COI.tsv"}=      "30";
$seqs{"iBOL_phase_6.50_COI.tsv"}=      "30";

#specify order to read in files, from oldest to newest
@keys = ("CanadianBarcodeNet_ver1.txt",
		"iBOL_phase_0.50_COI.tsv",
		"iBOL_phase_0.75_COI.tsv",
		"iBOL_phase_1.00_COI.tsv",
		"iBOL_phase_1.25_COI.tsv",
		"iBOL_phase_1.50_COI.tsv",
		"iBOL_phase_1.75_COI.tsv",
		"iBOL_phase_2.0_COI.tsv",
		"iBOL_phase_2.25_COI.tsv",
		"iBOL_phase_2.50_COI.tsv",
		"iBOL_phase_2.75_COI.tsv",
		"iBOL_phase3.0_COI.tsv",
		"iBOL_phase_3.25_COI.tsv",
		"iBOL_phase_3.50_COI.tsv",
		"iBOL_phase_3.75_COI.tsv",
		"iBOL_phase_4.00_COI.tsv",
		"iBOL_phase_4.25_COI.tsv",
		"iBOL_phase_4.50_COI.tsv",
		"iBOL_phase_5.00_COI.tsv",
		"iBOL_phase_5.25_COI.tsv",
		"iBOL_phase_5.50_COI.tsv",
		"iBOL_phase_5.75_COI.tsv",
		"iBOL_phase_6.00_COI.tsv",
		"iBOL_phase_6.25_COI.tsv",
		"iBOL_phase_6.50_COI.tsv");

#Add list of Eukaryote phyla from BOLD Taxonomy page
$hash_phyla{"Acanthocephala"}="1";
$hash_phyla{"Annelida"}="1";
$hash_phyla{"Arthropoda"}="1";
$hash_phyla{"Brachiopoda"}="1";
$hash_phyla{"Bryozoa"}="1";
$hash_phyla{"Chaetognatha"}="1";
$hash_phyla{"Chordata"}="1";
$hash_phyla{"Cnidaria"}="1";
$hash_phyla{"Cycliophora"}="1";
$hash_phyla{"Echinodermata"}="1";
$hash_phyla{"Gnathostomulida"}="1";
$hash_phyla{"Hemichordata"}="1";
$hash_phyla{"Mollusca"}="1";
$hash_phyla{"Nematoda"}="1";
$hash_phyla{"Nemertea"}="1";
$hash_phyla{"Onychophora"}="1";
$hash_phyla{"Platyhelminthes"}="1";
$hash_phyla{"Porifera"}="1";
$hash_phyla{"Priapulida"}="1";
$hash_phyla{"Rotifera"}="1";
$hash_phyla{"Sipuncula"}="1";
$hash_phyla{"Tardigrada"}="1";
$hash_phyla{"Xenoturbellida"}="1";
$hash_phyla{"Bryophyta"}="1";
$hash_phyla{"Chlorophyta"}="1";
$hash_phyla{"Lycopodiophyta"}="1";
$hash_phyla{"Magnoliophyta"}="1";
$hash_phyla{"Pinophyta"}="1";
$hash_phyla{"Pteridophyta"}="1";
$hash_phyla{"Rhodophyta"}="1";
$hash_phyla{"Ascomycota"}="1";
$hash_phyla{"Basidiomycota"}="1";
$hash_phyla{"Chytridiomycota"}="1";
$hash_phyla{"Glomeromycota"}="1";
$hash_phyla{"Myxomycota"}="1";
$hash_phyla{"Zygomycota"}="1";
$hash_phyla{"Chlorarachniophyta"}="1";
$hash_phyla{"Ciliophora"}="1";
$hash_phyla{"Heterokontophyta"}="1";
$hash_phyla{"Pyrrophycophyta"}="1";

#create an outfile
open (OUT, ">>", $outfile) || die "Cannot open outfile: $!\n";

#open each file in order
while($keys[$i]) {
	$file = $keys[$i];
	chomp $file;

	#identify the correct order of fields to grab from the data release files
	if (exists $headers{$file}) {
		$fieldlist = $headers{$file};
		@fieldlist = split(',',$fieldlist);
		
		#open file
		open (IN, "<", $file) || die "Cannot open infile $file: $!\n";
		@in = <IN>;

		#parse through file line by line
		while ($in[$j]) {
			$line = $in[$j];
			chomp $line;

			#skip over header row
			if ($j == 0) {
				$j++;
				next;
			}
			else {
				#grab each field in data release file, automatically zero-indexed
				@data = split(/\t/,$line);

				#grab sampleID and phylum upfront to check for their presence in hashes
				$field = $fieldlist[0];
				$sampleID = $data[$field];
				$field = $fieldlist[3];
				$phylum = $data[$field];
				
				#if a value for phylum is found then proceed with processing
				if (length($phylum) > 0) {

					#subroutine to prase through each field and create a correctly formatted fasta header
					$header = parse_fields(\@fieldlist, \@data);

					#if we have a Eukaryote phylum, continue processing
					if (exists $hash_phyla{$phylum}) {
						$hash_header{$sampleID} = $header;

						#verify which field contains the nucleotide sequence
						if (exists $seqs{$file}) {
							$field = $seqs{$file};
							$seq = $data[$field];
							$hash_seq{$sampleID} = $seq;
						}
					}
				}
				else {
					$j++;
					next;
				}					
			}
			$j++;
			$line=();
			@data=();
			$field=();
			$sampleID=();
			$phylum=();
			$header=();
			$seq=();
		}
		$j=0;
	}
	else {
		print "Cannot find file $file in headers hash\n";
	}
	$i++;
	$file=();
	$fieldlist=();
	@fieldlist=();
	@in=();
}
$i=0;

#print final non-redundant hash, all sampleIDs are unique
while (($key,$value) = each(%hash_header)) {
	$header = $value;
	$counter++;

	if (exists $hash_seq{$key}) {
		$seq = $hash_seq{$key};
		print OUT ">$header\n$seq\n";
	}
	else {
		print "Couldn't find seq for header $header\n";
	}
}
print "Counter=$counter\n";
close OUT;

##############################################################################

sub parse_fields {

#read in array refs
my $fieldlist = shift;
my $data = shift;

#de-reference the array refs
my @fieldlist = @{$fieldlist};
my @data = @{$data};

my $k=0;				
my $field;
my $value;
my $header;
my $newheader;
		
#parse through the fields and create a properly formatted fasta header
while ($fieldlist[$k]) {
	$field = $fieldlist[$k];
	chomp $field;

	#check for sampleID
	$value = $data[$field];

	#handle the first field individually
	if ( $k == 0 ) {
		#if the value is defined
		if (length $value) {
			$header = $value;
		}
		else {
			print "SampleID field missing\n";
		}
	}

	#check that value is defined
	elsif (length $value) {
		$newheader = $header."|".$value;
		$header = $newheader;	
	}

	#if value is undefined, just print the delimiter
	else {
		$newheader = $header."|";
		$header = $newheader;
	}
	$k++;
}

return $header;

$k=0;
$field=();
$value=();
$header=();
$newheader=();

}
