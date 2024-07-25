#!/bin/sh

#==========================================================================
#
#  FILE:
#	exec_nodes.sh
#	
#  DESCRIPTION:
# 	Start grammar-based program generators and testing framework components
#
#  USAGE:
# 	./exec_nodes.sh <TC-SIZE> <SINGLE TEST-CASE TIMEOUT> <CHUNK_SIZE> [REG]
# 	Required parameters are enclosed in angle brackets
#
#==========================================================================


# User settings

USER="your_username"
# Individual test case (TC) size
PUT_size="$1"
# Individual testcase timeout (ms)
tt="$2"
# Chunk size
CHUNK_SIZE="$3"
# Default timeout in seconds (can be overridden with script commandline parameter)
TIMEOUT="$((60*60*5))"
# Binary file
BIN_FILE="/home/""$USER""/Desktop/tests/mksh-master3/mksh-master3/mksh-master/mksh"


# Advanced settings

# Number of processes to start for generation
N_PROC=3
# Number of TCs to produce by each process
N=1000000000
# Seeds directory
SEEDS_DIR="/tmp/additional_seeds"
# Seconds to wait before the beginning of the test (in order to favour the production of inputs)
WAIT_BEFORE_STARTING="$((30))"
## Wait value for debugging
#WAIT_BEFORE_STARTING="$((0))"
#WAIT_BEFORE_STARTING="$((5))"



trap print_out INT

print_out () {
	echo "Ctrl-C detected. Exiting... Remember to logout in order to make sure to stop all the processes."
	exit
}

print_options () {
	printf "Options:\n\n"
	printf "<TC-SIZE> <SINGLE TEST-CASE TIMEOUT> <CHUNK_SIZE> [REG]\n" 

	printf "\nRequired parameters are enclosed in angle brackets\n\n"
}


rand() {
	# number of digits 
	num_digit=9
	hexdump -v -d /dev/urandom | awk '{ printf("1%s",$2) }' | head -c"$num_digit"
}


# Verify input parameters
if [ "$1" = "" ] || [ "$2" = "" ]; then
	print_options
	exit 1
fi

if [ "$4" != "" ]; then
	REG="$4"
fi

if [ "$5" != "" ]; then
	TIMEOUT="$5"
fi

mkdir -p "$SEEDS_DIR" || echo "Proceeding..."
watch -n 10 "find /tmp/to_delete -maxdepth 1 -type f -delete" >/dev/null 2>&1 &

i=0
while [ $i -lt "$N_PROC" ]; do
	mkdir "$SEEDS_DIR"/"$i" || echo "Proceeding..."
		
# 	Uncomment to slow down production speed for specific parameter values in order to avoid finishing the available inodes 
#	if [[ "$PUT_size" == "10" ]] && [[ "$CHUNK_SIZE" == "1" ]]; then
#		N=200000
#	fi

	# Employ tmpfs to improve speed
	./"$PUT_size"/grammar_generator-testcommonother $N 100000000000 "$SEEDS_DIR"/"$i" /tmp/to_delete $i"$(rand)" &
	i=$((i+1))
done

# Wait for new seeds
printf "Waiting for new seeds... "
sleep "$WAIT_BEFORE_STARTING"
echo "Done."

timeout -s KILL "$TIMEOUT" ./script6.sh "$BIN_FILE" "$SEEDS_DIR"/0 "$CHUNK_SIZE" "$tt" "$REG"


echo "Testing process terminated."
