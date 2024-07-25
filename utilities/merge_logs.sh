#!/bin/sh

#==========================================================================
#
#  FILE:
#	merge_logs.sh
#	
#  DESCRIPTION:
#	Merge log files and filter invalid characters
#
#  USAGE:
#  	./merge_logs.sh <OUT> <FOLDER>
# 	
# 	
#==========================================================================




# USER="your_username"
# WORKDIR="/home/"$USER"" 
# FOLDER=$WORKDIR/special_bug
OUT="$1"
# PRINT_FILENAMES=0 # 0=False (default), 1=True.
FOLDER="$2"

c=0
# Note: the folder structure is known a-priori
for f in $(find "$FOLDER" -maxdepth 1 -type f -print); do
	c=$((c+1))
	cat "$f" | tr -dc '[:print:]' >> "$OUT"
	printf "\n" >> "$OUT"
done
printf "%s" "Done.\nNumber of processed files: ""$c\n"

# remove empty lines
# sed -E -i '/$\s*^/d' "$OUT"
