#!/bin/sh
################################################################################
# String Utilities                                                             #
#                                                                              #
# A collection of fanctions to analyze and manipulate strings.                 #    
#                                                                              #
# Type: Actions                                               .                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the c_r_ prefix.
# Optional parameters are denoted with the c_o_ prefix.

function __print_usage {
  sh $(dirname $0)/help__actions.sh -a print_actions_usage_exiting -t $0
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_actions_help -t $0
}

function __print_missing_parameter_error {
  echo "Validation Error: Missing the '$1' parameter required for this action.">&2
  exit 1
}

function __print_incorrect_action_error {
  echo "Validation Error: The provided action is not available. Please check Help for more info..">&2
  exit 1
}

# Counts the number of timnes a specified single character appears in the supplied text. The search cab be flagged as case-insensitive.
function count_char_occurrences {
  [ -z "$c_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$c_r_text" ] && c_r_text="$(cat $c_r_text)"
  [ -z "$c_o_character" ] && __print_missing_parameter_error "character"
  [ -z "$c_o_ignoreCase" ] && c_o_ignoreCase="false"
  cCount=0;
  if [ "$c_o_ignoreCase" == "true" ]; then
    # String manipulation requires ${}. The ^^ operator is to make a string upper case.
    c_o_character="${c_o_character^^}";
    c_r_text="$(echo $c_o_character|tr [:lower:] [:upper:])";
  fi
  # Using # inside ${} to get the size of the string.
  for (( i=0;i<${#c_r_text};i++ )); do
    # Using $ to compare strings, as comparison of values when provide the correct equality.
    if [[ "${c_r_text:i:1}" == "$c_o_character" ]]; then 
      ((cCount=cCount+1))
    fi 
  done
  echo $cCount;
}

## Flips the case of eachn character in the supplied text.
function flip_case {
  [ -z "$c_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$c_r_text" ] && c_r_text="$(cat $c_r_text)"
  flippedCaseText="";
  # Using # inside ${} to get the size of the string.
  IFS=""; while read l; do # IFS needed to preserve leading spaces.
    for (( i=0;i<${#l};i++)); do # Reading per line in order to be able to detect newlines.
      # Using $ to compare strings, as comparison of values when provide the correct equality.
      c="${l:i:1}"
      flippedC="$(echo "$c"|sed "s/\(.\)/\U\1/g")"
      if [[ "$c" == "$flippedC" ]]; then
        flippedCaseText="$flippedCaseText$(echo "$flippedC"|sed "s/\(.\)/\L\1/g")"
      else
        flippedCaseText+="$flippedC"
      fi 
    done
    flippedCaseText+="\n"
  done <<< "$c_r_text"
  printf "$flippedCaseText";
}

## Shows the positions (starting from 1) of the supplied single character in the supplied text. If multiple occurrences, the positions are separated by commas. The search can be flagged as case-insensitive.
function show_positions_of_char {
  [ -z "$c_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$c_r_text" ] && c_r_text="$(cat $c_r_text)"
  [ -z "$c_o_character" ] && __print_missing_parameter_error "character"
  [ -z "$c_o_ignoreCase" ] && c_o_ignoreCase="false"
  if [ "$c_o_ignoreCase" == "true" ]; then
    c_o_character="$(echo "$c_o_character"|sed "s/\(.\)/\U\1/g")"
    c_r_text="$(echo "$c_r_text"|sed "s/\(.\)/\U\1/g")"
  fi
  posText=""
  # Using # inside ${} to get the size of the string.
  for ((i=0; i<${#c_r_text}; i++)); do 
    if [[ "${c_r_text:i:1}" == "$c_o_character" ]]; then 
      posText+="$((i+1)),"
    fi 
  done
  [ ${#posText} -eq 0 ] && posText="," # To avoid errors while removing the last comma in case of no positions.
  echo "${posText:0:$((${#posText}-1))}"
}

## Rpplaces each encountered placeholder with the field whose turn comes in the supplied separated list. The number of placeholders should be the same as the number of fields in the list.
function replace_positional_placeholders { 
  [ -z "$c_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$c_r_text" ] && c_r_text="$(cat $c_r_text)"
  [ -z "$c_o_separatedListText" ] && __print_missing_parameter_error "separated_list_text"
  prefix_placeholder='{'
  postfix_placeholder='}'
  outputText=""
  buffer=""
  pos=0
  IFS=""; while read l; do # IFS needed to preserve leading spaces.
    for (( i=0;i<${#l};i++)); do # Reading per line in order to be able to detect newlines.
      c="${l:i:1}"
      if [ "$prefix_placeholder" == "$c" ]; then
        buffer="{"
        continue
      elif [ "$postfix_placeholder" == "$c" ] && [ "$buffer" == "$prefix_placeholder" ]; then
        pos=$((pos+1))
        outputText+="$(echo "$c_o_separatedListText"|cut -d ";" -f $pos)"
      else
        outputText+="$c"
      fi
      buffer=""
    done
    outputText+="\n"
  done <<< "$c_r_text"
  printf "$outputText" # Using printf to have the same exact output as input in terms of formatting. The command 'echo' produces an extra line at the end.
}

## Replaces each encountered placeholder with the field whose turn comes in the supplied separated list. The number of placeholders should be the same as the number of fields in the list.
function replace_text_by_dictionary { 
  [ -z "$c_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$c_r_text" ] && c_r_text="$(cat $c_r_text)"
  [ -z "$c_o_dictionary" ] && __print_missing_parameter_error "dictionary"
  outputText="$c_r_text"
  recordPos=1
  while [ ! -z "$(echo "$c_o_dictionary"|cut -d ";" -f $recordPos)" ]; do
    field=$(echo "$c_o_dictionary"|cut -d ';' -f $recordPos)
    key="$(echo "$field"|cut -d '=' -f 1)"
    value="$(echo "$field"|cut -d '=' -f 2)"
    outputText="$(echo "$outputText"|sed "s/$key/$value/g")"
    recordPos=$((recordPos+1))
 done
  printf "$outputText" # Using printf to have the same exact output as input in terms of formatting. The command 'echo' produces an extra line at the end.
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  c_r_text="$inp"
  while read inp; do
    c_r_text+="'\n$inp"
  done 
fi
# Parse options and parameters.
while getopts "ha:c:t:l:d:i" o; do
  case $o in
    ## The name of the function to be triggered.
    a) c_r_action=$OPTARG ;;
    ## The character to be queried or manipulated. The size must be of a single character.
    c) c_o_character=$OPTARG ;;
    ## A list of keys and values that resembles to a dictionat. The record separator defaults to semi-colon, while the key/value separator is '='.
    d) c_o_dictionary="$OPTARG" ;;
    ## A flag to become case-insensitive while querying. If the option is present, the flag is true; otherwise, false.
    i) c_o_ignoreCase="true" ;;
    ## A string in the form of a list separated by the serparator, which defaults to ai semi-colon.
    l) c_o_separatedListText=$OPTARG ;;
    ## The text to be queried or manipulated. This can be a string specified via command line, or a path to a text file.
    t) c_r_text="$OPTARG" ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $c_r_action" $0)" ] && $c_r_action || __print_incorrect_action_error
