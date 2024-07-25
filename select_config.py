#!/usr/bin/python3


#==========================================================================
#
#  FILE:
#	select_config.py
#	
#  DESCRIPTION:
# 	Select generator configuration	
#
#  USAGE:
# 	python3 select_config.py <CONF_CODE>
#	
#	<CONF_CODE> has the following format: #.<n>, where <n> is an integer number
#
#==========================================================================



#### Program code ####

import sys

USER="your_username"
WORKDIR="/home/"+USER+"/Downloads/Grammar-Mutator-stable/to_keep/common/"
FILENAME="script6.sh"
DEFAULT_CNF="#.1"

def reset_all(filename):
    ''' Reset options to their default values '''
    

    with open(filename, 'r+') as infile:
        lines=infile.readlines()
        infile.seek(0)
        infile.truncate()

        options=["#."+str(n) for n in range(0,10)]

        for line in lines:
            for option in options:
                if line.strip().endswith(option):
                    # remove option (including starting white space)
                    index=line.find(option)
                    for i in range(-1,len(option)):
                        lline=str_to_list(line)
                        lline[index+i]=" "
                        line=list_to_str(lline)

                    # add option to the beginning
                    for i in range(0,len(option)):
                        lline=str_to_list(line)
                        lline[i]=option[i]
                        line=list_to_str(lline)

            infile.write(line)
        




def write_option(filename,option):
    ''' Write option to file '''

    with open(filename, 'r+') as infile:
        lines=infile.readlines()
        infile.seek(0)
        infile.truncate()


        for line in lines:
            if line.strip().startswith(option):

                # remove option
                index=line.find(option)
                for i in range(0,len(option)):
                    lline=str_to_list(line)
                    lline[index+i]=" "
                    line=list_to_str(lline)

                # add option to the end
                line = line[:len(line)-1].rstrip() + " " + option + "\n"

            infile.write(line)


def list_to_str(l):
    ''' Convert string to list '''
    return ''.join(l)

def str_to_list(str_):
    ''' Convert list to string '''
    return list(str_)


def main():

    # write options to file
    filename=WORKDIR + FILENAME

    if len(sys.argv)>1 and sys.argv[1]=="reset":

        # reset default values
        reset_all(filename)
        write_option(filename,DEFAULT_CNF)

    elif len(sys.argv)>1:
        reset_all(filename)
        write_option(filename,sys.argv[1])
    
    else:
        print("Usage:\n")
        print("select_config.py <CONFIG_NUM>\n\n")

main()
