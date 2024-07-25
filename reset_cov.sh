#!/bin/sh

#==========================================================================
#
#  FILE:
#	reset_cov.sh
#	
#  DESCRIPTION:
#  	Reset coverage of target binary 
#
#  USAGE:
#  	./reset_cov.sh
# 	
#==========================================================================


USER="your_username"
BIN_FILE="/home/""$USER""/Desktop/tests/mksh-master3/mksh-master3/mksh-master/mksh"
# Re-execute the script when the value does not decrease below ZERO_VALUE
ZERO_VALUE="0%"

# Representation of empty value
ZERO_VALUE2="--%"


if [ "$1" != "" ] && [ "$1" != " " ]; then
	BIN_FILE="$1"
fi


echo "Removing .gcda files..."
gcovr -b -d -j 5 -r "$(dirname "$BIN_FILE" )" 2>/dev/null | grep TOTAL

echo "Calculating coverage a second time for verification..."
sleep 1
VALUE="$(gcovr -b -d -j 5 -r "$(dirname "$BIN_FILE" )" 2>/dev/null | grep TOTAL | awk '{print $4}')"
echo "$VALUE"

while [ "$VALUE" != "$ZERO_VALUE" ] && [ "$VALUE" != "$ZERO_VALUE2" ]; do
	echo "$VALUE"
	echo "Re-executing..."
	sleep 1
	VALUE="$(gcovr -b -d -j 5 -r "$(dirname "$BIN_FILE" )" 2>/dev/null | grep TOTAL | awk '{print $4}')"
	echo "$VALUE"
done
