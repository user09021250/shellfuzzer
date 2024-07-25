#!/bin/bash
set -e

#==========================================================================
#
#  FILE:
#	prepare_grammars.sh
#	
#  DESCRIPTION:
#  	Prepare grammars
#
#  USAGE:
#  	./prepare_grammars.sh
# 	
#==========================================================================


# Settings
USER="your_username"
WORKDIR="/home/""$USER""/Downloads/Grammar-Mutator-stable_gen"

# Default grammars
GRAMMARS=(2500 500 10)
REPETITIONS=(288 58 2)

# Execute only for specific grammar. Empty = syntax and V2 only. Commented = disabled.
GRAMMARS=()
REPETITIONS=()


# Utilities
# clean previous execution
clean() {
	echo "Cleaning..."
	for gram in "${GRAMMARS[@]}"; do
		rm -r "$WORKDIR"_"$gram" || echo "Proceeding..." 
	done
	echo "Done."
}


# generate grammars with different sizes
gen_gram() {
	i=0
	for gram in "${GRAMMARS[@]}"; do
		echo "Generating grammar ""$gram""..."
		(cd "$WORKDIR"/grammars && "$WORKDIR"/grammars/supergrammar.sh "${REPETITIONS[$i]}" && cp "$WORKDIR"/grammars/testcommonother.json "$WORKDIR"/grammars/testcommonother_"$gram".json && cd "$INITIAL_DIR")
		i=$((i+1))
		echo "Done."
	done
}


# copy grammar files
copy_gram() {
	cd ..
	echo "Copying grammar files"
	for gram in "${GRAMMARS[@]}" ; do
		cp  -r "$WORKDIR" "$WORKDIR"_"$gram"
		cp "$WORKDIR"/grammars/testcommonother_"$gram".json "$WORKDIR"_"$gram"/grammars/
	done
}

# syntax grammar
copy_gram2() {
	rm -r "$WORKDIR"_syntax || echo "Proceeding..."
	cp  -r "$WORKDIR" "$WORKDIR"_syntax

	cp "$WORKDIR"/grammars/testcommonother_syntax.json "$WORKDIR"_syntax/grammars/
	NUM_GRAMS="${#GRAMMARS[@]}"
	GRAMMARS[$((NUM_GRAMS+1))]="syntax"
}


# V2 grammar
copy_gramV2() {
	rm -r "$WORKDIR"_V2 || echo "Proceeding..."
	cp  -r "$WORKDIR" "$WORKDIR"_V2

	cp "$WORKDIR"/grammars/testcommonother_V2.json "$WORKDIR"_V2/grammars/
	NUM_GRAMS="${#GRAMMARS[@]}"
	GRAMMARS[$((NUM_GRAMS+1))]="V2"
}


# Extended V2 grammar
copy_gramV2_2() {
	rm -r "$WORKDIR"_V2_2 || echo "Proceeding..."
	cp  -r "$WORKDIR" "$WORKDIR"_V2_2

	cp "$WORKDIR"/grammars/testcommonother_V2_2.json "$WORKDIR"_V2_2/grammars/
	NUM_GRAMS="${#GRAMMARS[@]}"
	GRAMMARS[$((NUM_GRAMS+1))]="V2_2"
}


copy_gramtestprob() {
	rm -r "$WORKDIR"_testprob
	cp  -r "$WORKDIR" "$WORKDIR"_testprob

	cp "$WORKDIR"/grammars/testcommonother_testprob.json "$WORKDIR"_testprob/grammars/
	NUM_GRAMS="${#GRAMMARS[@]}"
	GRAMMARS[$((NUM_GRAMS+1))]="testprob"
}


# compile
compile_gram() {
	echo "Compiling grammar files..."
	for gram in "${GRAMMARS[@]}"; do
		echo "Compiling ""$gram""..."
		cd "$WORKDIR"_"$gram"
		make clean
		cp ../Grammar-Mutator-stable/third_party/antlr4-cpp-runtime/antlr4-cpp-runtime-4.8-source.zip third_party/antlr4-cpp-runtime/
		make GRAMMAR_FILE=grammars/testcommonother_"$gram".json
	done
}



# copy binary files in working folder
copy_bin() {
	echo "Copying binary files..."
	for gram in "${GRAMMARS[@]}"; do
		mkdir "$INITIAL_DIR"/"$gram" || echo "Proceeding..." 
		cp "$WORKDIR"_"$gram"/libgrammarmutator*.so "$INITIAL_DIR"/"$gram"/
		cp "$WORKDIR"_"$gram"/grammar_generator* "$INITIAL_DIR"/"$gram"/
	done
}


end() {
	cd "$INITIAL_DIR"
	echo "Done."
}



# Program

INITIAL_DIR="$(pwd)"

clean
gen_gram
copy_gram
copy_gram2
copy_gramV2
copy_gramV2_2
#copy_gramtestprob
compile_gram
copy_bin
end
