#!/bin/sh

#==========================================================================
#
#  FILE:
#	count_lines2.sh
#	
#  DESCRIPTION:
#	Count number of lines for each file in <DIR> and compute average 
#
#  USAGE:
#  	./count_lines2.sh 
# 	
# 	
#==========================================================================



# Count lines and compute average

trap print_out QUIT TERM INT

DIR=/tmp/additional_seeds/6/0


print_out () {
	printf "\n"
	printf "%s" "$LIST_" | sed 's/+\+$/)\/'$counter'/' | tr -d '\n' | bc -i
	exit
}


if [ "$1" != "" ]; then
	DIR="$1"
fi

counter=0
LIST_="("
for file_ in "$DIR"/*; do
	LIST_="$LIST_""$(./break_in_lines.sh "$file_" | wc -l | tr -d '\n' )""+"
	counter=$((counter+1))
done
