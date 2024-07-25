#!/bin/sh

set -e

#==========================================================================
#
#  FILE:
#	set_rw.sh
#	
#  DESCRIPTION:
#	Make the environment writable (after the testing process) 
#
#  USAGE:
#	./set_rw.sh
#
#==========================================================================



USER=your_username
# BIN_FILE="/home/your_username/Desktop/tests/mksh-master3/mksh-master3/mksh"
# SEEDS_DIR="/tmp/additional_seeds/"

chmod -R u+w /home/"$USER"
