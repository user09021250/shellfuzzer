#!/bin/sh

#==========================================================================
#
#  FILE:
#	debug.sh
#	
#  DESCRIPTION:
#	Debug crash with GDB
#
#  USAGE:
#  	./debug.sh <IN_FILE>  <BIN_FILE>
# 	
# 	
#==========================================================================



#BIN="/home/your_username/Desktop/tests/mksh-master3/mksh-master3/mksh-master/mksh"
BIN="/home/your_username/Desktop/tests/mksh-master3/mksh-master3/mksh-master_no_instr/mksh-master/mksh"
IN_FILE="$1"
if [ "$2" != "" ]; then
	BIN="$2"
fi

OUT_FILE="gdb.out"
if [ "$3" != "" ]; then
	OUT_FILE="$3"
fi

backtrace_max_len="200"

echo "q" | gdb "$BIN" -ex "r ""$IN_FILE"" "  -ex "backtrace ""$backtrace_max_len" > "$OUT_FILE" 2>&1
