#!/bin/sh

#==========================================================================
#
#  FILE:
#	gen_mut.sh
#	
#  DESCRIPTION:
#	Produce mutated variants for generator N by executing the mutation module on each detected alert program
#
#  USAGE:
#	./gen_mut.sh
#
# 	
#==========================================================================



USER="your_username"
WORKDIR="/home/""$USER""/Downloads/Grammar-Mutator-stable/to_keep/common"
MUT="$WORKDIR"/mut_modules/mut_var4_v7

# Debug

# Variable used for debugging purposes
# BIN_FILE="/home/""$USER""/Desktop/tests/mksh-master3/mksh-master3/mksh-master/mksh"


# FILE_LIST="$(ls -f -d "$WORKDIR"/bug_*/* | grep "$WORKDIR""/bug_[0-9]\+/[0-9]*$")"
# FILE_LIST="$(find "$WORKDIR"/bug_*/ -type f -print | grep "$WORKDIR""/bug_[0-9]\+/[0-9]*$")"
# FILE_LIST="$(find "$WORKDIR"/baks/prev_bugs/other/other_server.img_server_test_only7*/curr_bugs*/bug_*/ -type f -print | grep "curr_bugs.*""/bug_[0-9]\+/[0-9]*$")"

# End debug


FILE_LIST="$(find "$WORKDIR"/baks/prev_bugs/other/individual_gen/other_server.img_server_test_only7*/curr_bugs*/bug_*/ -type f -print | grep "curr_bugs.*""/bug_[0-9]\+/[0-9]*$")"

# print differences in mutated PUTs
for f in $FILE_LIST; do
	# only consider bugs found by generator number 3 
	F_DIR="$(dirname "$f")"	
	if [ "$(head -3c "$F_DIR"/PUT_generator.txt)" '=' '#.3' ]; then 

		echo "$f"
		$MUT "$f" /dev/stdout RANDOM > "$f"_mut_n
		cmp -b "$f" "$f"_mut_n | awk '{ print $10 }' > "$f"_df
		# Alternative 
		# cmp -b "$f" "$f"_mut_v | awk '{ print $(NF-1) }' > "$f"_df
		
		# Debug
		# cmp -b "$f" "$f"_mut_v | awk '{print $(NF-2)" "$(NF-1)" "$(NF)}' > "$f"_df
		# cmp -b "$f" "$f"_mut_v > "$f"_df

		# verify bug
		# $BIN_FILE "$f_mut"_v  | grep <REG>
		# End debug
	fi
done
echo "Done."

