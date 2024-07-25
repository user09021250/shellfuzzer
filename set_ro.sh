#!/bin/sh

set -e

#==========================================================================
#
#  FILE:
#	set_rw.sh
#	
#  DESCRIPTION:
#	Make the environment read-only before starting the testing process
#
#  USAGE:
#	./set_rw.sh
#
#==========================================================================


USER=your_username
# Binary directory. The parent directory must be included, because it is used by the main program.
BIN_DIR="/home/your_username/Desktop/tests/mksh-master3/mksh-master3/"
SEEDS_DIR="/tmp/additional_seeds/"
# The work directory must reside inside the home directory
WORKDIR="/home/""$USER""/Downloads/Grammar-Mutator-stable/to_keep/common"


# Create output folders 
for OUT_FOLDER in "$SEEDS_DIR" /home/"$USER"/special_bug /home/"$USER"/special_warn; do
	if [ ! -d "$OUT_FOLDER" ]; then
		mkdir "$OUT_FOLDER"
	fi
done

# Set to read-only
# everything, except
chmod -R a-w /home/"$USER"

# output folders
# mkdir /home/"$USER"/special_bug || echo "Proceeding..."
# mkdir /home/"$USER"/special_warn || echo "Proceeding..."
chmod -R u+w /home/"$USER"/special_bug
chmod -R u+w /home/"$USER"/special_warn

# - binary folder
chmod -R u+w "$BIN_DIR"

# - seed directory
chmod -R u+w "$SEEDS_DIR" || echo "Proceeding ..."

# - non-binary files in work directory
chmod -R u+w "$WORKDIR"
chmod -R u-w "$WORKDIR"/mut_modules || echo "Proceeding ..."
chmod -R u-w "$WORKDIR"/*.sh || echo "Proceeding ..."
chmod -R u-w "$WORKDIR"/*.py || echo "Proceeding ..."
chmod -R u-w "$WORKDIR"/*.cpp || echo "Proceeding ..."
chmod -R u-w "$WORKDIR"/mut || echo "Proceeding ..."


# exception (must be modified by select_config.py)
chmod -R u+w "$WORKDIR"/script6.sh
