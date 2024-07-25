#!/bin/sh

#==========================================================================
#
#  FILE:
#	start_with_rep.sh
#	
#  DESCRIPTION:
# 	Program start script. Enable automation of multiple repetitions
#
#  USAGE:
#  	./start_with_rep.sh  --- Start program
#  	./start_with_rep.sh debug --- Start program in debug mode (additional debug statements are preceeded by # Debug comments).
#
#==========================================================================


# Create tmpfs to hold seeds. It requires at least 20-30GB of RAM. 0=Disabled, 1=Enabled.
TMPFS=0

MAIN_LOG="main_log.txt"
USER=your_username
WORKDIR=/home/"$USER"/Downloads/Grammar-Mutator-stable/to_keep/common

# Number of repetitions
REP=3

# Start program with main logger
r=0
while [ "$r" -lt "$REP" ]; do
	# printf '\n\n%s\n\n%s\n' "ShellFuzzer v0.01." "Starting main program..." | tee -a "$MAIN_LOG" cov_log.txt stat_log.txt log2.txt crash_log.txt
	printf '\n\n%s\n\n' "Starting main program (repetition ""$r"")..." | tee -a "$MAIN_LOG" cov_log.txt stat_log.txt log2.txt crash_log.txt

	# Start program
	echo "Making non-needed files read-only..."
	./set_ro.sh
	echo "Done."

	if [ "$1" = "debug" ]; then
		# Debug mode
		./test_param.sh 2>&1 | tee -a "$MAIN_LOG"
	else
		if [ "$TMPFS" = 1 ]; then
			# Create tmpfs
			mkdir -p /tmp/additional_seeds /tmp/to_delete
			sudo mount -t tmpfs tmpfs /tmp/additional_seeds -o size=15G,nr_inodes=5M
			sudo mount -t tmpfs tmpfs /tmp/to_delete -o size=10G,nr_inodes=5M
		fi
		base64 -d "$WORKDIR"/../.avb | sudo -S nice -n -1 sudo -u your_username ./test_param.sh 2>&1 | tee -a "$MAIN_LOG"
	fi
	echo "Done."
	

	# Experimental: enable automation of multiple repetitions 
	set -e

	cd $WORKDIR

	# verify time is elapsed

	# force termination
	for i in $(seq 1 10); do
		./terminate.sh
		pkill -9 find || true
		pkill -9 rm || true
	done

	# restore rw attributes
	./set_rw.sh

	# wait some seconds
	sleep 2

	# save bug reports
	./save_to_archive.sh

	# clean env
	./clean_logs.sh delete
	./clean_temporary_files.sh

	# wait some seconds
	sleep 2
	r=$((r+1))

done
