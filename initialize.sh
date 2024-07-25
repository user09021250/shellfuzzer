#!/bin/sh

#==========================================================================
#
#  FILE:
#	initialize.sh
#	
#  DESCRIPTION:
#  	Initialize environment and produce TCs before starting the testing process	
#
#  USAGE:
#  	./initialize.sh
# 	
#==========================================================================


# generate initial programs
echo "Generating initial shell programs..."
mkdir /tmp/additional_seeds || echo "Proceeding..."
sudo nice -n -20 sudo -u your_username ./generate_puts.sh /tmp/additional_seeds 2500 2

sleep $((60*2)) # $((60*60*2))

./terminate.sh
echo "Done."
