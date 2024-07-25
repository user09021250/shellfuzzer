#!/bin/sh

#==========================================================================
#
#  FILE:
#	valgrind.sh
#	
#  DESCRIPTION:
#	Debug crash with Valgrind
#
#  USAGE:
#  	./valgrind.sh <IN_FILE> 
# 	
# 	
#==========================================================================


BIN="/home/your_username/src/no_instr/mksh-master/mksh -x"

### Alternatives
# BIN="/home/your_username/Desktop/tests/mksh-master3/mksh-master3/mksh-master_no_instr/mksh-master/mksh -x"
# BIN="/home/your_username/src/mksh-master/mksh -x"


valgrind --leak-check=full --trace-children=yes --show-leak-kinds=all --track-origins=yes "$BIN" "$1" 


# verbose
# valgrind --leak-check=full --trace-children=yes --show-leak-kinds=all --track-origins=yes -v "$BIN" "$1" 
