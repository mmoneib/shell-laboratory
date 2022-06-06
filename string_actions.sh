#!/bin/bash
################################################################################
# String Utilities                                                             #
#                                                                              #
# Description: A collection of utility fanctions to analyze and manipulate     #
# strings.                                                                     #    
#                                                                              #
# Type: Actions                                               .                #
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
  [ -z "$p_r_text" ] && p_r_text="$1"
  [ -z "$p_o_character" ] && p_o_character="$2"
  [ -z "$p_o_ignoreCase" ] && p_o_ignoreCase="$3"
  cPosition=0;
  if [[ $__string_utilities__ignore_case && $__string_utilities__ignore_case -eq "-i" ]]; then
    # String manipulation requires ${}. The ^^ operator is to make a string upper case.
    p_o_character=${p_o_character^^};
    p_r_text=${p_r_text^^};
  fi
  # Using # inside ${} to get the size of the string.
  for (( i=0;i<${#p_r_text};i++ )); do 
    # Using $ to compare strings, as comparison of values when provide the correct equality.
    if [[ "${p_r_text:i:1}" == "$p_o_character" ]]; then 
      ((cPosition=cPosition+1))
    fi 
  done
  echo $cPosition;
}

function flip_case_of_string {
  p_r_text=$__string_utilities__1;
  if [[ -z $str ]]; then
    read p_r_text;
  fi
  p_r_text2="";
  # Using # inside ${} to get the size of the string.
  for ((__string_utilities__i=0; __string_utilities__i<${#p_r_text}; __string_utilities__i++)); do 
    # Using $ to compare strings, as comparison of values when provide the correct equality.
    c=${p_r_text:__string_utilities__i:1};
    if [[ "$__string_utilities__c" == "${__string_utilities__c^^}" ]]; then 
      p_r_text2=${p_r_text2}${__string_utilities__c,,};
    else
      p_r_text2=${p_r_text2}${__string_utilities__c^^};
    fi 
  done
  # printf seems to have a problem with spaces.
  echo $p_r_text2;
}

function show_position_of_char_in_string {
  p_r_text=$1;
  p_o_character=$2
  __string_utilities__ignore_case=$3
  __string_utilities__a=();
  __string_utilities__c=0;
  if [[ $__string_utilities__ignore_case && $__string_utilities__ignore_case -eq "-i" ]]; then
    # String manipulation requires ${}. The ^^ operator is to make a string upper case.
    p_o_character=${p_o_character^^};
    p_r_text=${p_r_text^^};
  fi
  # Using # inside ${} to get the size of the string.
  for ((i=0; i<${#p_r_text}; i++)); do 
    if [[ "${p_r_text:i:1}" == "$p_o_character" ]]; then 
      __string_utilities__a[__string_utilities__c]=$i;
      ((__string_utilities__c++));
    fi 
  done
  echo "${__string_utilities__a[@]}";
}

function replace_placeholders_in_string {
  [ -z "$p_r_text" ] && p_r_text="$1"
  prefix_placeholder='{'
  postfix_placeholder='}'
  shift
  pos=0
  while [ ! =z $1 ]; do
    ((pos++))
    __string_utilities__placeholder=$prefix_placeholder$pos$postfix_placeholder
     p_r_text=$(echo p_r_text|sed "s/$__string_utilities__placeholder/$1/g")
  done 
}

if [ "$1" != "skip_run" ]; then
  if [ -z $1 ]; then
    read -t 0.1 inp;
    [ -z $inp ] && print_usage
  fi
  while getopts "ha:c:t:i" o; do
    case $o in
      a) p_r_action=$OPTARG ;;
      c) p_o_character=$OPTARG ;;
      i) p_o_ignoreCase="-i" ;; # To send it as is to the functions.
      t) p_r_text=$OPTARG ;;
      h) print_help ;;
      *) print_usage ;;
    esac
  done
  # Generic action call with positional parameters based on available ones.
  $p_r_action $p_r_text $p_o_character $p_o_ignoreCase
fi
