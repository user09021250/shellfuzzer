#!/bin/bash

#==========================================================================
#
#  FILE:
#	get_mut_summary.sh
#	
#  DESCRIPTION:
#	Get list of applied mutations
#
#  USAGE:
#	./get_mutation_summary.sh
#
# 	
# 	
#==========================================================================



USER="your_username"
WORKDIR="/home/""$USER""/Downloads/Grammar-Mutator-stable/to_keep/common"
# WORKDIR="/home/"$USER"/Downloads/Grammar-Mutator-stable/to_keep/common""/baks/prev_bugs/other/individual_gen/other_server.img_server_test_only7_ni/curr_bugs1


shopt -s extglob

# print summary
cat "$WORKDIR"/bug_*/+([0-9])_df | sort | uniq -c

echo
echo "####################"
echo

# detect possible problems  
grep "unable"  "$WORKDIR"/bug_*/+([0-9])_mut_n


