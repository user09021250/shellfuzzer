#!/bin/sh

#==========================================================================
#
#  FILE:
#	generate_puts.sh
#	
#  DESCRIPTION:
#  	Generate scripts with grammar-based generators
#
#  USAGE:
#  	./generate_puts.sh <SEEDS_DIR> <GENERATOR_NAME> <NUMBER_OF_PROCESSES_TO_START>
# 	
#==========================================================================


print_options() {
	printf "\nOptions:\n\n"
	printf "<SEEDS_DIR> <GENERATOR_NAME> <NUMBER_OF_PROCESSES_TO_START>\n\n"
}


rand() {
	# number of digits 
	num_digit=9
	hexdump -v -d /dev/urandom | awk '{ printf("1%s",$2) }' | head -c"$num_digit"
}



if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]; then
	print_options
	exit 1
fi


# Chunk size
PUT_size="$2" 

# Number of processes to start
N_PROC="$3"
# Number of test cases TCs to produce by each process
N=100000000
# Seeds directory
SEEDS_DIR="/tmp/additional_seeds"


if [ "$1" != "" ]; then
	SEEDS_DIR="$1"
fi


mkdir /tmp/to_delete || echo "Proceeding..." 

i=0
while [ $i -lt "$N_PROC" ]; do
	mkdir -p "$SEEDS_DIR"/"$i" || echo "Proceeding..."

	# Alternative (possible improvement, but less efficient after test)
	# N=10000
	# mkdir /tmp/empty || echo "Proceeding..."
	# chmod u-w /tmp/empty 
       	# ./"$PUT_size"/grammar_generator-testcommon* $N 100000000000 "$SEEDS_DIR"/"$i" /tmp/empty $i$RANDOM &
	# Other possible improvement: employ tmpfs to improve speed
 
	./"$PUT_size"/grammar_generator-testcommonother $N 100000000000 "$SEEDS_DIR"/"$i" /tmp/to_delete "$i""$(rand)" &
	i=$((i+1))

done

# remove tree files
find /tmp/to_delete -maxdepth 1 -type f -delete >/dev/null 2>&1
wait 
find /tmp/to_delete -maxdepth 1 -type f -delete >/dev/null 2>&1
