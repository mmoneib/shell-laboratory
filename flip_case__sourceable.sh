#!/bin/bash
str=$1;
if [[ -z $str ]]; then
  read str;
fi
str2="";
# Using # inside ${} to get the size of the string.
for ((i=0; i<${#str}; i++)); do 
  # Using $ to compare strings, as comparison of values when provide the correct equality.
  c=${str:i:1};
  if [[ "$c" == "${c^^}" ]]; then 
    str2=${str2}${c,,};
  else
    str2=${str2}${c^^};
  fi 
done
# printf seems to have a problem with spaces.
echo $str2;
