#!/bin/sh

#==========================================================================
#
#  FILE:
#	test_param.sh
#	
#  DESCRIPTION:
# 	Execute main program with several parameters	
#
#  USAGE:
#  	./test_param.sh  
#
#==========================================================================


#################################### Parameters ###############################

# Log files 
COV_LOG_FILE="cov_log.txt"
CRASH_LOG_FILE="crash_log.txt"
STAT_LOG_FILE="stat_log.txt"

# Seeds directory
SEEDS_DIR="/tmp/additional_seeds"
USER="your_username"
BIN_FILE="/home/""$USER""/Desktop/tests/mksh-master3/mksh-master3/mksh-master/mksh"

# Execute first phase. 0=False, 1=True.
FIRST_PHASE=1
FIRST_PHASE_DURATION="$((60*4))"
# Execute second phase. 0=False, 1=True (default). Useful for debugging purposes.
SECOND_PHASE=1
SECOND_PHASE_DURATION="$((60*4))"

# Number of seed generation processes to start.
N_PROC=3

# Skip selected combination of parameters. 0=False, 1=True.
SKIP_ITERATIONS=0

# Arrays containing different parameters
PUT_size="10 2500 500"

CHUNK_SIZE="1 100 1000"

TT="0.5 2.5 5"

# Uncomment to select specific parameters
PUT_size="500"
CHUNK_SIZE="100"
TT="2.5"


### Optional: additional phases and grammars

# Number of additional phases with custom grammars. 0=False. Default=0.
ADDITIONAL_PHASES=1

# Duration of additional phases
PHASES_DURATION=""$((60*4))""
# PHASES_DURATION=""$((60*30*0))" "$((60*30*0))" "$((60*30*0))""

# Paths to the grammars for each additional phase
ADDITIONAL_GRAMMARS="V2"
# ADDITIONAL_GRAMMARS="syntax 500 500"


### Additional (experimental) settings

# Temporary file to hold file list. Required only for some generator 
TMP_FILE_LIST="filelist.tmp"

# Employ result of previous execution for first phase. 0=False, 1=True.
PREV_PHASE_RESULTS=0


##########################################################################




############################## Functions #################################

terminate_processes() {
	./terminate.sh
	./terminate.sh
	./terminate.sh
	./terminate.sh
	./terminate.sh
}


# Write log header with parameters
write_log_header() {
		echo | tee -a "$COV_LOG_FILE" "$CRASH_LOG_FILE" "$STAT_LOG_FILE"
		echo "Phase: ""$1"  | tee -a "$COV_LOG_FILE" "$CRASH_LOG_FILE" "$STAT_LOG_FILE"
		echo "Parameters:"  | tee -a "$COV_LOG_FILE" "$CRASH_LOG_FILE" "$STAT_LOG_FILE"
		echo "put_size: " "$put_size" | tee -a "$COV_LOG_FILE" "$CRASH_LOG_FILE" "$STAT_LOG_FILE"
		echo "chunk_size: " "$chunk_size" | tee -a "$COV_LOG_FILE" "$CRASH_LOG_FILE" "$STAT_LOG_FILE"
		echo "tt: " "$tt" | tee -a "$COV_LOG_FILE" "$CRASH_LOG_FILE" "$STAT_LOG_FILE"
}


start_monitor_processes() {
	# Monitor and save coverage in background
	nice -n 5 ./monitor_progress.sh cov >/dev/null 2>&1 &
	./monitor_progress.sh cov2 >/dev/null 2>&1 &
	# Monitor and save number of crashes and found bugs in background
	./monitor_progress.sh crash "$BIN_FILE" >/dev/null 2>&1 &

	# Monitor system resources
	# Debug
	# echo "Debug: ""$SEEDS_DIR" "$put_size" "$N_PROC" | tee -a debug_out.txt
	# End debug

	./monitor_resources.sh "$SEEDS_DIR" "$put_size" "$N_PROC" >/dev/null 2>&1 &

	# Monitor coverage increments and update seeds
	# Started from script6.sh, when applicable.
	#./update_seeds.sh &
}


