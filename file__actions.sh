#!/bin/sh
################################################################################
# File Actions                                                                 #
#                                                                              #
# A collection of actions to managee or analyze files.                         #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.
# TODO Add action to perform a command on several files.

function __print_usage {
  sh $(dirname $0)/help__actions.sh -a print_actions_usage -t $0
  exit 1
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_actions_help -t $0
  exit 1
}

function __print_missing_parameter_error {
  sh $(dirname $0)/help__actions.sh -a print_missing_parameter_error -p $1
  exit 1
}

function __print_incorrect_action_error {
  sh $(dirname $0)/help__actions.sh -a print_incorrect_action_error
  exit 1
}

## Add a file with an automated name based on the specified prefix (if any) and the next number in thea sequence based on the highest foundt in the specified directory.
function add_sequential_file {
  [ -z "$p_r_path" ] && __print_missing_parameter_error "path"
  [ -z "$p_o_content" ] && __print_missing_parameter_error "content"
  highestSequence="$(ls -1 $p_r_path|grep "$p_o_prefix"[0-9]|sort -n|tail -1)"
  [ ! -z "$p_o_prefix" ] && highestSequence="$(echo "$highestSequence"|sed "s/$p_o_prefix//g")"
  [ -z "$highestSequence" ] && highestSequence="0"
  (( highestSequence++ ))
  echo "$p_o_content" > "$p_r_path/$p_o_prefix$highestSequence"
  echo "Created file $p_o_prefix$highestSequence."  
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  p_r_path="$inp"
  while read inp; do
     p_r_path+="\n$inp"
  done
fi
# Parse options and parameters.
while getopts "ha:b:c:p:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ## The path to the file or the directory upon which the operation should be performed.
    p) p_r_path=$OPTARG ;;
    ## A prefix to be used in file sequencing.
    b) p_o_prefix=$OPTARG ;;
    ## The content of the file specified.
    c) p_o_content=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && _print_incorrect_action_error
# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
