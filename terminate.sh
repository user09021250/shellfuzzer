#!/bin/sh

#==========================================================================
#
#  FILE:
#	terminate.sh
#	
#  DESCRIPTION:
# 	Terminate testing process	
#
#  USAGE:
#  	./terminate.sh  
#
#==========================================================================


# Username
USER="your_username"

# Work directory
WORKDIR="/home/""$USER""/Downloads/Grammar-Mutator-stable/to_keep/common"

# Number of maximum iterations
N=10

# Array of programs to terminate
SCRIPTS="script6\.sh|grammar_generator-testcommon|monitor_resources\.sh|monitor_progress\.sh|watch|gcovr|afl-fuzz|generate_puts\.sh|mksh|radamsa|update_seeds\.sh|exec_nodes\.sh|find"


echo "Terminating program..."

# do-while loop to terminate processes 
for i in $(seq 1 $N); do
	pkill -9 -f -u "$USER" "$SCRIPTS"

	if [ $? -eq 1 ]; then
		break
	fi
done	

# Clean temporary files
echo "Cleaning temporary files..."
rm "$WORKDIR"/.gen_nice_lowered || echo "Proceeding..."
find /tmp/to_delete -maxdepth 1 -type f -delete >/dev/null 2>&1

# Slower alternative
# rm -r /tmp/to_delete && mkdir /tmp/to_delete

# Stop 'find processes' at the end
# sleep 0.2
# pkill -9 -f -u "$USER"  find
# pkill -9 -f -u "$USER"  rm

printf "Program terminated.\n"

# Debug (diagnostic message)
printf "You can verify it from the following pgrep output (it should be empty, otherwise execute this script a second time):\n"
pgrep -f -u "$USER" "$SCRIPTS" || true
# End-debug
