#!/bin/sh
################################################################################
# Math Actions                                                                 #
#                                                                              #
# A set of functions to perform mathematical calculations on numbers.          #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     bc.                                                                      #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

function __print_usage {
  sh $(dirname $0)/help__actions.sh -a print_actions_usage -t $0
  exit
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_actions_help -t $0
  exit
}

function __print_missing_parameter_error {
  sh $(dirname $0)/help__actions.sh -a print_missing_parameter_error -p $1
  exit 1
}

function __print_incorrect_action_error {
  sh $(dirname $0)/help__actions.sh -a print_incorrect_action_error
  exit 1
}

## Calculate the average of the numbers provided in the separated list.
function average {
  [ -z "$p_o_separatedListText" ] && __print_missing_parameter_error "separated_list_text"
  IFS=","; read -a numArr <<< "$p_o_separatedListText"
  sum=0
  for num in ${numArr[@]}; do
    sum=$(echo "$sum+$num"|bc)
  done
  echo "scale=$p_o_scale;$sum/${#numArr[@]}"|bc
}

## Calculate the summation of the numbers provided in the separated list.
function sum {
  [ -z "$p_o_separatedListText" ] && __print_missing_parameter_error "separated_list_text"
  IFS=","; read -a numArr <<< "$p_o_separatedListText"
  sum=0
  for num in ${numArr[@]}; do
    sum=$(echo "$sum+$num"|bc)
  done
  echo "scale=$p_o_scale;$sum"|bc
}

## Prints an arithmetic sequece with the given step and up to the specifiec amount of digits.
function print_arithmetic_sequence {
  [ -z "$p_o_beginning" ] && __print_missing_parameter_error "beginning"
  [ -z "$p_o_count" ] && __print_missing_parameter_error "count"
  [ -z "$p_o_step" ] && __print_missing_parameter_error "step"
  [ -z "$p_o_separator" ] && p_o_separator="" 
 for (( d=$p_o_beginning; d<=$p_o_count; d=d+$p_o_step )); do
    printf "$d$p_o_separator"
  done
 if [ "$p_o_separator" != "\n" ]; then # In-line if causes the action validation error to be thrown for some reason.
  printf "\n"
 fi
}

## Prints a geometric sequece with the given step and up to the specifiec amount of digits. Having no separator will join the numbers.
function print_geometric_sequence {
  [ -z "$p_o_beginning" ] && __print_missing_parameter_error "beginning"
  [ -z "$p_o_count" ] && __print_missing_parameter_error "count"
  [ -z "$p_o_step" ] && __print_missing_parameter_error "step"
  [ -z "$p_o_separator" ] && p_o_separator=""
  for (( d=$p_o_beginning; d<=$p_o_count; d=d*$p_o_step )); do
    printf "$d$p_o_separator"
  done
  if [ "$p_o_separator" != "\n" ]; then
    printf "\n"
  fi
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  ~input text parameter here~="$inp"
  while read inp; do
     ~input text parameter here~+="\n$inp"
  done
fi
p_o_scale=2
# Parse options and parameters.
while getopts "ha:b:c:l:s:S:r:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ## The beginning digit of a sequenc.
    b) p_o_beginning=$OPTARG ;;
    ## The count of a sequence.
    c) p_o_count=$OPTARG ;;
    ## List of numbers separated by a comma.
    l) p_o_separatedListText=$OPTARG ;;
    ## Scale, like number of digits after the decimal point.
    s) p_o_scale=$OPTARG ;;
    ## Step for a sequence.
    S) p_o_step=$OPTARG ;;
    ## A separator to separate the members of a sequence.
    r) p_o_separator=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && __print_incorrect_action_error
# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
