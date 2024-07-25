/* ========================================================================
#
#  FILE:
#	mut_var4_v7	
#	
#  DESCRIPTION:
# 	Apply program mutations	
#
#  USAGE:
# 	<INPUT> <OUTPUT> <wordToReplace> <wordToReplaceWith>
#
# 	<INPUT> <OUTPUT> random <wordToReplaceWith>  -> replace random token with fixed word
# 
# 	<INPUT> <OUTPUT> RANDOM  -> replace random token with random token
#
#
# =========================================================================
*/



#include <fstream>
#include <iostream>
#include <random>
#include <climits>
#include <experimental/random>
using namespace std;



void print_usage() {
	cout << " <INPUT> <OUTPUT> <wordToReplace> <wordToReplaceWith> " << endl;
 
  cout << " <INPUT> <OUTPUT> random <wordToReplaceWith>  -> replace random token with fixed word" << endl;
  
  cout << " <INPUT> <OUTPUT> RANDOM  -> replace random token with random token" << endl;
  										
}


int main(int argc, char **argv) {

	// Number of output lines to produce for each iteration
	const int N_OUTPUT=1;

	// Input tokens to modify or replace
	const int MAX_LEN=24;
	static string tokenList[MAX_LEN]={"if ", "then "," fi","while "," do ", ";do ", "for "," done"," esac","until ","case "," {",";{","}","[","]"," (",";(",")", "in ", " ((",";((", "))","\"$(("};

	// Replacement tokens
	const int MAX_LEN2=1;
	static string tokenListToReplaceWith[MAX_LEN2]={" "};

	// Option for replacement. "standard"=replace from command-line argument. "random"=replace a random token with the supplied one, "RANDOM"=replace a random token with a random token. Default: standard
	string option="standard";

	// Random seed to make every execution reproducible
	const int RANDOM_SEED=1234567;
	
	// Allow consecutive mutations starting from the initial input. 0=False 1=True (default)
	const int allow_consecutive_mut=1;

	// Number of iterations (attempts) of substitutions to perform before throwing an error
	const int ITER_ERR=10000;

	// Number of positions to ignore (starting from the end) when performing replacements. Larger values can improve the capability to reach deep branches in the CFG. Default=0;
	const size_t starting_pos=1;

	// Possible additional parameters
	// Number of occurrences to replace for each line (in order of appearance in the input) 
	// const int OCC_TO_REPLACE=experimental::randint(1,3);

	// Number of occurrences to ignore before starting to replace 
	// const int OCC_TO_IGNORE=experimental::randint(1,3);

	
	if (argc < 4 || argc > 5) {
		print_usage();
		return -1;
	}

	ifstream in(argv[1]);
	ofstream out(argv[2]);
	string wordToReplace(argv[3]);
	string wordToReplaceWith;

	if (!in) {
		cerr << "Could not open " << argv[1] << "\n";
		return 1;
	}

	if (!out) {
		cerr << "Could not open " << argv[2] << "\n";
		return 1;
	}

	experimental::reseed(RANDOM_SEED);
	
	if (wordToReplace=="random") {

		option="random";
		wordToReplace=tokenList[experimental::randint(0,MAX_LEN-1)];
		wordToReplaceWith=argv[4];


	} else if (wordToReplace=="RANDOM") {
		option="RANDOM";
		wordToReplace=tokenList[experimental::randint(0,MAX_LEN-1)];		
		wordToReplaceWith=tokenListToReplaceWith[experimental::randint(0,MAX_LEN2-1)];
	} else
		wordToReplaceWith=argv[4];
		

	// Debug
	// cout << "a: "  << endl;
	// cout << wordToReplace << endl;
	// cout  << "b: " << endl;
	// cout << wordToReplaceWith << endl;
	// End debug

	string line;
	string prev_line;

	// Number of performed replacements
	size_t repl=0;
	size_t len=wordToReplace.length();
	while (getline(in,line)) {
		// Produce N_OUTPUT outputs
		for (int j=0; j<ITER_ERR; j++) {
			prev_line=line;
				// Debug
				// cout << "a: "  << endl;
				// cout << wordToReplace << endl;
				// cout  << "b: " << endl;
				// cout << wordToReplaceWith << endl;
				// End debug


			// Different options
			// size_t pos=line.rfind(wordToReplace);
			// size_t pos=line.rfind(wordToReplace,starting_pos);
			// size_t pos=line.find(wordToReplace,floor(line.length()/2));
			// size_t pos=line.find(wordToReplace,floor(line.length()/3));
			// size_t pos=line.rfind(wordToReplace,floor(line.length()/2));
			// randomized
			// size_t pos=line.find(wordToReplace,floor(experimental::randint(0,line.length()-1)));
			// size_t pos=line.find(wordToReplace,floor(experimental::randint(0,line.length()-1)/2));

			size_t llength=line.length();
			size_t pos=0;
			if (llength > INT_MAX)
				pos=line.find(wordToReplace,floor(llength/3));
			else
				pos=line.find(wordToReplace,floor(experimental::randint(0,static_cast<int>(llength))/2));

			
			if (pos != string::npos) { // and pos < string.length() and string[pos-1] != "\"" and string[pos+1]!="\"" // avoid removing token from strings 
				// Debug
				// cout << "a: "  << endl;
				// cout << wordToReplace << endl;
				// cout  << "b: " << endl;
				// cout << wordToReplaceWith << endl;
				// cout  << "pos: " << endl;
				// cout  << pos << endl;
				// End debug

				line.replace(pos,len,wordToReplaceWith);
				cout << line << '\n';
				line=prev_line;
				repl++;
			}

			// Action to perform when there are no matches
			// Can be optimized (do-while)
			if (repl == N_OUTPUT)
				return 0;

			// Select new token to replace
			if (option=="random") {

				wordToReplace=tokenList[experimental::randint(0,MAX_LEN-1)];
				len=wordToReplace.length();
			} else if (option=="RANDOM") {

				// Debug
				// cout << wordToReplace << endl;
				// int index=experimental::randint(0,MAX_LEN-1);
				// cout << index << endl;
				// End debug
				
				
				wordToReplace=tokenList[experimental::randint(0,MAX_LEN-1)];

				len=wordToReplace.length();
				wordToReplaceWith=tokenListToReplaceWith[experimental::randint(0,MAX_LEN2-1)];

			}
		}

		// Exit with error to avoid infinite loop
		cout << "E: Error. unable to produce a syntax error after " << ITER_ERR << " iterations" << '\n';
		return -1;

	}
}
