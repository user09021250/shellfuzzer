#!/bin/sh

#==========================================================================
#
#  FILE:
#	update_seeds.sh
#	
#  DESCRIPTION:
# 	Update input seeds	
#
#  USAGE:
# 	./update_seeds.sh
#
#==========================================================================


COV_LOG_FILE="cov_log.txt"
THRESHOULD="0"
SEEDS_DIR="/tmp/additional_seeds/0"
REMOVED_SEEDS_DIR="/tmp/to_delete"
REPEAT_INTERVAL="20s"

# Number of seeds to copy
N_TO_CP=100

# Number of seeds to skip (most recent ones)
N_TO_SK=100
N="$((N_TO_CP+N_TO_SK))"

# Monitor cov file
# if cov diff > threshould, re-employ seeds
while true; do
	DIFF="$(tail -2 "$COV_LOG_FILE" | cut -d " " -f 4 | tr -d '%' | paste -sd-  | xargs -I "%" python3 -c "print(abs(""%""))")"
	echo "Diff: ""$DIFF"
	echo "Threshoud:""$THRESHOULD"

	if echo "$DIFF" | grep -E -q "^-?[0-9]+$" && [ "$DIFF" -gt "$THRESHOULD" ]; then
		# Debug
		echo "Updating seeds..."
		# End Debug

		ls -trfA "$REMOVED_SEEDS_DIR" | tail -n "$N" | head -n "$N_TO_CP" | xargs -I "{}" mv "$REMOVED_SEEDS_DIR""/""{}" "$SEEDS_DIR"

		# to add: when RADAMSA=0, use it in any case to mutate the seeds in a "safe" way, before re-employment.
	fi

	# Debug
	# echo "Not updating..."
	# End Debug

	sleep "$REPEAT_INTERVAL"
done
