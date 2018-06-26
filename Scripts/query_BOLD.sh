#!/bin/zsh
#Juen 26, 2018 by Teresita M. Porter
#Apr.26/18 break up a big query into a bunch of little ones
#taxonlist_all.txt should contain one taxon per line
#USAGE zsh query_BOLD.sh taxonlist_all.txt

#grab list of taxa to grab from the command line
taxonlist=$1

for taxon in `cat $taxonlist`
	do

	echo "Searching for $taxon..."

	#query BOLD through Public Data API
	wget "www.boldsystems.org/index.php/API_Public/sequence?marker=COI-3P|COI-5P&taxon=${taxon}" -O ${taxon}.fasta

done
