#!/bin/sh
################################################################################
# Brute Forcer                                                                 #
#                                                                              #
# Generates by brute force, based on an input set of characters, all possible  #
# combinations as words of variable sizes as specified by the minimum and      #
# maximum sizes. Each word can then be used as the input of an action          #
# specified by the user.                                                       #
#                                                                              #
# Type: Yielding Process.                                                      #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     grep                                                                     #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c for config, d for data, and o for output.

#TODO Add support to strings to be combined like chars.
#TODO Add optional criteria to evaluate output.
#TODO Add option to suppress undesired output from the action.
#TODO Add masking/

function __print_incorrect_parameter_value_error {
  echo "Validation Error: The provided value '$1' is not supported by this parameter '$2'. Please check Help for more info.">&2
  exit 1
}

function __print_usage {  
  sh $(dirname $0)/help__actions.sh -a print_process_usage -t $0
  exit
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_process_help -t $0
  exit
}

function initialize_input {
  if [ -z $1 ]; then # Case of no options at all.
    __print_usage
  fi
  c_o_action="echo word_here"
  while getopts "ha:c:m:x:" o; do
    case "$o" in
    ## The action to be invoked with each word, specified by "word_here", as its input. Defaults to "echo word_here".
    a) c_o_action=$OPTARG ;;
    ## A string containing the set of chars (without a separator) to be combined to form the words.
    c) c_r_chars=$OPTARG ;;
    ## Minumum size in characters of the word to be guessed. Must be greater than zero.
    m) c_r_minimumSizeOfWord=$OPTARG ;;
    ## Maximum size in characters of the word to be guessed. Must be greater than zero and the minimum.
    x) c_r_maximumSizeOfWord=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  [ $c_r_minimumSizeOfWord -le 0 ] && __print_incorrect_parameter_value_error  "$c_r_minimumSizeOfWord" "minimum_size_of_word"
  [ $c_r_maximumSizeOfWord -le 0 ] && __print_incorrect_parameter_value_error  "$c_r_maximumSizeOfWord" "maximum_size_of_word"
  [ $c_r_maximumSizeOfWord -le $c_r_minimumSizeOfWord ] && __print_incorrect_parameter_value_error  "$c_r_maximumSizeOfWord" "maximum_size_of_word"
  [ -z "$(echo "$c_o_action"|grep "word_here")" ] && __print_incorrect_parameter_value_error  "$c_o_action" "action"
  d_chars=()
  for ((i=0; i<${#c_r_chars};i++)) do
    d_chars[i]="${c_r_chars:$i:1}"
  done
  d_sizeOfSelection=${#d_chars[@]}
  d_word=""
  d_count=0
  d_sizeOfWord=$c_r_minimumSizeOfWord
  o_action="$(echo $c_o_action|sed s/word_here/\$o_word/g)"
  #~hooks for adding a certain behavour at a specific event (like trapping EXIT to clear)~
}

function process_data {
  while [ $d_sizeOfWord -le $c_r_maximumSizeOfWord ]; do
    while [ $d_count -lt $(($d_sizeOfSelection**$d_sizeOfWord)) ]; do
      for ((i=0; i<$d_sizeOfWord; i++)); do
        d_word="${d_chars[(( (d_count/(d_sizeOfSelection**i))%d_sizeOfSelection ))]}$d_word" # Truth table
      done
      o_word="$d_word"
      output
      d_word=""
      d_count=$((d_count+1))
    done
    d_sizeOfWord=$(( d_sizeOfWord+1 ))
  done
}

function output {
  eval $o_action
}

initialize_input "$@"
process_data
