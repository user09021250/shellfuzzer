#!/bin/sh

#==========================================================================
#
#  FILE:
#	compress_bug_report.sh
#	
#  DESCRIPTION:
# 	Compress bug reports
#
#  USAGE:
# 	./compress_report.sh 
#
#==========================================================================



SEM_DIR="/home/your_username/special_bug"
WARN_DIR="/home/your_username/special_warn"

c=0
while [ -f bugs"$c".tar.gz ]; do
	c=$((c=c+1))
done
tar -czvf bugs"$c".tar.gz bug_*

# Logic bugs
tar -czvf sem_bugs"$c".tar.gz "$SEM_DIR"/input_*
tar -czvf sem_warn"$c".tar.gz "$WARN_DIR"/input_*
