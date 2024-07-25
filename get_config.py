#!/usr/bin/python3


#==========================================================================
#
#  FILE:
#	get_config.py
#	
#  DESCRIPTION:
# 	Return current generator configuration in stdout
#
#  USAGE:
# 	python3 get_config.py 
#	
#
#==========================================================================



#### Program code ####

USER="your_username"
WORKDIR="/home/"+USER+"/Downloads/Grammar-Mutator-stable/to_keep/common/"
FILENAME="script6.sh"

# initialization 
options=["#."+str(n) for n in range(0,10)]
filename=WORKDIR + FILENAME

with open(filename, 'r') as infile:
    lines=infile.readlines()

for line in lines:
    for option in options:
        if line.strip().endswith(option):
            print(option)

