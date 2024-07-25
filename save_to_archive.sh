#!/bin/sh

#==========================================================================
#
#  FILE:
#	save_to_archive.sh
#
#	
#  DESCRIPTION:
#	Save bug report to archive	
#
#
#  USAGE:
#  	./save_to_archive.sh
#
# 	
# 	
#==========================================================================




set -e

USER="your_username"
WORK_DIR="/home/""$USER""/Downloads/Grammar-Mutator-stable/to_keep/common"
ARC_PAR_DIR="$WORK_DIR"/baks/prev_bugs
ADDITIONAL_BUG_DIR="/home/""$USER"




## Create new directory to archive
mkdir -p "$ARC_PAR_DIR"

# Number of directories saved in previous executions
n_dir=0
n_dir="$(find "$ARC_PAR_DIR" -maxdepth 1 -type d -iname "curr_bugs*" | wc -l)"

n_dir=$((n_dir+1))
mkdir "$ARC_PAR_DIR"/curr_bugs"$n_dir"

## Move bugs and log files into it
mv "$WORK_DIR"/bug_* "$ARC_PAR_DIR"/curr_bugs"$n_dir" || echo "Proceeding..."
mv "$WORK_DIR"/*.txt "$ARC_PAR_DIR"/curr_bugs"$n_dir" || echo "Proceeding..."
mv "$WORK_DIR"/*.tmp "$ARC_PAR_DIR"/curr_bugs"$n_dir" || echo "Proceeding..."


# Save additional bugs and warnings

if find "$ADDITIONAL_BUG_DIR"/special_bug -maxdepth 1 -iname "input_*" -type f -print -quit | grep -q '^'; then
	echo "Creating bug archive..."
	tar -zcf "$ARC_PAR_DIR"/curr_bugs"$n_dir"/special_bug.tar.gz -C "$ADDITIONAL_BUG_DIR"/special_bug . && rm -r "$ADDITIONAL_BUG_DIR"/special_bug
fi

if find "$ADDITIONAL_BUG_DIR"/special_warn -maxdepth 1 -iname "input_*" -type f -print -quit | grep -q '^'; then
	echo "Creating warning archive..."
 	tar -zcf "$ARC_PAR_DIR"/curr_bugs"$n_dir"/special_warn.tar.gz -C "$ADDITIONAL_BUG_DIR"/special_warn . && rm -r "$ADDITIONAL_BUG_DIR"/special_warn
fi

echo "Done."

