#!/bin/sh

#==========================================================================
#
#  FILE:
#	break_in_lines.sh
#	
#  DESCRIPTION:
#	Split source file in lines 
#
#  USAGE:
#  	./break_in_lines2.sh <FILENAME> 
# 	
# 	
#==========================================================================



in_file="$1"

cat "$in_file" | sed 's/;/;\n/g'

