# README

This repository contains the scripts used to generate and analyze data for Porter & Hajibabaei, 2018 bioRxiv doi: https://doi.org/10.1101/353904

## Overview

[Part I - Retrieve Taxonomy IDs from the NCBI taxonomy database](#part-i---retrieve-taxonomy-ids-from-the-ncbi-taxonomy-database)
[Part II - Retrieve COI records from the NCBI nucleotide database](#part-ii---retrieve-coi-records-from-the-ncbi-nucleotide-database)
[Part III - Parse through the COI GenBank records and print reports](#part-iii---parse-through-the-coi-genbank-records-and-print-reports)
[Part IV - IUCN endangered animal species data analysis](#part-iv---iucn-endangered-animal-species-data-analysis)
[Part V - BARCODE dataset](#part-v---barcode-dataset)
[Part VI - Freshwater dataset](#part-vi---freshwater-dataset)
[Part VII - Map country & latlon metadata with R](#part-vii---map-country-&-latlon-metadata-with-R)
[Part VIII - Other R figures](#part-viii---other-r-figures)

## Part I - Retrieve Taxonomy IDs from the NCBI taxonomy database

Retrieve all taxonids from the NCBI taxonomy database for all Eukaryotes with a species name.  Be sure to add your email address to line 85 in ebot_taxonomy3.plx.

```perl
perl ebot_taxonomy3.plx
```

The outfile is taxonomy.taxid which contains a list of taxonids.

For each taxonid, skip entries that contain sp., nr., aff., or cf. else retrieve the genus and species.  Be sure to update the hard-coded paths to names.dmp and nodes.dmp on lines 29 and 30 in taxonomy_crawl_for_genus_species_list.plx  These can be obtained from ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz and should be kept current.

```linux
perl taxonomy_crawl_for_genus_species_list.plx taxonomy.taxid
```

The outfile is Genus_species.txt

Use the linux split command to break Genus_species.txt into smaller files for easier parsing.

```linux
split -l 100 Genus_species.txt
```

The outfiles will be automatically named with the prefix 'x'.

Reformat these files for the NCBI Entrez query using Linux commands and GNU parallel.  GNU parallel can be obtained from https://www.gnu.org/software/parallel/ .  Be sure to update the -j flag to reflect the number of available cores for this step.

```linux
ls | grep '^x' | parallel -j 23 "perl reformat_list_for_entrez_taxonomy.plx {}"
```

Outfiles will be automatically named with the prefix 'x' and file extension .txt

The following commands will clean up the directory a bit

```linux
mkdir reformatted_taxids
mv *.txt reformatted_taxids/.
mv reformatted_taxids/Genus_species.txt .
mkdir original_split_taxids
mv x* original_split_taxids/.
cd reformatted_taxids
```

## Part II - Retrieve COI records from the NCBI nucleotide database

Retrieve GenBank formatted text files from the NCBI nucleotide database.  Use Linux and GNU parallel to run a single job with a bunch of infiles.  The infiles here are the reformatted xsomething.txt files.  This script requires Bio::DB::Eutilities that can be obtained from CPAN.  Be sure to update the search terms used for the Entrez query on line 28 and your email address on line 31. 

```linux
ls | grep .txt | parallel -j 1 "perl grab_many_gb_catch_errors_auto_CO1_year.plx {}"
```

The outfiles will be automatically named 'xsomething_seqs.gb'.  Repeat this search as needed using the appropriate search terms varying the year[PDAT] as needed.  Organize outfiles into their own directories ex. genbank_records_year 

## Part III - Parse through the COI GenBank records and print reports

The script below will search the text-formatted fully identified GenBank COI records for records with sequences are at least 500bp in length, with country and/or latlon metadata.  The taxonomy.taxid file is from Part I.  The dirlist.txt should contain a list of directory names ex. genbank_records_year/ with one entry per line for each year.

```linux
perl quick_filter_gb_country_latlon_CO1.plx taxonomy.taxid dirlist.txt
```

The output is country_latlon_year.txt and is a tab delimited file with the following headers: species, GenBank accession, country, latlon, as well as binary fields for 500bp (0=no, 1=yes), country annotation present, latlon annotation present.

The script below will count up the number of fully identified records that are at least 500bp+ and contain country and/or latlon metadata.

```linux
sort -u country_latlon_year.txt | awk 'BEGIN {FS="\t"} {print $6"\t"$7"\t"$8}' | awk '{sum1 +=$1} {sum2 +=$2} {sum3 +=$3} END {print sum1"\t"sum2"\t"sum3}'
```

If needed, concatenate several outfiles using linux and GNU parallel for further processing of tabular data with Python.

```linux
 ls | grep country_latlon_20 | parallel -j 1 "cat {} >> cat.txt"
 ```

Clean up the tabular output to map this data in R.  The infile is cat.txt from above.

```linux
python3 genbank_map.py
```

The outfile is AllEukaryota_gg_latlon.csv 

## Part IV - IUCN endangered animal species data analysis
### Grab a list of target species from the IUCN website

Go to http://www.iucnredlist.org . Use the filters for taxonomy-> Animalia, save the search and export as a .csv file.  From this data grab a list of all binomial species names including synonyms.  Exclude names with affinis or sp.nov.  Name this file IUCN_genus_species.txt.

Go to https://www.ncbi.nlm.nih.gov/Taxonomy/TaxIdentifier/tax_identifier.cgi and submit the list IUCN_genus_species.txt

Grab just the unique taxids. Name this file taxonomy.taxid 

Adjust the line endings if necessary. Remove the quotes. Remove spaces.

### Plug these results into the data flow described in Parts I-III above

Using the clean taxonomy.taxid file with the taxonomy_crawl_for_genus_species_list.plx grab a list of good species names as described in Part I above.  Continue with the steps outlined in Part II to retrieve the COI GenBank records for the endangered animal species dataset.

The script quick_filter_gb_country_latlon_CO1.plx is described above in Part III and will search the text-formatted fully identified GenBank COI records for records with COI sequences are at least 500bp in length, with country and/or latlon metadata.  Continue with the remaining steps described in Part III.

The script below is similar to quick_filter_gb_country_latlon_CO1.plx and searches through the text-formatted fully identified GenBank COI records as above but also includes a field in the outfile for the organism name.  Another difference is that there is no filter for target taxa (ex. endangered species) and all taxa are reported.

```linux
perl quick_filter_gb_country_latlon_CO1_organism.plx dirlist.txt
```

The output country_latlon_year.txt is a tab delimited file as described above with an additional field for organism name.

Concatenate several outfiles using linux and GNU parallel, get a list of the unique species.

```linux
ls | grep organism_20 | parallel -j 1 "cat {} >> organism_cat.txt"
awk 'BEGIN {FS="\t"} {print $4}' organism_cat.txt | sort -u >> organism_cat.unique
```

Concatenate several outfiles using Linux and GNU parallel for further processing of tabular data with Python.

```linux
 ls | grep country_latlon_20 | parallel -j 1 "cat {} >> cat.txt"
 ```

Clean up the tabular output to map this data in R.  The infile is cat.txt.

```linux
python3 IUCN_map.py
```

The outfile is IUCN_gg_latlon.csv 

## Part V - BARCODE dataset

Use the grab_many_gb_catch_errors_auto_CO1_year.plx script from Part II above the the appropriate search terms including the "BARCODE"[KYWD] individually for one year at a time or for a range of years as described in the script. 

Parse through the text formatted COI GenBank records using the quick_filter_gb_country_latlon_CO1.plx script described above in Part III with the newly generated taxonomy.taxid and dirlist.txt files.

Count up the number of fully identified records in the country_latlon_year.txt files that are at least 500bp and contain country and/or latlon metadata as described above in Part III. Do this for each year.

Concatenate the country_latlon_year.txt reports into a single file as described above in Part III.

Reformat the data with python for analysis in R.  The infile is cat.txt.

```linux
python3 barcode_map.py
```

The output file is EukaryotaBarcode_gg_latlon.csv

## Part VI - Freshwater dataset

Get a list of all species names for each higher level taxon of interest for freshwater biomonitoring from the NCBI taxonomy database.  Insert the following search term, one at a time, into the ebot_taxonomy3.plx script: Hirudinea, Oligochaeta AND Metazoa, Gastropoda, Coleoptera, Diptera, Ephemeroptera, Megaloptera, Odonata, Plecoptera AND Polyneoptera, Trichoptera, Amphipoda, Isopoda, Polychaeta, Turbellaria.  Rename each taxonomy.taxid outfile so they don't get overwritten, ex. part1_taxonomy.taxid

```linux
perl ebot_taxonomy3.plx
```

Concatenate all the part_taxonomy.taxid files 

```linux
ls | grep part | parallel -j 1 "cat {} >> taxonomy.taxid"
```

Grab the genus and species names for each taxid using the taxonomy_crawl_for_genus_species_lsit.plx script described above in Part I.  The outfile is Genus_species.txt .  Continue with the steps described in Part I above.

Grab the GenBank formatted text files from the NCBI nucleotide database using the grab_many_gb_catch_errors_auto_CO1_year.plx script described above in Part II.  Do this for each year.

Count up the number of fully identified records in the country_latlon_year.txt files that are at least 500bp and contain country and/or latlon metadata as described in Part III.

Concatenate the country_latlon_year.txt reports into a single file as described above in Part III.

Reformat the data with python for analysis in R.  The infile is cat.txt

```linux
python3 freshwater_map.py
```

The output file is freshwater_gg_latlon.csv

## Part VII - Map country & latlon metadata with R

Script to create Fig 4 is F4_maps_061218.R and uses the dataset AllEukaryota_gg_latlon.csv

Script to create Supplementary Fig 3 (S3) is SF3_maps.R and uses the datasets EukaryotaBarcode_gg_latlon.csv, freshwater_gg_latlon.csv, and IUCN_gg_latlon.csv

## Part VIII - Other R figures

Script to create Fig 1 is F1_bars.R and the dataset is F1.csv

Script to create Fig 2 is F2_facetbars.R and the dataset is F2.csv

Script to create Fig 3 is F3_stackedbar.R and the dataset is F3.csv

Script to create Supplementary Fig 1 (S1) is SF1_horizbar.R and the dataset is FS1.csv

Script to create Supplementary Fig 2 (S2) is SF2_bars.R and the dataset is FS2.csv

# Acknowledgements

I would like to acknowedge funding from the Canadian government through the Genomcis Research and Development Initiative (GRDI) EcoBiomics project.

Last updated: June 26, 2018
