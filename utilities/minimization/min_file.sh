#!/bin/sh

#==========================================================================
#
#  FILE:
#	min_file.sh
#	
#  DESCRIPTION:
# 	Minimize test case
#
#  USAGE:
# 	./min_file.sh <FILE>
#
#==========================================================================


# Purpose: minimize testcase size in case of nested structures (such as programming languages). The current prototype implementation is focused on shell scripts.


### Settings
BIN="/home/your_username/Desktop/tests/mksh-master3/mksh-master3/mksh-master/mksh"
MATCH="ERROR:" #"not an identifier"
MATCH2="Leak" #"'||'"
VERBOSE=1
# Delete candidate or keep only it. Default is to delete it until the output stops matching
STRATEGY="delete"
# Change replaced token after $EQUAL_CUTOFF failed attempts. Disabled=99999999
EQUAL_CUTOFF="99"

# Debug settings
set -x
#set -e



## Program

IN_F="$1"
cp "$IN_F" file.tmp

smallest_match="$(basename "$IN_F")"
cp "$smallest_match"  smallest_match.txt

i=0
count_equal=0
while true; do

	PREV_LENGTH="$CURR_LENGTH"
	
	printf "================"
	printf "Current length: "
	CURR_LENGTH="$(wc -c file.tmp | cut -d " " -f1 )"
	printf "%s\n""$CURR_LENGTH"

	if [ "$PREV_LENGTH" '=' "$CURR_LENGTH" ]; then
		count_equal=$((count_equal+1))

		if [ "$count_equal" -gt "$EQUAL_CUTOFF" ]; then
			# Change token
			i=$((i+1000))
			count_equal=0
		fi
	fi


	set +e
	python3 -O replace_candidate.py file.tmp "$i" "$STRATEGY" > file2.tmp

	if [ "$?" = 0 ]; then
		# exec
		test "$VERBOSE" -eq 1 && printf "%s\n" "=== replaced"

		# Assert that the two files are different
		if { diff -q file.tmp file2.tmp >/dev/null ; } && [ "$STRATEGY" '!=' "keep" ]; then
			printf "Fatal error. Exiting..."
			exit 1
		fi

		# Perform AND of two regexes
		# OUT="$($BIN file.tmp 2>&1 | awk -v match1="$MATCH" -v match2="$MATCH2" '$0 ~ match1 && $0 ~ match2 { print; }')"

		OUT="$("$BIN" file2.tmp 2>&1 | grep -E "$MATCH" | grep -E -o "$MATCH2")"
		# Debug
		# OUT="$($BIN file.tmp 2>&1 | awk '/ERR/ && /Leak/ { print; }')"
		# echo "OUT before: ""$OUT"
		# End debug

		# verify outcome
		if [ "$OUT" '!=' "" ]; then 

			# Debug
			# OUT becomes empty
			# echo "OUT after: ""$OUT"
			# if [ "$?" = 0 ]; then
			# echo "$OUT"
			# exit 1

			# set -e
			# End debug


			test "$VERBOSE" -eq 1 && echo "-> matches"

			# commit results to file
			cp file2.tmp file.tmp
			# save smallest_match
			cp file.tmp smallest_match.txt

			# Debug
			# test again the absence of bugs
			# OUT="$("$BIN" file.tmp 2>&1 | awk -v match1="$MATCH" -v match2="$MATCH2" '$0 ~ match1 && $0 ~ match2 { print; }')"
	
			# echo "OUT: ""$OUT"
			# if ! { echo "$OUT" |  grep -o 'Leak';} ; then
			#	echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ bug"
			# fi

			# if ! { echo "$OUT" |  grep -o 'Leak';} ; then
			#	echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ bug"
			# fi
			# End debug

			i=$((i+1))
		else
			test "$VERBOSE" -eq 1 && echo "=== The output does not match after replacement. Reloading previous file version..."
			if [ "$STRATEGY" '=' "keep" ]; then
				i=$((i+1))
			else
				STRATEGY="keep"
				continue
			fi
		fi
	else
		test "$VERBOSE" -eq 1 && echo "Regex not replaced. Proceeding..."
		i=$((i+1))
		#STRATEGY="delete"
		#continue
	fi

	STRATEGY="delete"
done

echo ""
echo "Smallest match: " smallest_match.txt


