#!/bin/sh

#==========================================================================
#
#  FILE:
#	cp_with_exclusion.sh
#	
#  DESCRIPTION:
# 	Copy <SOURCE> to <DEST> and exclude <EXCLUDE> path list
#
#
#  USAGE:
#  	./cp_with_exclusion <SOURCE> <DEST> <EXCLUDE_FILE1> [<EXCLUDE_FILE2>] [...]
# 
#  DEPENDENCIES:
#	* tar
#
#==========================================================================


set -e

SOURCE="$1"
DEST="$2"
shift 2

if [ "$SOURCE" '=' "" ] || [ "$DEST" '=' "" ] || [ "$1" '=' "" ] ; then
	echo "Usage: "
	echo "$0 <SOURCE> <DESTINATION> <EXCLUDE PATH> <EXCLUDE PATH> <...>"
	echo
	exit 1
fi

set -x
# remove previous tmp file
rm tmp.tar || echo "Proceeding"

# Build exclusion list
for option in "$@"; do
	OPTIONS="$OPTIONS"" --exclude ""$option"
done
tar $OPTIONS -vcf /tmp/tmp.tar "$SOURCE" && mkdir -p "$DEST" && tar -xf /tmp/tmp.tar --directory "$DEST" && rm /tmp/tmp.tar


# manage path
if [ -d "$DEST" ] && [ "$DEST" != "" ] && [ "$DEST" != " " ] && [ "$DEST" != "/" ]; then
	mv "$DEST"/home/your_username/Downloads/Grammar-Mutator-stable/to_keep/* "$DEST" && rmdir -p --ignore-fail-on-non-empty "$DEST"/home/your_username/Downloads/Grammar-Mutator-stable/to_keep
fi

printf "\n%s\n" "Done."
