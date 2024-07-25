#!/bin/sh

#==========================================================================
#
#  FILE:
#	get_diff.sh
#	
#  DESCRIPTION:
#  	Get difference between TC and its mutated variant and open both files with a text editor. Useful in conjunction with TC Generator Ni for debugging purposes.
#
#  USAGE:
#  	./get_diff.sh <FILENAME> <MUTATION MODULE VERSION>	
#
# 		$1: filename
# 		$2: mut version 
# 	
#==========================================================================


print_options() {
	printf "\nOptions:\n\n"
	printf "<FILENAME> <MUTATION MODULE VERSION> \n\n"
}


if [ "$1" '=' "" ] || [ "$2" '=' "" ] || [ "$1" '=' " " ] || [ "$2" '=' " " ]; then
	print_options	
fi



echo Filename: "$1" 

# Mutation module
MUT="mut_modules/mut_var4_v$2"


# Get mutated program
$MUT "$1" /dev/stdout RANDOM > mut_put.tmp
cmp -b "$1" mut_put.tmp | awk '{ print $10 }'

vi -p $1 mut_put.tmp
rm mut_put.tmp




