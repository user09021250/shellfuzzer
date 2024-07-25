#!/bin/sh

trap print_out TERM
trap ctrl_c INT


#==========================================================================
#
#  FILE:
#	script6.sh
#	
#  DESCRIPTION:
#
#  USAGE:
#  	./script6.sh <BIN_FILE> <SEEDS_DIR> <CHUNK_SIZE> [TIMEOUT for each CHUNK] [REG]
#
#	Required parameters are enclosed in angle brackets
# 	
# 	
#==========================================================================




## Program default settings 

# Default chunk size (number of TCs to merge)
CHUNK_SIZE=5000

# Log files (some of them are reserved for specific grammar-based generators)
BUGF="bugs.txt"
STAT_LOG_FILE="stat_log.txt"
OUTF="log2.txt"

# Mutation module
MUT="mut_modules/mut_var4_v7"

# Number of iterations before changing directory
ITER_CHANGE_DIR=10

# Temporary file to hold file list
TMP_FILE_LIST="filelist.tmp"

# Default timeout for each chunk
tt_per_put=10
tt="$(echo "print(($tt_per_put*$CHUNK_SIZE)/1000)" | python3 )"


## Additional settings

# Dynamic timeout: add dynamic value to timeout, depending on CHUNK_SIZE. 0=False (Default), 1=True.
DYNAMIC_TIMEOUT=0

# Default regex to match errors (can be modified by script commandline parameter)
REG="\"yntax\|ERROR\""


## Experimental features. Some of them are not used in the current release.

# Employ Radamsa. 0=False, 1=True
RADAMSA=0
RADAMSA_MUTATIONS="ab,bd,bf,bi,br,bp,bei,bed,ber,sr,sd,td,tr2,ts1,ts2,tr,num,ui,ft,fn,fo"
RADAMSA_SAFE_MUTATIONS="td,tr2,ts1,ts2,tr"
RADAMSA_BIN="/home/your_username/Downloads/radamsa-v0.6/bin/radamsa"
# Number of test cases to generate with Radamsa in each execution
RADAMSA_N=1

# Auth settings
A_FILE=".avb"

# Use temporary cmd file. 0=False (Default), 1=True.
USE_CMD_FILE=0

# Base name for tmp files
TMP_FILE=/tmp/additional_seeds/tmp_file_15443234

# Behaviour to adopt when seeds are finished. 0=Warning, 1=Warning and exit, 2=Change seed directory by incrementing a counter (MAX_SEED_FOLDERS is the maximum number of allowed folders)
ON_ZERO_SEEDS=2
MAX_SEED_FOLDERS=3

# Number of seconds to wait on zero seeds (to improve seed generation speed).
WAIT_ON_ZERO_SEEDS="2"

# Number of parallel processes to execute. Fixed or dynamic value, based on chunk_size.
N_PARALLEL_PROC=3
DYNAMIC_PARALLEL_PROC=0

# Predicted number of maximum files in each seed directory (employed to calculate N_PARALLEL_PROC)
MAX_FILE_PER_FOLDER=100000




## Utility functions

# Set permissions in RADAMSA mode. It (currently) requires admin permissions.
set_permissions() {
	base64 -d "$CURR_DIR""/""$A_FILE" | sudo -S chmod +t /home/"$USER"
	for dir_name in "$SEEDS_DIR" "$(dirname "$BIN_FILE")"; do
		if [ -d "$dir_name" ]; then 
			base64 -d "$CURR_DIR""/""$A_FILE" | sudo -S chown -R rad "$dir_name" > /dev/null 2>&1
		fi
	done
}

unset_permissions() {
	base64 -d "$CURR_DIR""/""$A_FILE" | sudo -S chmod -t /home/"$USER"
	for dir_name in "$SEEDS_DIR" "$(dirname "$BIN_FILE")"; do
		if [ -d "$dir_name" ]; then 
			base64 -d "$CURR_DIR""/""$A_FILE" | sudo -S chown -R "$USER" "$dir_name" > /dev/null 2>&1
		fi
	done
}


print_out () {
	echo 
	echo "Number of performed iterations: ""$count" 2>&1 | tee -a "$CURR_DIR"/"$STAT_LOG_FILE"
	echo "Number of executions: ""$((count*CHUNK_SIZE))" 2>&1 | tee -a "$CURR_DIR"/"$STAT_LOG_FILE"
	echo 
	cd "$CURR_DIR" || exit 

	exit
}


ctrl_c () {
	echo "Ctrl-C detected. Exiting..."
	print_out
}


print_options() {
	printf "\nOptions:\n\n"
	printf "<BIN_FILE> <SEEDS_DIR> <CHUNK_SIZE> [TIMEOUT for each CHUNK] [REG]\n"
	printf "\nRequired parameters are enclosed in angle brackets\n\n\n"
}


