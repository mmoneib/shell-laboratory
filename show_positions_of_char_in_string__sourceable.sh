#!/bin/bash
################################################################################
# Show Position of Chars in String                                             #
#                                                                              #
# Description: Does as it says.                                                #
#                                                                              #
# Type: To be used as a standalone or sourced by other scripts.                #
# Dependencies: Bash                                                           #
# Developed by: Muhammad Moneib                                                #
################################################################################

str=$1;
car=$2
a=();
c=0;
if [[ $3 && $3 -eq "-i" ]]; then
  # String manipulation requires ${}. The ^^ operator is to make a string upper case.
  car=${car^^};
  str=${str^^};
fi
# Using # inside ${} to get the size of the string.
for ((i=0; i<${#str}; i++)); do 
  if [[ "${str:i:1}" == "$car" ]]; then 
    a[c]=$i;
    ((c++));
  fi 
done
echo "${a[@]}";
