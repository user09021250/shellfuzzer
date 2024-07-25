#!/usr/bin/python3

#==========================================================================
#
#  FILE:
#	count_lines.py
#	
#  DESCRIPTION:
#	Count the total number of lines for each generated program during the test and compute the average
#
#  USAGE:
#  	./count_lines.py
# 	
# 	
#==========================================================================


import glob

count=0
sum_=0

#file_list=glob.glob("/home/your_username/Downloads/Grammar-Mutator-stable/to_keep/common/baks/prev_bugs/other/other_server.img_server_test_only7*/curr_bugs*/put_sizes.txt")
file_list=glob.glob("/home/your_username/Downloads/Grammar-Mutator-stable/to_keep/common/baks/prev_bugs/other/individual_gen/other_server.img_server_test_only7*/curr_bugs*/put_sizes.txt")

#print(file_list)

for filename in file_list:
    count=0
    sum_=0
    with open(filename) as fd:
        for line in fd:
            sum_=sum_+int(line.split()[2])+1
            count=count+1
    print(filename)
    print("Avg: " + str(sum_/count))
    print("Total: " + str(count) + "\n\n\n")
    

# each gen
print("For each gen: ")

for filelist in [glob.glob("/home/your_username/Downloads/Grammar-Mutator-stable/to_keep/common/baks/prev_bugs/other/individual_gen/other_server.img_server_test_only7_v/curr_bugs*/put_sizes.txt"),glob.glob("/home/your_username/Downloads/Grammar-Mutator-stable/to_keep/common/baks/prev_bugs/other/individual_gen/other_server.img_server_test_only7_i/curr_bugs*/put_sizes.txt"),glob.glob("/home/your_username/Downloads/Grammar-Mutator-stable/to_keep/common/baks/prev_bugs/other/individual_gen/other_server.img_server_test_only7_ni/curr_bugs*/put_sizes.txt")]:
    count=0
    sum_=0
    print(filelist)
    for filename in filelist:
        print(filename)
        with open(filename) as fd:
                      for line in fd:
                        sum_=sum_+int(line.split()[2])+1
                        count=count+1
    print("Avg: " + str(sum_/count))
    print("Total: " + str(count) + "\n\n\n")
