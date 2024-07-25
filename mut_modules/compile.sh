#!/bin/sh

#==========================================================================
#
#  FILE:
#	compile.sh
#	
#  DESCRIPTION:
# 	Compile mutation modules and files in the current folder
#	gcc and g++ are required.
#
#  USAGE:
# 	./compile.sh 
#
#==========================================================================



gcc -O3 count_char_and_print3.c -o count_char_and_print3 
g++ -O3 mut_var4_v7.cpp -o mut_var4_v7

