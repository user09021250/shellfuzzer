#!/bin/sh

#==========================================================================
#
#  FILE:
#	clean_logs.sh
#	
#  DESCRIPTION:
# 	Clean log files and create a compressed backup with postfix POSTFIX
#
#  USAGE:
# 	./clean_logs.sh "<POSTFIX>"
# 	./clean_logs.sh delete - Delete log files without performing backup
# 	./clean_logs.sh deleteall - Delete log files and reports in home folder without performing backup
#
#==========================================================================


LOG_FILES="cov_log.txt crash_log.txt stat_log.txt main_log.txt log2.txt filelist.tmp found.tmp cmd.tmp filelist.tmp_mut cov_log.txt.tmp put_sizes.txt"
USER="your_username"
SPEC_BUG_DIR_PREFIX="/home/""$USER""/special_"


POSTFIX=""
if [ "$1" != "" ]; then
	POSTFIX="$1"
fi

for logfile in $LOG_FILES; do
	if [ -f "$logfile" ]; then
		# create a compressed backup
		if [ "$POSTFIX" != "delete" ] && [ "$POSTFIX" != "deleteall" ]; then
			OUT_NAME="$logfile".bak"$POSTFIX"
			n=0
			while [ -f "$OUT_NAME"_"$n".gz ]; do
				n=$((n+1))
			done
			gzip -k -c "$logfile" > "$OUT_NAME"_"$n".gz
		fi	
		# remove logs
		rm "$logfile" || echo "Proceeding..."
	fi
done


if [ "$POSTFIX" '=' "deleteall" ]; then
		echo "Removing bug reports in home folder..."
		find $SPEC_BUG_DIR_PREFIX"bug" -maxdepth 1 -type f -iname "input_*" -delete
		find $SPEC_BUG_DIR_PREFIX"warn" -maxdepth 1 -type f -iname "input_*" -delete
fi

echo "Done."
