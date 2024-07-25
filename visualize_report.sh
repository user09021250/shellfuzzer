#!/bin/sh

#==========================================================================
#
#  FILE:
#	visualize_report.sh
#	
#  DESCRIPTION:
# 	Visualize bug report (in progress)
#
#  USAGE:
# 	./visualize_report.sh
#
#==========================================================================


SEM_DIR="/home/your_username/special_bug"
CRASH_DIR="."

if [ "$1" = "sem" ]; then
	# logic / semantic bugs
	grep '' "$SEM_DIR"/input_*
else
	# crash inducing bugs
	cat "$CRASH_DIR"/bug_*/bugs.txt_*.log | grep -A 10 'ERR';
fi
