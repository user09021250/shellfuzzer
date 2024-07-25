#!/bin/sh

#==========================================================================
#
#  FILE:
#	count_lines.sh
#	
#  DESCRIPTION:
#	Count number of lines for each file in <DIR> and compute average 
#
#  USAGE:
#  	./count_lines.sh [<DIR>]
# 	
# 	
#==========================================================================


DIR=/tmp/additional_seeds/0/0

if [ "$1" != "" ]; then
	DIR="$1"
fi

for file_ in "$DIR"/*; do
	printf "\n"
	printf "%s" "$file_""\n"
	./break_in_lines.sh "$file_" | wc -l 
done
