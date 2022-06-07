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

function __print_usage {
  sh $(dirname $0)/help_actions.sh -a print_actions_usage_exiting -t $0
}

function __print_help {
  sh $(dirname $0)/help_actions.sh -a print_actions_help -t $0
}

function __print_missing_parameter_error {
  echo "Validation Error: Missing the '$1' parameter required for this action.">&2
  exit 1
}

function count_char_occurrences {
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -z "$p_o_character" ] && __print_missing_parameter_error "character"
  [ -z "$p_o_ignoreCase" ] && p_o_ignoreCase="false"
  cCount=0;
  if [ "$p_o_ignoreCase" == "true" ]; then
    # String manipulation requires ${}. The ^^ operator is to make a string upper case.
    p_o_character="${p_o_character^^}";
    p_r_text="$(echo $p_o_character|tr [:lower:] [:upper:])";
  fi
  # Using # inside ${} to get the size of the string.
  for (( i=0;i<${#p_r_text};i++ )); do
    # Using $ to compare strings, as comparison of values when provide the correct equality.
    if [[ "${p_r_text:i:1}" == "$p_o_character" ]]; then 
      ((cCount=cCount+1))
    fi 
  done
  echo $cCount;
}

function flip_case {
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  flippedCaseText="";
  # Using # inside ${} to get the size of the string.
  for (( i=0;i<${#p_r_text};i++)); do 
    # Using $ to compare strings, as comparison of values when provide the correct equality.
    c="${p_r_text:i:1}"
    flippedC="$(echo "$c"|sed "s/\(.\)/\U\1/g")"
    if [[ "$c" == "$flippedC" ]]; then 
      flippedCaseText="$flippedCaseText$(echo "$flippedC"|sed "s/\(.\)/\L\1/g")"
    else
      flippedCaseText+="$flippedC"
    fi 
  done
  # printf seems to have a problem with spaces.
  echo "$flippedCaseText";
}

function show_positions_of_char {
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -z "$p_o_character" ] && __print_missing_parameter_error "character"
  [ -z "$p_o_ignoreCase" ] && p_o_ignoreCase="false"
  if [ "$p_o_ignoreCase" == "true" ]; then
    p_o_character="$(echo "$p_o_character"|sed "s/\(.\)/\U\1/g")"
    p_r_text="$(echo "$p_r_text"|sed "s/\(.\)/\U\1/g")"
  fi
  posText=""
  # Using # inside ${} to get the size of the string.
  for ((i=0; i<${#p_r_text}; i++)); do 
    if [[ "${p_r_text:i:1}" == "$p_o_character" ]]; then 
      posText+="$((i+1)),"
    fi 
  done
  [ ${#posText} -eq 0 ] && posText="," # To avoid errors while removing the last comma in case of no positions.
  echo "${posText:0:$((${#posText}-1))}"
}

function replace_positional_placeholders { 
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -z "$p_o_separatedListText" ] && __print_missing_parameter_error "separated_list_text"
  prefix_placeholder='{'
  postfix_placeholder='}'
  outputText=""
  buffer=""
  pos=0
  while read -N 1 inp; do # SHould be 'read -k' in ZSH.
    if [ "$prefix_placeholder" == "$inp" ]; then
       buffer="{"
       continue
    elif [ "$postfix_placeholder" == "$inp" ] && [ "$buffer" == "$prefix_placeholder" ]; then
      pos=$((pos+1))
      outputText+="$(echo "$p_o_separatedListText"|cut -d "," -f $pos)"
    else
      outputText+="$inp"
    fi
    buffer=""
  done <<< "$p_r_text"
  printf "$outputText" # Using printf to have the same exact output as input in terms of formatting. The command 'echo' produces an extra line at the end.
}

if [ -z $1 ]; then
  read -t 0.1 inp;
  [ -z $inp ] && __print_usage
fi
while getopts "ha:c:t:l:i" o; do
  case $o in
    a) p_r_action=$OPTARG ;;
    c) p_o_character=$OPTARG ;;
    i) p_o_ignoreCase="true" ;;
    l) p_o_separatedListText=$OPTARG ;;
    t) p_r_text=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
# Generic action call with positional parameters based on available ones.
$p_r_action
