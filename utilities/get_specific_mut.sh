#!/bin/bash

#==========================================================================
#
#  FILE:
#	get_specific_mut.sh
#	
#  DESCRIPTION:
#	List detected alerts with specific mutation. Optionally open them in editor, together with the original programs
#
#  USAGE:
#	./get_specific_mut.sh 
#
# 	$1 replacement token
# 	$2 optional: open
#
# 	
#==========================================================================



USER="your_username"
WORKDIR="/home/""$USER""/Downloads/Grammar-Mutator-stable/to_keep/common"
# WORKDIR="/home/"$USER"/Downloads/Grammar-Mutator-stable/to_keep/common""/baks/prev_bugs/other/individual_gen/other_server.img_server_test_only7_ni/curr_bugs2"

shopt -s extglob

if [ "$2" = "open" ]; then

	grep "$1" "$WORKDIR"/bug_*/+([0-9])_df > .filelist.tmp
	FILE_LIST2="$(cat .filelist.tmp | sed 's/_df[^\s\S]\+$//' | tr '\n' ' ' )"

	FILE_LIST3=""
	for f in $FILE_LIST2; do
		FILE_LIST3="$FILE_LIST3"" ""$f"" ""$f"_mut_n
	done

	# Debug
	# echo "$FILE_LIST3"
	# End debug

	vim.tiny -p $FILE_LIST3

	# rm .filelist.tmp

else
	grep "$1" "$WORKDIR"/bug_*/+([0-9])_df
fi
