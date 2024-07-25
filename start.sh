#!/bin/sh

#==========================================================================
#
#  FILE:
#	start.sh
#	
#  DESCRIPTION:
# 	Program start script
#
#  USAGE:
#  	./start.sh  --- Start program
#  	./start.sh debug --- Start program in debug mode (admin permission are not required, but it cannot increase the priority of the process for performance purposes). Additional debug statements are preceeded by # Debug comments.
#
#==========================================================================


# Create tmpfs to hold seeds. It requires at least 20-30GB of RAM. 0=Disabled, 1=Enabled.
TMPFS=0

MAIN_LOG="main_log.txt"

# Start program with main logger
# printf '\n\n%s\n\n%s\n' "ShellFuzzer v0.01." "Starting main program..." | tee -a "$MAIN_LOG" cov_log.txt stat_log.txt log2.txt crash_log.txt
printf '\n\n%s\n\n' "Starting main program..." | tee -a "$MAIN_LOG" cov_log.txt stat_log.txt log2.txt crash_log.txt

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
	sudo nice -n -1 sudo -u your_username ./test_param.sh 2>&1 | tee -a "$MAIN_LOG"
fi
echo "Done."
