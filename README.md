# ShellFuzzer v0.01. Prototype implementation

# How to use
=====================================

* Compile the shell interpreter

* Compile the mutation modules (in the 'mut_modules' folder)

* Update the paths of the work directory and the compiled interpreter binary (including the $HOME folder path) in the source

* Prepare (and compile) the program generators
	* ./prepare_grammars.sh


* Configure the software depending on specific needs and available system resources
	* Choose and configure the testing phase timeouts
	* monitor_resources.sh


* Start
./start.sh 

* Repeat the same test multiple times (default: 3 repetitions)
./start_with_rep.sh


Please note that the initial setup can require moderate skills in the UNIX environment. For further information, please, consult the documentation.

