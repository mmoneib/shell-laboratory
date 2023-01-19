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
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

#TODO Add ignore case to all suitable actions.
#TODO Update README to reflect preference to internal calls.
#TODO Add action to roll circularly for a given list (regex) of acceptable values.

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

## Counts the number of timnes a specified single character appears in the supplied text. The search cab be flagged as case-insensitive.
function count_char_occurrences {
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
  [ -z "$p_o_character" ] && __print_missing_parameter_error "character"
  [ -z "$p_o_ignoreCase" ] && p_o_ignoreCase="false"
  cCount=0;
  if [ "$p_o_ignoreCase" == "true" ]; then
    p_o_character="$(echo $p_o_character|tr [:lower:] [:upper:])"
    p_r_text="$(echo $p_r_text|tr [:lower:] [:upper:])"
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

## Flips the case of each character in the supplied text.
function flip_case {
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
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
  done <<< "$p_r_text"
  printf "$flippedCaseText";
}

## Keep the first and last letters only in each word of the supplied text.
function remove_internal_chars {
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
  printf "$p_r_text\n" | tr '\n' '\r' | sed "s/\([a-Z]\)[a-Z]*\([a-Z][^a-Z]\)/\1\2/g"|tr '\r' '\n' # The command tr is used as a workaround since sed doesn't consider \n outside [a-z].
}

## Replaces each encountered placeholder {} with the field whose turn comes in the supplied separated list. The number of placeholders should be the same as the number of fields in the list.
function remove_text { 
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
  [ -z "$p_o_separatedListText" ] && __print_missing_parameter_error "separated_list_text"
  p_o_dictionary=""
  p_o_dictionary="$(printf "$p_o_separatedListText"|sed "s/\([^;]\)$/\1;/g"|sed "s/;/=;/g")"
  replace_text_by_dictionary
}

## Replaces each encountered placeholder {} with the field whose turn comes in the supplied separated list. The number of placeholders should be the same as the number of fields in the list.
function replace_positional_placeholders { 
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
  [ -z "$p_o_separatedListText" ] && __print_missing_parameter_error "separated_list_text"
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
        outputText+="$(echo "$p_o_separatedListText"|cut -d ";" -f $pos)"
      else
        outputText+="$c"
      fi
      buffer=""
    done
    outputText+="\n"
  done <<< "$p_r_text"
  printf "$outputText" # Using printf to have the same exact output as input in terms of formatting. The command 'echo' produces an extra line at the end.
}

## Replaces each encountered text entry from the dictionaty with its corresponding text there.
function replace_text_by_dictionary { 
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
  [ -z "$p_o_dictionary" ] && __print_missing_parameter_error "dictionary"
  outputText="$p_r_text"
  recordPos=1
  while [ ! -z "$(echo "$p_o_dictionary"|cut -d ";" -f $recordPos)" ]; do
    field=$(echo "$p_o_dictionary"|cut -d ';' -f $recordPos)
    key="$(echo "$field"|cut -d '=' -f 1)"
    value="$(echo "$field"|cut -d '=' -f 2)"
    outputText="$(echo "$outputText"|sed "s/^key/$value/g"|sed "s/ \?$key/$value/g")" # ? is used to indicate pre-word space as optional. First sed is to cover the case when the key is the first thing in the text without space before it.
    recordPos=$((recordPos+1))
  done
  outputText+="\n"
  printf "$outputText" # Using printf to have the same exact output as input in terms of formatting. The command 'echo' produces an extra line at the end.
}

## Roll the characters of a string based on their numerical (decimal) value and the offset provided.
function roll_chars_by_offset {
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
  [ -z "$p_o_offset" ] && __print_missing_parameter_error "offset"
  outputText=""
  for ((p=0;p<${#p_r_text};p++)); do 
    c="${p_r_text:$p:1}"
    p_o_character="$c" # Preparing for internal call to another action.
    val="$(show_decimal_of_char $c)"
    newVal="$(($val+$p_o_offset))"
    newChar="$($0 -a show_char_of_decimal -c "$newVal")" # Called externally due to null bytes by printf output being not allowed in command substitution $(). Expensive. #TODO Use read or truncate null bytes.
    outputText+="$newChar"
  done
  printf "$outputText\n"
}

## Shows the char value of the character supplied as a decimal number.
function show_char_of_decimal {
  [ -z "$p_o_character" ] && __print_missing_parameter_error "character"
  printf "\\$(printf %o $p_o_character)\n" # Convert the decimal to octal and then print the char (by \\) of the octal.
}

## Shows the decimal value of the supplied character.
function show_decimal_of_char {
  [ -z "$p_o_character" ] && __print_missing_parameter_error "character"
  printf "%d\n" "'$p_o_character"
}

## Shows the positions (starting from 1) of the supplied single character in the supplied text. If multiple occurrences, the positions are separated by commas. The search can be flagged as case-insensitive.
function show_positions_of_char {
  [ -z "$p_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
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

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  p_r_text="$inp"
  while read inp; do
    p_r_text+="\n$inp"
  done 
fi
# Parse options and parameters.
while getopts "ha:c:d:il:o:t:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ## The character to be queried or manipulated. The size must be of a single character.
    c) p_o_character=$OPTARG ;;
    ## A list of keys and values that resembles to a dictionary. The record separator defaults to semi-colon, while the key/value separator is '='.
    d) p_o_dictionary="$OPTARG" ;;
    ## A flag to become case-insensitive while querying. If the option is present, the flag is true; otherwise, false.
    i) p_o_ignoreCase="true" ;;
    ## A string in the form of a list separated by the serparator, which defaults to ai semi-colon.
    l) p_o_separatedListText=$OPTARG ;;
    ## Offset number indicating the distance between two elements in the string.
    o) p_o_offset=$OPTARG ;;
     #  [ "$OPTARG" -eq "$(echo $OPTARG | grep "^[0-9]*$")" ] || echo "ERROR: Incorrect parameter value for o." ;;
    ## The text to be queried or manipulated. This can be a string specified via command line, or a path to a text file.
    t) p_r_text="$OPTARG" ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done

# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ]  && $p_r_action || __print_incorrect_action_error
