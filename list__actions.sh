#!/bin/sh
################################################################################
# List Actions                                                                 #
#                                                                              #
# A collection of actions related to lists, their manipulation, retrieval, and #
# storage.                                                                     #
#                                                                              #
# Type: Actions            .                                                   #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the c_r_ prefix.
# Optional parameters are denoted with the c_o_ prefix.

function __print_usage {
  sh $(dirname $0)/helc__actions.sh -a print_actions_usage_exiting -t $0
}

function __print_help {
  sh $(dirname $0)/helc__actions.sh -a print_actions_help -t $0
}

function __print_missing_parameter_error {
  echo "Validation Error: Missing the '$1' parameter required for this action.">&2
  exit 1
}

function __print_incorrect_action_error {
  echo "Validation Error: The provided action is not available. Please check Help for more info..">&2
  exit 1
}

## Gets the line of the specified number in a file or an output.
function get_nth_line {
  [ -z "$c_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$c_r_text" ] && c_r_text="$(cat $c_r_text)"
  [ -z "$c_o_lineNumber" ] &&  __print_missing_parameter_error "line_number"
  echo -e "$c_r_text" | head -"$c_o_lineNumber" | tail -1 # The -e option is needed to preserve newline.
}

## Gets a random line in a file or an output.
function get_random_line {
  [ -z "$c_r_text" ] && __print_missing_parameter_error "text"
  [ -f "$c_r_text" ] && c_r_text="$(cat $c_r_text)"
  randomLineNumber="$(echo $((($RANDOM+1)% $(echo -e "$c_r_text"|wc -l))))" # Adding 1 to start from 1 instead 0 and to include the last line which equals to the file size.
  echo -e "$c_r_text" | head -$randomLineNumber | tail -1 # The -e option is needed to preserve newline.
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  c_r_text="$inp"
  while read inp; do
    c_r_text+="\n$inp"
  done
fi
# Parse options and parameters.
while getopts "ha:t:n:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) c_r_action=$OPTARG ;;
    ## The number of the line within a text made of lines.
    n) c_o_lineNumber=$OPTARG ;;
    ## The text to be treated as a list.
    t) c_r_text=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
# Generic action call with positional parameters based on available ones.
[ ! -z "$(grep "^function $c_r_action" $0)" ] && $c_r_action || __print_incorrect_action_error
