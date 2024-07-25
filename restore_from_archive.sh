#!/bin/sh

#==========================================================================
#
#  FILE:
#	restore_from_archive.sh
#
#	
#  DESCRIPTION:
#	Restore bug report from archive to WORK directory
#
#  USAGE:
#
#	./restore_from_archive.sh
# 	
# 	
#==========================================================================


USER="your_username"
WORK_DIR="/home/""$USER""/Downloads/Grammar-Mutator-stable/to_keep/common"
ARC_PAR_DIR="$WORK_DIR"/baks/prev_bugs
ADDITIONAL_BUG_DIR="/home/""$USER"

# bug report number to restore from archive
n_dir="$1"


if ! find "$ADDITIONAL_BUG_DIR"/special_bug -maxdepth 1 -iname "input_*" -type f -print -quit | grep -q '^'; then
	if ! find "$ADDITIONAL_BUG_DIR"/special_warn -maxdepth 1 -iname "input_*" -type f -print -quit | grep -q '^'; then
		if ! find "$WORK_DIR" -maxdepth 1 -type d -iname "bug_*" | grep -q '^'; then
			if ! find "$WORK_DIR" -maxdepth 1 -type d -iname "*.txt" | grep -q '^'; then
				if ! find "$WORK_DIR" -maxdepth 1 -type d -iname "*.tmp" | grep -q '^'; then	
					if [ -d "$ARC_PAR_DIR"/curr_bugs"$n_dir" ]; then 

						# main bug reports
						mv "$ARC_PAR_DIR"/curr_bugs"$n_dir"/bug_* "$WORK_DIR"
						mv "$ARC_PAR_DIR"/curr_bugs"$n_dir"/*.txt "$WORK_DIR"
						mv "$ARC_PAR_DIR"/curr_bugs"$n_dir"/*.tmp "$WORK_DIR"


						# special bugs/warnings
						mkdir -p "$ADDITIONAL_BUG_DIR"/special_bug "$ADDITIONAL_BUG_DIR"/special_warn
						tar -xzf "$ARC_PAR_DIR"/curr_bugs"$n_dir"/special_bug.tar.gz -C "$ADDITIONAL_BUG_DIR"/special_bug
						tar -xzf "$ARC_PAR_DIR"/curr_bugs"$n_dir"/special_warn.tar.gz -C "$ADDITIONAL_BUG_DIR"/special_warn

					else
						echo "Archive folder does not exist. Exiting..."
					fi	
				else
					echo "Cannot proceed: there are already bug reports in the working directory"
				fi	
			else
				echo "Cannot proceed: there are already bug reports in the working directory"
			fi		
		else
			echo "Cannot proceed: there are already bug reports in the working directory"
		fi
	else
		echo "Cannot proceed: there are already bug reports in the special warn directory"
	fi
else
echo "Cannot proceed: there are already bug reports in the special bug directory"
fi