manage_possible_bug() {
		if [ "$RADAMSA" = "1" ]; then 
			unset_permissions
		fi

		echo "== Possible bug found. Logging and saving seeds..."

		# Debug
		# create directory for bug information
		# printf "Value: $n_bugs"
		# n_bugs="$(find "$CURR_DIR" -maxdepth 1 -type d -iname "bug_*" | wc -l)"
		# printf "\nValue:\n $n_bugs"
		# End debug

		n_bugs=$((n_bugs+1))

		# Debug
		# printf "\nValue:\n $n_bugs""\n"
		# End debug

		mkdir "$CURR_DIR"/bug_"$n_bugs" || { echo "Error... Bug directory ""$CURR_DIR"/bug_"$n_bugs"" already exists." && touch err_1 ;}

		# copy chunk of seeds (and remove it from SEEDS_DIR)
		for file_to_add in $(grep -E -o '^([0-9]+):' "$CURR_DIR"/"$TMP_FILE_LIST" | tr -d ":" | sort | uniq); do

			cp -n "$SEEDS_DIR""/""$file_to_add" "$CURR_DIR""/bug_""$n_bugs/" || echo "Proceeding..."
	
			# Debug (replace previous instruction)
			# cp -n $SEEDS_DIR/$file_to_add "$CURR_DIR"/bug_"$n_bugs/" || { cp -n "/tmp/to_delete/"$file_to_add "$CURR_DIR"/bug_"$n_bugs/" && touch "$CURR_DIR"/moved_from_deleted; }
			# End debug

			rm "$SEEDS_DIR""/""$file_to_add" || echo "Proceeding..."
		done

		# Debug
		# copy entire log into it. Useful for debugging purposes, but requires a significant amount of disk memory.
		# cp "$CURR_DIR"/"$OUTF" "$CURR_DIR"/bug_"$n_bugs"/"$BUGF"_"$n_bugs".log || echo "Proceeding..."
		# End Debug

		# save generator number
		"$CURR_DIR""/"get_config.py > "$CURR_DIR"/bug_"$n_bugs"/PUT_generator.txt
		# save timestamp
		date +"%H:%M:%S" >> "$CURR_DIR"/bug_"$n_bugs"/PUT_generator.txt

		# copy filelist log
		cp "$CURR_DIR"/"$TMP_FILE_LIST" "$CURR_DIR"/bug_"$n_bugs"/"$BUGF"_"$n_bugs"_"$TMP_FILE_LIST" || echo "Proceeding..."


		# remove log file (to avoid saving data for the same error multiple times) 
		# rm "$CURR_DIR"/"$OUTF" || echo "Proceeding..."
		if [ "$RADAMSA" = "1" ]; then
			set_permissions
		fi
 
		# copy list of applied mutations
		if [ -f "$CURR_DIR"/"$TMP_FILE_LIST"_mut ]; then
			cp "$CURR_DIR"/"$TMP_FILE_LIST"_mut "$CURR_DIR"/bug_"$n_bugs"/"$BUGF"_"$n_bugs"_"$TMP_FILE_LIST"_mut
		fi

	
		# Debug
		# Temporary patch: remove directory if empty (and decrement counter)
		NUM_F="$(ls "$CURR_DIR"/bug_"$n_bugs" | wc -l)"
		ls "$CURR_DIR"/bug_"$n_bugs" | grep -q "^[0-9]\+"
		if [ "$?" != 0 ] && [ "$NUM_F" = 2 ]; then
			printf "\nRemoving empty directory...\n"
			rm -r "$CURR_DIR"/bug_"$n_bugs"
			n_bugs=$((n_bugs-1))
		fi
		# End debug
}


### Main program


## Commandline parameters

# Verify input parameters
if [ "$1" = "" ] || [ "$2" = "" ] || [ "$1" = " " ] || [ "$2" = " " ]; then
	print_options
	exit 1
fi

BIN_FILE="$1"
SEEDS_DIR="$2"
PARENT_SEEDS_DIR="$(dirname "$SEEDS_DIR")"


if [ ! -f "$BIN_FILE" ]; then
	echo "Binary file does not exist. Exiting..."
	exit 1
elif [ ! -d "$SEEDS_DIR" ]; then
	echo "Input directory does not exist. Exiting..."
	exit 1
fi


if [ "$3" != "" ]; then
	CHUNK_SIZE="$3"

	if [ "$DYNAMIC_PARALLEL_PROC" = 1 ]; then
		N_PARALLEL_PROC="$(echo "print(int(""$MAX_FILE_PER_FOLDER""/""$CHUNK_SIZE""))" | python3)"
	fi
fi

