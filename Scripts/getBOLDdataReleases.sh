#!/bin/zsh

#June 26, 2018 by Teresita M. Porter

#Apr.30/18 download data releases directly from http://www.boldsystems.org/index.php/datarelease
### BE SURE TO CITE WEBPAGE IN PUBLICATIONS ###
#releases.txt should contain one link per line
#USAGE zsh getBOLDdataReleases.sh releases.txt

#grab list of files to grab from the command line
files=$1

for file in `cat $files`
	do

	echo "Searching for $file..."

	#download each BOLD data release one at a time
	wget "${file}"

done
