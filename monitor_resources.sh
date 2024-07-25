#!/bin/sh

#==========================================================================
#
#  FILE:
#	monitor_resources.sh
#	
#  DESCRIPTION:
#  	Monitor and manage system resources during execution
#
#  USAGE:
#  	./monitor_resources.sh <SEEDS_DIR> <TC_SIZE> <NUMBER_OF_PROCESSES_TO_START>
# 	
#==========================================================================


# Settings

DISK_DEV=sda2
MAX_DISK="85" # in percentage
MAX_INODES="85" # in percentage
# Maximum logsize (in MB)
MAX_LOGSIZE="500"
LOG_FILE="log2.txt"
COV_LOG_FILE="cov_log.txt"

REPEAT_INTERVAL="20s"

# Number of seeds to delete when resources are scarse
N=70000

# Number of processes to restart when there is no running generator
N_PROC=3

# String to identify generators
PROC_STRING="grammar_generator-testcommonother"

# Minutes after which the nice of the generators is decreased
#MIN_MIN=10
MIN_MIN=1
MIN_HMIN="$(($MIN_MIN*2))"

# Stop processes older than age (in seconds)
OLD_AGE="$((60*15))"
# Stop processes older than age (in minutes)
OLD_AGE_MIN="15"


# Functions

print_options() {
	printf "\nOptions:\n\n"
	printf "<SEEDS_DIR> <TC_SIZE> <NUMBER_OF_PROCESSES_TO_START>\n"
}


rand() {
	# number of digits
	num_digit=9
	hexdump -v -d /dev/urandom | awk '{ printf("1%s",$2) }' | head -c"$num_digit"
}


compress_log() {
	echo "Compressing log file..."
	gzip -c -k log2.txt > log2_"$(rand)".txt.gz
	rm log2.txt
	touch log2.txt
	echo "Done."
}




# Main program

# Read parameters (to complete with validation)
# Seeds directory
SEEDS_DIR="$1"
# Individual shell program size
PUT_size="$2"
# Number of processes to start
N_PROC="$3"




if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]; then
	print_options
	exit 1
fi



while true; do

	# monitor disk and inode percentage
	DISK="$(df -h | grep "$DISK_DEV" | awk '{print $5}' | sed 's/%//')"
	INODES="$(df -ih | grep "$DISK_DEV" | awk '{print $5}' | sed 's/%//')"

	echo 
	echo 
	echo "DISK: ""$DISK""%"
	echo "INODES: ""$INODES""%"

	while [ "$DISK" -gt "$MAX_DISK" ] || [ "$INODES" -gt "$MAX_INODES" ]; do 
		# delete files
		echo "Deleting files..."
		find /tmp/to_delete -maxdepth 1 -type f -delete /dev/null 2>&1
		find /tmp/additional_seeds/2 -maxdepth 1 -type f -delete /dev/null 2>&1
		find /tmp/additional_seeds/1 -maxdepth 1 -type f -print0 | head -n "$N" | xargs -0 rm /dev/null 2>&1
		find /tmp/additional_seeds/0 -maxdepth 1 -type f -print0 | head -n "$N" | xargs -0 rm /dev/null 2>&1
		echo "Done."

		# update values
		DISK="$(df -h | grep "$DISK_DEV" | awk '{print $5}' | sed 's/%//')"
		INODES="$(df -ih | grep "$DISK_DEV" | awk '{print $5}' | sed 's/%//')"
	done
		
	# monitor log size 
	if [ -f "$LOG_FILE" ]; then
		LOGSIZE="$(du -m "$LOG_FILE" | awk '{print $1}' )"
		echo "LOGSIZE: ""$LOGSIZE""M"

		if [ "$LOGSIZE" -gt "$MAX_LOGSIZE" ]; then
			compress_log
		fi
	fi

	# monitor processes
	PIDs="$( pgrep -f "$PROC_STRING" )"
	if [ "$PIDs" = "" ]; then
		./generate_puts.sh "$SEEDS_DIR" "$PUT_size" "$N_PROC" &
	fi

	# As soon as there are enough scripts, decrease the nice of generators. If a generator is stopped for any reason, when it is automatically restarted, it recovers the default nice value.
	if [ ! -f .gen_nice_lowered ]; then
		#HMINUTES_PASSED="$(cat "$COV_LOG_FILE" | tr -d n | sed 's/Phase/{/g' | grep -o '{[^{]*{*' | sed 's/%/\n/g' | wc -l)"
		HMINUTES_PASSED="$(tac "$COV_LOG_FILE" | sed '/^tt/q' | tac | grep '%' | wc -l)"
	      	if  [ "$HMINUTES_PASSED" -gt "$MIN_HMIN" ]; then
			for gen in $PIDs; do
				renice 0 "$gen"
				touch .gen_nice_lowered
			done
		fi
	fi

	# When there are few TCs, increase nice to its original value

	# Stop old processes
	# When -O option is available
	# pkill -f -O "$OLD_AGE" "find /tmp/ "
	# pkill -f -O "$OLD_AGE" "rm /tmp/ "

	# killall -e -o "$OLD_AGE"s find > /dev/null 2>&1 # does not match full cmdline

	find /proc -maxdepth 1 -type d -name "[0-9]*" -mmin +"$OLD_AGE_MIN" | sed 's/$//cmdline/' | xargs -r grep -l --no-messages -e 'find /tmp/' -e 'rm -r /tmp/'| cut -d / -f3 | xargs -r kill -9

	sleep "$REPEAT_INTERVAL"
done