# clean SEEDS directory
clean_seeds_dir() {
	# clean SEEDS_DIR 
	echo "Cleaning seeds directories..."
	for subdir in "$SEEDS_DIR"/*; do
		if [ "$subdir" != "" ]; then
			if [ -d "$subdir" ]; then
				find "$subdir" -maxdepth 1 -type f -delete >/dev/null 2>&1 
			fi
		fi
	done
	echo "Done."
}

# Idea from stackoverflow.com/638802 (user Jo So)
# Print number of tokens in string.
length() { printf "%s" "$#"; }

# Get i-th token in input string.
# get <index> <string>
get() { shift "$1" ; printf "%s" "$1"; }

##############################################################################




################################# Main program ###############################


# Parse parameters
N1="$(length $PHASES_DURATION)"
N2="$(length $ADDITIONAL_GRAMMARS)"

if [ $ADDITIONAL_PHASES -ne 0 ]; then
	if [ "$ADDITIONAL_PHASES" != "$N1" ] || [ "$N1" != "$N2" ]; then
		printf "Invalid parameters. Additional testing phases are not correctly configured.\n"
		exit 1
	fi
fi

# Reset coverage
./reset_cov.sh

# First phase (syntax TC gen)
for put_size in $PUT_size; do
	for chunk_size in $CHUNK_SIZE; do
		for tt in $TT; do
			if [ "$FIRST_PHASE" -eq 1 ] && [ "$PREV_PHASE_RESULTS" -eq 0 ]; then

				./select_config.py "reset" && ./select_config.py "#.2"
				sleep 0.5

				write_log_header 1
				start_monitor_processes

				# Execute main program
				./exec_nodes.sh "syntax" "2" "1000" "ERROR" "$FIRST_PHASE_DURATION"

				# Completely terminate all background processes after execution
				terminate_processes
				
				# Save binary folder with initial cov value
				set -e

				BIN_DIR="$(dirname "$BIN_FILE")"
				if [ -d "$BIN_DIR"_saved ]; then
					rm -r "$BIN_DIR"_saved
				fi
				cp -r "$BIN_DIR" "$BIN_DIR"_saved

				set +e

				# Remove temporary files
				clean_seeds_dir
				rm "$TMP_FILE_LIST" || echo "Proceeding..."

			fi
		done
	done
done

# Second phase
# Loop through each parameter value
if [ "$SECOND_PHASE" -ne 0 ]; then
	for put_size in $PUT_size; do
		for chunk_size in $CHUNK_SIZE; do
			for tt in $TT; do
				# Copy binary folder (to restore coverage value after first phase)
				if [ "$FIRST_PHASE" -eq 1 ]; then
					set -e
					BIN_DIR="$(dirname "$BIN_FILE")"
					rm -r "$BIN_DIR" && cp -r "$BIN_DIR"_saved "$BIN_DIR"
					set +e
				fi

				./select_config.py "reset" && ./select_config.py "#.1"

				sleep 0.5

				write_log_header 2

				if [ "$SKIP_ITERATIONS" -eq 1 ]; then
					# Modify or uncomment to skip some iterations
					if [ "$put_size" = "10" ] && [ "$chunk_size" = "5000" ] && [ "$tt" = "50" ]; then
						 echo "Skipped"  | tee -a "$COV_LOG_FILE" "$CRASH_LOG_FILE" "$STAT_LOG_FILE" ; continue
						# sleep 0
					fi
				fi

				start_monitor_processes

				# Execute main program
				./exec_nodes.sh "$put_size" "$tt" "$chunk_size" "\"yntax\|ERR\"" "$SECOND_PHASE_DURATION"

				# Completely terminate all background processes after execution
				terminate_processes
			
				# Wait for completion
				sleep 0.5

if [ $ADDITIONAL_PHASES -eq 0 ]; then
				# Reset coverage
				./reset_cov.sh
fi

				clean_seeds_dir
			done
		done
	done
fi


### Additional phases ###

# Custom parameters for additional phases
TT="100"

# Test_param for tuning
# CHUNK_SIZE="10 100 1000"
# ADDITIONAL_GRAMMARS="V2 V2_2"

# Selected param
CHUNK_SIZE="1000"
ADDITIONAL_GRAMMARS="V2"

CURRENT_ADDITIONAL_PHASE=0
while [ $CURRENT_ADDITIONAL_PHASE -lt $ADDITIONAL_PHASES ]; do
	for put_size in $ADDITIONAL_GRAMMARS; do
		for chunk_size in $CHUNK_SIZE; do
			for tt in $TT; do
				./select_config.py "reset" && ./select_config.py "#.3"
				sleep 0.5

				write_log_header $(($CURRENT_ADDITIONAL_PHASE+3))
				# Optional: skip iterations with specific parameters.

				start_monitor_processes

				# Execute main program
				CURRENT_PHASE_DURATION="$(get $(($CURRENT_ADDITIONAL_PHASE+1)) $PHASES_DURATION)"
				./exec_nodes.sh "$put_size" "$tt" "$chunk_size" "\"yntax\|ERR\"" "$CURRENT_PHASE_DURATION"

				# Completely terminate all background processes after execution
				terminate_processes

				# Wait for completion
				sleep 0.5

				# Reset coverage
				./reset_cov.sh

				clean_seeds_dir
			done
		done
	done
	CURRENT_ADDITIONAL_PHASE=$(($CURRENT_ADDITIONAL_PHASE+1))
done

############################################################################
