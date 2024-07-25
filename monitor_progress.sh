#!/bin/sh

#==========================================================================
#
#  FILE:
#	monitor_progress.sh
#	
#  DESCRIPTION:
#  	Monitor execution of the testing process	
#
#  USAGE:
#  	./monitor_progress.sh <OPTION>
# 	
#==========================================================================


### Settings ###

USER="your_username"
BIN_FILE="/home/""$USER""/Desktop/tests/mksh-master3/mksh-master3/mksh-master/mksh"
# BIN_FILE="/home/"$USER"/Desktop/tests/mksh-master3/mksh-master3/mksh-master_afl/mksh-master/mksh"
SEEDS_DIR="/tmp/additional_seeds/0/"
BUGS_DIR="/home/""$USER""/Downloads/Grammar-Mutator-stable/to_keep/common/"
# Date format for watch command
DATE_FMT="+%H:%M:%S"

# Log files
INPUT_LOG_FILE="log2.txt"
COV_LOG_FILE="cov_log.txt"
CRASH_LOG_FILE="crash_log.txt"

# Measurement interval in seconds
INTERVAL="$((30))"  # 60*4 or very large for optimal performance 


### Main program ###

# Debug options
# set -e
# set -euxo pipefail
# End debug


if [ "$2" != "" ] && [ "$2" != " " ]; then
	BIN_FILE="$2"
fi

BIN_DIR="$(dirname "$BIN_FILE")"

printf "\n\nStarting monitoring..." 

if [ "$1" = "seeds" ]; then
	watch -n 1 "date ""$DATE_FMT""; ls -f ""$SEEDS_DIR"" | wc -l"
	# while true; do clear; date "$DATE_FMT"; ls -f "$SEEDS_DIR" | wc -l; sleep "$INTERVAL"; done
elif [ "$1" = "cov" ]; then
	watch -n "$INTERVAL" -p "{ date ""$DATE_FMT""; gcovr -b -k -j 5 -r ""$BIN_DIR"" ; } 2>/dev/null | egrep \"((TOTAL)|([0-9]+:[0-9]+:[0-9]+))\" | tr -s '\n' ' ' | cut -d \" \" -f1,3,4,5 >&1 | tee -a ""$COV_LOG_FILE"".tmp"
elif [ "$1" = "cov2" ]; then
	watch -n "$INTERVAL" -p "{ date ""$DATE_FMT"" | tr -s '\n' ' ' ; tail -1 ""$COV_LOG_FILE"".tmp ; }  | awk '{print \$1\" \"\$3\" \"\$4\" \"\$5}' |  tee -a ""$COV_LOG_FILE"
elif [ "$1" = "crash" ]; then
	watch -n "$INTERVAL" -p "date ""$DATE_FMT""; ls -f ""$BUGS_DIR"" | grep -F ""bug_"" | wc -l | tee -a ""$CRASH_LOG_FILE"
elif [ "$1" = "covsave" ]; then
	gcovr -b -k -j 5 -r "$BIN_DIR" ;
elif [ "$1" = "all" ]; then
	while true; do
		date "$DATE_FMT";
		printf "Calculating...\n"
		COV_VAL="$({ gcovr -b -k -j 5 -r "$BIN_DIR" ; } 2>/dev/null | grep -E "((TOTAL)|([0-9]+:[0-9]+:[0-9]+))" | tr -s '\n' ' ' | cut -d " " -f3,4,5 >&1)"
		CRASH_VAL="$(find "$BUGS_DIR" -maxdepth 1 -name "*bug_*" | wc -l)"	
		# CRASH_VAL="$(ls -f "$BUGS_DIR" | grep -F "bug_" | wc -l)"	
		#SEEDS="$(ls -f "$SEEDS_DIR" | wc -l)"
		SEEDS="$(find "$SEEDS_DIR" -maxdepth 1 | wc -l)"
		clear
		date "$DATE_FMT";
		printf "\n\nCOVERAGE: %s""$COV_VAL"
		printf "\nCRASHES: %s""$CRASH_VAL"
		printf "\nSEEDS: %s""$SEEDS"

		sleep "$INTERVAL"
	done

else
	if [ -f "$INPUT_LOG_FILE" ]; then
		watch -n 1 -p "tail -50 ""$INPUT_LOG_FILE"
	else
		echo "Log file doesn't exist. Exiting..."	
		exit 1
	fi
fi