if [ "$4" != "" ]; then
	tt="$4"
	if [ "$DYNAMIC_TIMEOUT" = 1 ]; then
		# add value to base timeout
		tt="$(echo "print(($tt*$CHUNK_SIZE))" | python3 )"
	fi
fi

if [ "$5" != "" ]; then
	REG="$5"
fi


# Save current directory before moving
CURR_DIR="$(pwd)"


# Number of bugs found in previous executions
n_bugs=0
n_bugs="$(find "$CURR_DIR" -maxdepth 1 -type d -iname "bug_*" | wc -l)"


# Debug
# set -x

cd "$SEEDS_DIR" || { echo "Error. Exiting..." && exit ; }
count=0
dir_count=0

CMD=""
if [ "$RADAMSA" = "1" ]; then 
	CMD="$TEMPLATE_SANDBOX"
	(cd "$CURR_DIR" && ./update_seeds.sh &)
	set_permissions
elif [ "$USE_CMD_FILE" = 1 ]; then
	CMD="$TEMPLATE_WHITEBOX_WITH_LOG"
	echo "$CMD" > "$PARENT_SEEDS_DIR"/cmd.tmp
	chmod u+x "$PARENT_SEEDS_DIR"/cmd.tmp
fi


while true; do








#.1         find "$SEEDS_DIR" -maxdepth 1 -type f -print0 | head -z -n "$CHUNK_SIZE" | xargs -0 -n 1 -P0 -I '%' sh -c '{ { { timeout -s KILL '$tt' cat '%' | '$CURR_DIR'/mut_modules/count_char_and_print3 2>> '$CURR_DIR'/put_sizes.txt | '$BIN_FILE' '%' "param_1 param_1_part2" "param_2 param_2_part2" 2>&1 ;} | sed "s/^/$(basename '%'):/" | { grep -A 20 '$REG' >>'$CURR_DIR'/'$TMP_FILE_LIST' 2>&1; };} || mv '%' /tmp/to_delete; } ' 2> /dev/null    



#.2      find "$SEEDS_DIR" -maxdepth 1 -type f -print0 | head -z -n "$CHUNK_SIZE" | xargs -0 -n 1 -P0 -I '%' sh -c '{ { { timeout -s KILL '$tt' '$CURR_DIR'/'$MUT' '%' /dev/stdout RANDOM | '$CURR_DIR'/mut_modules/count_char_and_print3 2>> '$CURR_DIR'/put_sizes.txt | '$BIN_FILE' '%' "param_1 param_1_part2" "param_2 param_2_part2" 2>&1 ;} | sed "s/^/$(basename '%'):/" | { grep -A 20 '$REG' >>'$CURR_DIR'/'$TMP_FILE_LIST' 2>&1; };} || mv '%' /tmp/to_delete; } ' 2> /dev/null    






   	find "$SEEDS_DIR" -maxdepth 1 -type f -print0 | head -z -n "$CHUNK_SIZE" | xargs -0 -n 1 -P0 -I '%' sh -c '{ { timeout -s KILL '$tt' '$CURR_DIR'/'$MUT' '%' /dev/stdout RANDOM | '$CURR_DIR'/mut_modules/count_char_and_print3 2>> '$CURR_DIR'/put_sizes.txt | '$BIN_FILE' -s "param_1 param_1_part2" "param_2 param_2_part2" 2>&1 ;} | { grep -F -q -e "syntax" -e "missing" -e "unclose" -e "E:" -e "inaccessible" -e "no\ closing" -e "unexpected" && mv '%' /tmp/to_delete; } || { echo $(basename '%'): >>'$CURR_DIR'/'$TMP_FILE_LIST'; };}' 2> /dev/null #.3







	if [ -s "$CURR_DIR"/"$TMP_FILE_LIST" ]; then
		manage_possible_bug
		rm "$CURR_DIR"/"$TMP_FILE_LIST" || echo "Proceeding..." 
	fi

	# Change directory and log counter
	if [ $(($count % $ITER_CHANGE_DIR)) -eq 0 ]; then
		dir_count=$(((dir_count+1)%$MAX_SEED_FOLDERS))
		NEW_DIR="$(dirname "$SEEDS_DIR")"/$dir_count
		echo "Changing directory from ""$SEEDS_DIR"" to ""$NEW_DIR"" ..."
		if [ -d "$NEW_DIR" ]; then
			SEEDS_DIR="$NEW_DIR"
			cd "$SEEDS_DIR" || { echo "Error. Exiting..." && exit ; }
		else
			echo "Error: new directory does not exist. Remaining in the current one."
		fi

		# Log counter
		echo "$((count*CHUNK_SIZE*ITER_CHANGE_DIR))" 2>&1 | tee -a "$CURR_DIR""/""$STAT_LOG_FILE"

	fi

	count=$((count+1))
done

