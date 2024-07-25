#!/usr/bin/python3

#==========================================================================
#
#  FILE:
#	replace_candidate.py	
#	
#  DESCRIPTION:
# 	Used by min_file.sh to minimize test case
#
#  USAGE:
#
# 	./replace_candidate.py <filename> <seed> <strategy>
#
#	Supported strategies:
#		delete (default), 
#		keep, 
#		deleteonly: exclusively delete the pair (<initial>,<final>) of tokens
#
#==========================================================================



# Source of inspiration (for stack-based implementation): christian, scipython3.com

import re
import sys
import random
import hashlib



def print_usage(): 
    
    print("\nreplace_candidate.py <filename> <seed> <strategy>")
    print("\nSupported strategies:\ndelete (default), keep, deleteonly (esclusively delete the pair of tokens) ")
    print("\n")
    sys.exit(-1)
   



def replace_candidate(string_,seed,strategy="delete"):

    random.seed(seed)

    # Tokens are listed (and consequently replaced) in order of their predicted frequency in the code
    first_token_list=['custom_function\(\)', 'if \[[^\]]+\]; then', 'while \[', 'until \[', 'case', 'for [a-zA-Z0-9]+ in', ' { ' ]
    second_token_list=['custom_function  ;', '; fi ;', 'loop_exit=1; done', 'loop_exit=\"string\"; done', 'esac', '; done', '; } ']
    
    # List of replacement for each group of token. It can contain empty elements
    replacement_list=[': ;',': ;',':',':', ':',':',':']

    i=(int(int(seed)/1000))%len(first_token_list)

    p1=re.compile(first_token_list[i])
    p2=re.compile(second_token_list[i])

    stack=[]
    token_locs={}

    start1=-1
    start2=-1

    # For each couple <start,end> of tokens
    m1=p1.search(string_,start1)
    m2=p2.search(string_,start2)

    length=len(string_)
    while start1<length or start2<length:
        if m1 == None and m2 == None:
            break

        # one of the following conditions must be necessarily satisfied
        if m1 == None:
            start1=length+1
            start2=m2.start()
        elif m2 == None:
            start2=length+1
            start1=m1.start()
        else:
            start1=m1.start()
            start2=m2.start()


        # Debug
        # print("\n""start1:")
        # print(start1)
        # print("\n""start2:")
        # print(start2)
        # print("\n""stack:")
        # print(stack)
        # print("####################")
        # print(token_locs)
        # End debug

        # Main algorithm
        if start1 < start2:
            stack.append(start1)
            # update current match position
            m1=p1.search(string_,start1+1)

        else:
            try:
                # print("Removing top of the stack")
                beginning=stack.pop()
                token_locs[beginning]=start2
                # update current match position
                m2=p2.search(string_,start2+1)
            except IndexError:
                # Debug
                # print(token_locs)
                # print(start1)
                # End debug
                print ("Error: Unbalanced number of tokens")
                return 1


    # Debug
    # print(i)
    # print(first_token_list[i])
    # print(string_)
    # print(start1)
    # print(start2)
    # print("####################")
    # print(token_locs)
    # print(token_locs[sorted(token_locs)[int(seed)]])
    # End debug


    # delete (or keep) ith entry in the dictionary, depending on input seed
    num_entries=len(token_locs)
    if num_entries != 0:

        # Debug
        # Bug location:
        # remove_start=sorted(token_locs)[0]
        # remove_end=token_locs[sorted(token_locs)[0]] 
        # -> the index must be dynamic

        # Alternative
        # sorted_locs=sorted(token_locs)
        # remove_start=sorted_locs[0]
        # remove_end=token_locs[remove_start]

        # Other alternative (previous)
   	# remove_start=sorted(token_locs)[int(seed)%num_entries]
   	# remove_end=token_locs[sorted(token_locs)[int(seed)%num_entries]]

        # With hash(incomplete)
        # index= hashlib.md5(seed.encode('utf8').hexdigest(),16) %num_entries
        # remove_start=sorted(token_locs)[)]
        # remove_end=token_locs[sorted(token_locs)[random.randint(0,num_entries-1)]]

        # comment subsequent two lines
        # print(remove_start)
        # print(remove_end)

	# TD: improvement
        # for each element in the dict:
        #   find max(interval) 
        #   

        # End debug


        # delete ith entry in the dictionary, depending on input seed

	index=random.randint(0,num_entries-1)
        remove_start=sorted(token_locs)[index]
        remove_end=token_locs[sorted(token_locs)[index]]


        assert(remove_start != remove_end)
        assert(remove_start != None)
        assert(remove_end != None)
        assert(remove_start != "")
        assert(remove_end != "")
        assert((remove_start,remove_end) in token_locs.items())

        if strategy == "keep":
            out_string=string_[remove_start:remove_end+len(second_token_list[i])]
            # keep only the selected part
            print(out_string,end='')

        elif strategy == "deleteonly":
            # get first token position and length of match
            m=p1.search(string_,remove_start)
            out_string=string_[:remove_start]+string_[remove_start+len(m.group()):remove_end]+string_[remove_end+len(second_token_list[i]):]

            # Debug
            # out_string=string_[remove_start+len(m.group()):remove_end]
            # print(m.string)
            # End debug

            print(out_string,end='')
            
        else:
            # delete the selected part

            # Debug
            # print(remove_end+len(second_token_list[i]))
            # print(string_[:remove_start])
            # print(replacement_list[i])
            # End debug

            out_string=string_[:remove_start]+replacement_list[i]+string_[remove_end+len(second_token_list[i]):]
            print(out_string,end='')

            # Debug
            # print the removed token as a comment at the end of the program
            # print(string_[:remove_start]+replacement_list[i]+string_[remove_end+len(second_token_list[i]):]+" #"+string_[remove_start:remove_end],end='')
            # End debug

            assert(out_string != string_)
        return 0

    else:
        # Debug
        # print("# Minimized program")
        # print(" #" + str(token_locs))
        # End debug

        print(string_,end='')
        return 1



def main():
    if len(sys.argv) > 2:
        if sys.argv[1] != "":
            filename=sys.argv[1]

        if sys.argv[2] != "":
            seed=sys.argv[2]

    else:
        print("Error: invalid number of arguments")
        print_usage()

    if len(sys.argv) > 3 and sys.argv[3] != "":
        strategy=sys.argv[3]
    else:
        strategy="delete"

    with open(filename,'r') as fd:
        string_=fd.read()

        # Debug
        # print(string_)
        # print(seed)
        # print(filename)
        # return -1 # replace_candidate(string_,seed,strategy)
        # End debug

    ret=replace_candidate(string_,seed,strategy)
    sys.exit(ret)


main()

