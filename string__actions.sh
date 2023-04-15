#!/bin/sh
################################################################################
# String Actions                                                               #
#                                                                              #
# A set of fanctions to analyze and manipulate strings.                        #    
#                                                                              #
# Type: Actions                                               .                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

#TODO Add ignore case to all suitable actions.
#TODO Add action for alternating caps.
#TODO Update README to reflect preference to internal calls.
#TODO Add documentation of preference of multiple calls at runtime than increased complexity.
#TODO Add calculated replacement of chars from list.
#TODO Add documentation that a basic functionm must be accessible before creating convenient functions.
#TODO Add action to modify indentations with tabs and spaces.
#TODO Check if works with piped output.
#TODO Unify spearator across all actions and make it parametarized.
#TODO Add generic histogram in alaytics actions.
#TODO Action to add line numbers.
#TODO Add direction to some funtions that involves positions or sorting.
#TODO Action to remove indentation or any leading spaces.
#TODO Action to perform actions in multiple files. Better, this should be in file__actions.

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
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_character" ] && __print_missing_parameter_error "character"
  [ -z "$p_o_ignoreCase" ] && p_o_ignoreCase="false"
  cCount=0;
  if [ "$p_o_ignoreCase" == "true" ]; then
    p_o_character="$(echo $p_o_character|tr [:lower:] [:upper:])"
    p_o_text="$(echo $p_o_text|tr [:lower:] [:upper:])"
  fi
  # Using # inside ${} to get the size of the string.
  for (( i=0;i<${#p_o_text};i++ )); do
    # Using $ to compare strings, as comparison of values when provide the correct equality.
    if [[ "${p_o_text:i:1}" == "$p_o_character" ]]; then 
      ((cCount=cCount+1))
    fi 
  done
  echo $cCount;
}

## Flips the case of each character in the supplied text.
function flip_case {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  flippedCaseText="";
  # Using # inside ${} to get the size of the string.
  IFS=""; while read l; do # IFS needed to preserve leading spaces.
    for (( i=0;i<${#l};i++)); do # Reading per line in order to be able to detect newlines.
      # Using $ to compare strings, as comparison of values when provide the correct equality.
      c="${l:i:1}"
      flippedC="$(echo "$c"|sed "s/\(.\)/\U\1/g")" # Using sed's capture group \(..\) and the \U operator to indicate upper case of group 1.
      if [[ "$c" == "$flippedC" ]]; then
        flippedCaseText="$flippedCaseText$(echo "$flippedC"|sed "s/\(.\)/\L\1/g")"
      else
        flippedCaseText+="$flippedC"
      fi 
    done
    flippedCaseText+="\n"
  done <<< "$p_o_text"
  printf "$flippedCaseText";
}

## Insert a string of characters in the specified mapped positions within the whole text provided. Positions start at 1.
function insert_string_in_positions_within_text {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_dictionary" ] && __print_missing_parameter_error "dictionary"
  IFS=";"; read -a posStrArr <<< "$p_o_dictionary"
  refPosArr=() 
  refStrArr=()
  # Avoiding initialization within a loop by doing it in a separate loop first.
  for ((i=0;i<${#posStrArr[@]};i++)); do
    refPosArr[$i]="$(echo "${posStrArr[$i]}" | cut -d "=" -f 1)"
    refStrArr[$i]="$(echo "${posStrArr[$i]}" | cut -d "=" -f 2)"
  done
  outputText=""
  for ((c=0;c<${#p_o_text};c++)); do
    for ((i=0;i<${#posStrArr[@]};i++)); do
      pos="${refPosArr[$i]}"
      (( pos-- )) # To make it zero-based.
      if [ "$pos" -eq "$c" ]; then
        str="${refStrArr[$i]}"
        outputText+="$str"
      fi
    done
    outputText+="${p_o_text:$c:1}"
  done
  printf "%s\n" "$outputText" # Using the format string to avoid misinterpretation of printf special characters as such when they occur within the text.
}

## Insert a string of characters in the specified mapped positions within each line of the text provided.
function insert_string_in_positions_within_lines {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_dictionary" ] && __print_missing_parameter_error "dictionary"
  IFS=";"; read -a posStrArr <<< "$p_o_dictionary"
  refPosArr=() 
  refStrArr=()
  # Avoiding initialization within a loop by doing it in a separate loop first.
  for ((i=0;i<${#posStrArr[@]};i++)); do
    refPosArr[$i]="$(echo "${posStrArr[$i]}" | cut -d "=" -f 1)"
    refStrArr[$i]="$(echo "${posStrArr[$i]}" | cut -d "=" -f 2)"
  done
  outputText=""
  while read line; do
    outputLine=""
    for ((c=0;c<${#line};c++)); do
      for ((i=0;i<${#posStrArr[@]};i++)); do
        pos="${refPosArr[$i]}"
        (( pos-- )) # To make it zero-based.
        if [ "$pos" -eq "$c" ]; then
          str="${refStrArr[$i]}"
          outputLine+="$str"
        fi
      done
      outputLine+="${line:$c:1}"
    done
    outputText+="$outputLine\n"
  done <<< "$p_o_text"
  echo -e "$outputText"
}

## Check if the provided string contains only alphabetic characters based on a range (defaults to [a-Z]).
function is_string_alphabetic {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ ! -z "$(echo $p_o_text | grep "^[A-Za-z]*$")" ] && echo "true" || echo "false"
}

## Check if the provided string contains numbers and characters based on a range (defaults to [a-Z]).
function is_string_alphanumeric {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ ! -z "$(echo $p_o_text | grep "^[0-9A-Za-z]*$")" ] && echo "true" || echo "false"
}

## Check if the provided string is an email address.
function is_string_email {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ ! -z "$(echo $p_o_text | grep "^[a-zA-Z][0-9A-Za-z]*@[a-zA-Z][0-9A-Za-z]*\.[a-zA-Z]\+$")" ] && echo "true" || echo "false"
}

## Check if the provided string is a number.
function is_string_number {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ ! -z "$(echo $p_o_text | grep "^[0-9]*$")" ] && echo "true" || echo "false"
}

## Check if the provided string is a palindrome.
function is_string_palindrome {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  for ((c=0;c<${#p_o_text};c++)); do
    frontPos="$c"
    backPos="$((${#p_o_text}-1-$c))"
    [ "$frontPos" -ge "$backPos" ] && break
    [ "${p_o_text:$frontPos:1}" != "${p_o_text:$backPos:1}" ] && echo "false" && exit
  done
  echo "true"
}

## Check if the provided string has a special character (any character which is not a number and not in the provided alphabetic range defaulting to [a-Z]).
function is_string_with_special_character {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ ! -z "$(echo $p_o_text | grep "[^0-9A-Za-z]")" ] && echo "true" || echo "false"
}

## Keep the first and last letters only in each word of the supplied text.
function remove_internal_chars {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  printf "$p_o_text\n" | tr '\n' '\r' | sed "s/\([a-Z]\)[a-Z]*\([a-Z][^a-Z]\)/\1\2/g"|tr '\r' '\n' # The command tr is used as a workaround since sed doesn't consider \n outside [a-z].
}

## Replaces each encountered placeholder {} with the field whose turn comes in the supplied separated list. The number of placeholders should be the same as the number of fields in the list.
function remove_text { 
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_separatedListText" ] && __print_missing_parameter_error "separated_list_text"
  p_o_dictionary=""
  p_o_dictionary="$(printf "$p_o_separatedListText"|sed "s/\([^;]\)$/\1;/g"|sed "s/;/=;/g")"
  replace_text_by_dictionary
}

## Replaces each encountered placeholder {} with the field whose turn comes in the supplied separated list. The number of placeholders should be the same as the number of fields in the list.
function replace_positional_placeholders { 
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
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
  done <<< "$p_o_text"
  printf "$outputText" # Using printf to have the same exact output as input in terms of formatting. The command 'echo' produces an extra line at the end.
}

## Replaces each encountered text entry from the dictionaty with its corresponding text there.
function replace_text_by_dictionary { 
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_dictionary" ] && __print_missing_parameter_error "dictionary"
  outputText="$p_o_text"
  valuePostfix="±§\`±\`" # An imporabable text used to avoid replacement of values if they are included as keys further down the road in a dictionary.
  recordPos=1
  while [ ! -z "$(echo "$p_o_dictionary"|cut -d ";" -f $recordPos)" ]; do
    field=$(echo "$p_o_dictionary"|cut -d ';' -f $recordPos)
    key="$(echo "$field"|cut -d '=' -f 1)"
    value="$(echo "$field"|cut -d '=' -f 2)"
    outputText="$(echo "$outputText"|sed "s/$key\([^$valuePostfix]\)/$value$valuePostfix\1/g")"
    recordPos=$((recordPos+1))
  done
  outputText+="\n"
  outputText="$(echo "$outputText"|sed "s/$valuePostfix//g")"
  printf "$outputText" # Using printf to have the same exact output as input in terms of formatting. The command 'echo' produces an extra line at the end.
}

## Roll the characters of a string based on their numerical (decimal) value and one of the following modifiers: offset provided or a list of offsets, both with a possibility limiting the scope through regex ranges.
function roll_chars {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_offset" ] && [ -z "$p_o_separatedListText" ] && __print_missing_parameter_error "offset"
  [ -z "$p_o_range" ]
  [ -z "$p_o_separatedListText" ]
  outputText=""
  if [ ! -z "$p_o_range" ]; then
    offset="$p_o_offset"
  fi
  if [ ! -z "$p_o_range" ]; then
    rangeStr="$(echo "$p_o_range" | sed "s/\[//g"|sed "s/\]//g"|sed "s/\(.\)/\1\1/g"|sed "s/.--.//g")" # Repeat single chars to simulate a range prepare the string for parsing.
    temp="$p_o_text"
    p_o_text="$rangeStr"
    rangeDecimalsList="$(show_decimals_of_string)"
    p_o_text="$temp"
    rangeDecimalsList="$(echo "${rangeDecimalsList:0:$((${#rangeDecimalsList}-1))}" | tr , "/n" | sort -n | tr "/n" ,)"
    IFS=","; read -a rangeDecimalsArr <<< "$rangeDecimalsList"
    ultimateBegin="${rangeDecimalsArr[0]}"
    ultimateEnd="${rangeDecimalsArr[$((${#rangeDecimalsArr[@]}-1))]}"
  fi
  if [ ! -z "$p_o_separatedListText" ]; then
    IFS=","; read -a offsetsArr <<< "$p_o_separatedListText"
  fi
  for ((p=0;p<${#p_o_text};p++)); do 
    c="${p_o_text:$p:1}"
    p_o_character="$c" # Preparing for internal call to another action.
    val="$(show_decimal_of_char $c)"
    if [ ! -z "$p_o_offset" ]; then
      newVal="$(($val+$p_o_offset))"
    elif [ ! -z "$p_o_separatedListText" ]; then
      newVal="$(($val+${offsetsArr[$(($p%${#offsetsArr[@]}))]}))"
    fi
    if [ ! -z "$p_o_range" ]; then
      isFound="false"
      while [ "$isFound" == "false" ]; do # Should run maximum twice due to the % at the end of the loop.
        for ((i=0;i<$((${#rangeDecimalsArr[@]}-1));i+2)); do
          begin="${rangeDecimalsArr[$i]}"
          oldEnd="$end"
          [ -z "$oldEnd" ] && oldEnd="0"
          end="${rangeDecimalsArr[$((i+1))]}"
          if [ "$val" -lt "$begin" ] || [ "$val" -gt "$end" ]; then # Keep chars that are out of range.
            newVal="$val"
            isFound="true"
            break
          fi
          [ "$newVal" -gt "$ultimateEnd" ] && newVal="$(($ultimateBegin+$newVal-$ultimateEnd-1))" #Rolling.
          [ "$newVal" -lt "$begin" ] && newVal="$(($begin+$newVal))"
          [ "$newVal" -gt "$end" ] &&  newVal="$(($newVal%$end))" && continue
          [ "$newVal" -ge "$begin" ] && [ "$newVal" -le "$end" ] && isFound="true" && break
        done
      done
    fi
    #echo "$newVal"
    newChar="$(sh string__actions.sh -a show_char_of_decimal -c "$newVal")" # Called externally due to null bytes by printf output being not allowed in command substitution $(). Expensive. #TODO Use read or truncate null bytes.
    outputText+="$newChar"
  done
  printf "$outputText\n"
}

## Set case of each character in the provided text based on its "even" or "odd" position, or based on a provided sequence of intervals; first position is 1 (not 0 based).
function set_case_procedurally {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_position" ] && [ -z "$p_o_separatedListText" ] && __print_missing_parameter_error "position"
  [ -z "$p_o_separatedListText" ] && [ -z "$p_o_position" ] && __print_missing_parameter_error "separatedListText"
  changedCaseText="";
  IFS=";"; read -a sequenceArr <<< "$p_o_separatedListText"
  IFS=""; while read l; do # IFS needed to preserve leading spaces.
    seqPos=0
    [ "${#sequenceArr[@]}" -ge "0" ] && nextSeqCheckPos=$((${sequenceArr[0]}-1)) # -1 to avoid 0 based effect.
    for ((i=0;i<${#l};i++)); do # Reading per line in order to be able to detect newlines.
      c="${l:i:1}"
      p=$((i+1))
      if [ "$p_o_position" == "even" ] && [ $((p%2)) -eq 0 ]; then
        changedCaseText+=$(echo "$c"|sed "s/\(.\)/\U\1/g")
      elif [ "$p_o_position" == "even" ] && [ $((p%2)) -ne 0 ]; then
        changedCaseText+=$(echo "$c"|sed "s/\(.\)/\L\1/g")
      elif [ "$p_o_position" == "odd" ] && [ $((p%2)) -eq 0 ]; then
        changedCaseText+=$(echo "$c"|sed "s/\(.\)/\L\1/g")
      elif [ "$p_o_position" == "odd" ] && [ $((p%2)) -ne 0 ]; then
        changedCaseText+=$(echo "$c"|sed "s/\(.\)/\U\1/g")
      else # The case for sequence.
        if [ "$nextSeqCheckPos" -eq "$i" ]; then
          seqPos=$((($seqPos+1)%${#sequenceArr[@]}))
          nextSeqCheckPos=$(($i+${sequenceArr[$seqPos]}))
          changedCaseText+=$(echo "$c"|sed "s/\(.\)/\U\1/g")
        else
          changedCaseText+=$(echo "$c"|sed "s/\(.\)/\L\1/g")
        fi
      fi 
    done
    changedCaseText+="\n"
  done <<< "$p_o_text"
  printf "$changedCaseText";
}

## Reduce the provided text to a separated list of the tokens (defaults to words) included based on the regex range provided (defaults to [^a-zA-Z0-9]).
function separate_tokens {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_range" ] && p_o_range="[^a-zA-Z0-9]"
  outputText=$(echo "$p_o_text" | sed "s/$p_o_range/,/g"|tr "\n" ,|sed "s/,,/,/g"|sed "s/,,/,/g") # Same call at end because , has special behaviour of separating characters.
  echo "$outputText"
}

## Shows the char value of the character supplied as a decimal number.
function show_char_of_decimal {
  [ -z "$p_o_character" ] && __print_missing_parameter_error "character"
  printf "\\$(printf %o $p_o_character)\n" # Convert the decimal to octal and then print the char (by \\) of the octal.
}

## Shows a comma-separated list of decimals representing the chars of the provided text.
function show_decimals_of_string {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  decimalsList=""
  for ((i=0;i<${#p_o_text};i++)); do
     p_o_character="${p_o_text:i:1}"
    decimalsList+="$(show_decimal_of_char),"
  done
  printf "$decimalsList\n"
}

## Shows the decimal value of the supplied character.
function show_decimal_of_char {
  [ -z "$p_o_character" ] && __print_missing_parameter_error "character"
  printf "%d\n" "'$p_o_character"
}

## Shows the positions (starting from 1) of the supplied single character in the supplied text. If multiple occurrences, the positions are separated by commas. The search can be flagged as case-insensitive.
function show_positions_of_char {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_character" ] && __print_missing_parameter_error "character"
  [ -z "$p_o_ignoreCase" ] && p_o_ignoreCase="false"
  if [ "$p_o_ignoreCase" == "true" ]; then
    p_o_character="$(echo "$p_o_character"|sed "s/\(.\)/\U\1/g")"
    p_o_text="$(echo "$p_o_text"|sed "s/\(.\)/\U\1/g")"
  fi
  posText=""
  # Using # inside ${} to get the size of the string.
  for ((i=0; i<${#p_o_text}; i++)); do 
    if [[ "${p_o_text:i:1}" == "$p_o_character" ]]; then 
      posText+="$((i+1)),"
    fi 
  done
  [ ${#posText} -eq 0 ] && posText="," # To avoid errors while removing the last comma in case of no positions.
  echo "${posText:0:$((${#posText}-1))}"
}

## Sorts the characters of each token based onl the allowed characters and their positions in the provided separated list.
function sort_chars_per_token {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_separatedListText" ] && [ -z "$p_o_offset" ] && __print_missing_parameter_error "separatedListText"
  IFS=","; read -a referenceCharsArr <<< "$p_o_separatedListText"
  outputText=""
  lastCharPos=0
  while [ "$lastCharPos" -lt "${#p_o_text}" ]; do
    bufferStr=""
    postBufferChar=""
    for ((c=$lastCharPos;c<${#p_o_text};c++)); do
      isFound="false"
      for ((r=0;r<${#referenceCharsArr[@]};r++)); do
        [ "${p_o_text:$c:1}" == "${referenceCharsArr[$r]}" ] && isFound="true" && bufferStr+="${p_o_text:$c:1}" && break
      done
      [ "$isFound" == "false" ] && postBufferChar="${p_o_text:$c:1}" && break
    done
    lastCharPos="$(($c+1))"
    for ((r=0;r<${#referenceCharsArr[@]};r++)); do
      for ((b=0;b<${#bufferStr};b++)); do
        [ "${bufferStr:$b:1}" == "${referenceCharsArr[$r]}" ] && outputText+="${referenceCharsArr[$r]}" && bufferStr="$(echo "$bufferStr"|sed "s/${referenceCharsArr[$r]}//")"
      done
    done
    outputText+="$bufferStr"
    outputText+="$postBufferChar"
  done
  printf "$outputText\n"
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  p_o_text="$inp"
  while read inp; do
    p_o_text+="\n$inp"
  done 
fi
# Parse options and parameters.
while getopts "ha:b:c:d:e:il:o:p:r:s:t:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ## Beginning position or character ;;
    b) p_o_begin=$OPTARG ;;
    ## The character to be queried or manipulated. The size must be of a single character.
    c) p_o_character=$OPTARG ;;
    ## A list of keys and values that resembles to a dictionary. The record separator defaults to semi-colon, while the key/value separator is '='.
    d) p_o_dictionary="$OPTARG" ;;
    ## Ending position or character ;;
    e) p_o_end=$OPTARG ;;
    ## A flag to become case-insensitive while querying. If the option is present, the flag is true; otherwise, false.
    i) p_o_ignoreCase="true" ;;
    ## A string in the form of a list separated by the serparator, which defaults to ai semi-colon.
    l) p_o_separatedListText=$OPTARG ;;
    ## Offset number indicating the distance between two elements in the string.
    o) p_o_offset=$OPTARG ;;
    ## An indicator of a position, like "even" and "odd".
    p) p_o_position=$OPTARG ;;
     #  [ "$OPTARG" -eq "$(echo $OPTARG | grep "^[0-9]*$")" ] || echo "ERROR: Incorrect parameter value for o." ;;
    ## A Regex range of characters enclosed in squared braces.
    r) p_o_range=$OPTARG ;;
    ## A sequence of numbers used in calculated string manipulations.
    s) p_o_sequence=$OPTARG ;;
    ## The text to be queried or manipulated. This can be a string specified via command line, or a path to a text file.
    t) p_o_text="$OPTARG" ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && __print_incorrect_action_error

# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ]  && $p_r_action || __print_incorrect_action_error
