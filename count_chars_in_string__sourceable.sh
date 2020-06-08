#!/bin/bash
str=$1;
car=$2
c=0;
if [[ $3 && $3 -eq "-i" ]]; then
  # String manipulation requires ${}. The ^^ operator is to make a string upper case.
  car=${car^^};
  str=${str^^};
fi
# Using # inside ${} to get the size of the string.
for ((i=0; i<${#str}; i++)); do 
  # Using $ to compare strings, as comparison of values when provide the correct equality.
  if [[ "${str:i:1}" == "$car" ]]; then 
    ((c=c+1))
  fi 
done
printf $c\\n;
