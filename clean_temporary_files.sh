#!/bin/sh

#==========================================================================
#
#  FILE:
#	clean_temporary_files.sh
#	
#  DESCRIPTION:
# 	Clean temporary files (programs generated in default temporary folder)
#
#  USAGE:
# 	./clean_temporary_files.sh 
#
#==========================================================================




# Number of temporary folders
N_TMP_FOLDS=3

# Main (root) temporary folder
TMP_FOLD=/tmp/additional_seeds

# Folder for removal of temporary files
THRASH_FOLD=/tmp/to_delete


if [ "$1" != "" ]; then
	TMP_FOLD="$1"
fi

printf "Cleaning...\n"

# Decrement folder number to consider folder number 0
N_TMP_FOLDS=$((N_TMP_FOLDS-1))

for n in $(seq 0 $N_TMP_FOLDS); do
	find "$TMP_FOLD""/""$n" -maxdepth 1 -type f -delete >/dev/null 2>&1
done

find "$THRASH_FOLD" -maxdepth 1 -type f -delete >/dev/null 2>&1

printf "Done.\n"
