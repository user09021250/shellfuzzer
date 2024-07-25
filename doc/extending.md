# Extending the program 


## =========== How to add a new shell ====================

* Replace the  PATH variable in the program with the path of the compiled shell binary


## =========== How to add a new grammar ====================


* Implement the new grammar in a file .json
* Add a function copy_gram<GRAMMAR_NAME>()
* Add a new testing phase employing the grammar
* Compile the grammar
* Execute the program


## =========== How to add a new (external) program generator ===================


* Create a folder in the work directory
* Add the binary of the program generator to the previous folder
* Update the program paths in the source to point to the new generator


