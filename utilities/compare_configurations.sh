#!/bin/sh

#==========================================================================
#
#  FILE:
#	compare_configurations.sh
#	
#  DESCRIPTION:
#	Compare different configurations, after post-processing
#
#  USAGE:
#  	./compare_configurations.sh <FILENAME> 
# 	
# 	
#==========================================================================



cat "$1" | grep "Tot \(Mem\|Cov\|logic alerts\ \+\)" | sed 's/Tot Coverage: [0-9]\+/&\n/'
