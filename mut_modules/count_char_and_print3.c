/* ========================================================================
#
#  FILE:
#	count_char_and_print3
#	
#  DESCRIPTION:
# 	Count chars and print stdin (together with timestamp) to stdout
#
#  USAGE:
#	cat <input> | ./count_char_and_print3
#	
#
#
# =========================================================================
*/


#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <limits.h>

int main() {
	// count number of characters
	long long int counter = 0;
	// count number of lines (approximation)
	long long int counter2 = 0;
	time_t t = time(NULL);

	for (int c= getchar(); c != EOF && counter >= 0 && counter2 >= 0  ; c=getchar()) {
		// print the same character in output
		printf("%c",c);

		if (c == ';')
			counter2=counter2+1;

		counter=counter+1;

	}

	// return error in case of overflow
	if (counter <0 || counter2<0) {
		printf("Error: integer overflow. The file is too large.");
		return -1;
	}

	struct tm tm = *localtime(&t); 

	// print size and timestamp to stderr
	fprintf(stderr,"%02d:%02d:%02d\t%lld\t%lld\n", tm.tm_hour, tm.tm_min, tm.tm_sec, counter, counter2);
}
