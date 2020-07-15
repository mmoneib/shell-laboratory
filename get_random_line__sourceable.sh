#!/bin/bash
################################################################################
# Get a Random Lne.                                                            #
#                                                                              #
# Description: Does as the title says.                                         #
#                                                                              #
# Type: To be used as a standalone or sourced by other scripts.                #
# Dependencies: Bash                                                           #
# Developed by: Muhammad Moneib                                                #
################################################################################

f=$1;
if [[ -z $f ]]; then
  #To deal with piped input like from a cat operation.
  while read inp; do
    if [[ -z $f ]]; then
      f="$inp";
    else
      f="$f\n$inp";
    fi
    c=$(($c+1));
    temp_file=$(mktemp);
    #Remove the temp file on exit.
    trap "rm -f $temp_file" EXIT;
  done
  #Apply \n and put the resulting lines in the temp file.
  $((echo -e $f)>$temp_file);
  f=$temp_file;
else
  c=$((cat $f)|(wc -l));
fi
n=$(($RANDOM%$c+1)); # $(()) for evaluating mathematical operations.
str=$((head -$n $f)|(tail -1)); # $() for evaluating command with spaces.
echo $str;
