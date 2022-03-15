#!/bin/bash
################################################################################
# String Utilities                                                             #
#                                                                              #
# Description: A collection of utility fanctions to analyze and manipulate     #
# strings.                                                                     #    
#                                                                              #
# Type: To be used as a standalone or sourced by other scripts.                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

function usage() {
  echo "Usage: string_utilities__sourceable.sh -a action_here [-t text_here [-c character_here] [-r comma_separated_list_here]] [-i]
        Available actions:
          count_char_occurrences_in_string (needs t option and argument)
          flip_case_of_string (needs t option and argument)
          show_position_of_char_in_string (needs t and c options and arguments)
          replace_placeholders_in_string (needs t option and argument)"
  exit 1
}

function count_char_occurrences_in_string {
  __string_utilities__str=$1;
  __string_utilities__car=$2
  __string_utilities__ignore_case=$3
  __string_utilities__c=0;
  if [[ $__string_utilities__ignore_case && $__string_utilities__ignore_case -eq "-i" ]]; then
    # String manipulation requires ${}. The ^^ operator is to make a string upper case.
    __string_utilities__car=${__string_utilities__car^^};
    __string_utilities__str=${__string_utilities__str^^};
  fi
  # Using # inside ${} to get the size of the string.
  for ((__string_utilities__i=0; __string_utilities__i<${#__string_utilities__str}; __string_utilities__i++)); do 
    # Using $ to compare strings, as comparison of values when provide the correct equality.
    if [[ "${__string_utilities__str:__string_utilities__i:1}" == "$__string_utilities__car" ]]; then 
      ((__string_utilities__c=__string_utilities__c+1))
    fi 
  done
  printf $__string_utilities__c\\n;
}

function flip_case_of_string {
  __string_utilities__str=$__string_utilities__1;
  if [[ -z $str ]]; then
    read __string_utilities__str;
  fi
  __string_utilities__str2="";
  # Using # inside ${} to get the size of the string.
  for ((__string_utilities__i=0; __string_utilities__i<${#__string_utilities__str}; __string_utilities__i++)); do 
    # Using $ to compare strings, as comparison of values when provide the correct equality.
    c=${__string_utilities__str:__string_utilities__i:1};
    if [[ "$__string_utilities__c" == "${__string_utilities__c^^}" ]]; then 
      __string_utilities__str2=${__string_utilities__str2}${__string_utilities__c,,};
    else
      __string_utilities__str2=${__string_utilities__str2}${__string_utilities__c^^};
    fi 
  done
  # printf seems to have a problem with spaces.
  echo $__string_utilities__str2;
}

function show_position_of_char_in_string {
  __string_utilities__str=$1;
  __string_utilities__car=$2
  __string_utilities__ignore_case=$3
  __string_utilities__a=();
  __string_utilities__c=0;
  if [[ $__string_utilities__ignore_case && $__string_utilities__ignore_case -eq "-i" ]]; then
    # String manipulation requires ${}. The ^^ operator is to make a string upper case.
    __string_utilities__car=${__string_utilities__car^^};
    __string_utilities__str=${__string_utilities__str^^};
  fi
  # Using # inside ${} to get the size of the string.
  for ((i=0; i<${#__string_utilities__str}; i++)); do 
    if [[ "${__string_utilities__str:i:1}" == "$__string_utilities__car" ]]; then 
      __string_utilities__a[__string_utilities__c]=$i;
      ((__string_utilities__c++));
    fi 
  done
  echo "${__string_utilities__a[@]}";
}

function replace_placeholders_in_string {
  __string_utilities__str=$1;
  __string_utilities__prefix_placeholder='{'
  __string_utilities__postfix_placeholder='}'
  shift
  __string_utilities__pos=0
  while [ ! =z $1 ]; do
    ((__string_utilities__pos++))
    __string_utilities__placeholder=$__string_utilities__prefix_placeholder$__string_utilities__pos$__string_utilities__postfix_placeholder
     __string_utilities__str=$(echo __string_utilities__str|sed "s/$__string_utilities__placeholder/$1/g")
  done 
}

__string_utilities__par=$1
if [ -z $1 ] || [ "${__string_utilities__par:0:1}" != "-" ] || (( ${#__string_utilities__par} < 2 )); then
  usage
fi

while getopts "a:c:t:i" o; do
  case $o in
    a) __string_utilities__a_arg=$OPTARG ;;
    c) __string_utilities__c_arg=$OPTARG ;;
    i) __string_utilities__i_arg="-i" ;; # To send it as is to the functions.
    t) __string_utilities__t_arg=$OPTARG ;;
    r) __string_utilities__l_arg=$OPTARG ;;
    ?) usage ;;
  esac
done

$__string_utilities__a_arg $__string_utilities__t_arg $__string_utilities__c_arg $__string_utilities__i_arg
