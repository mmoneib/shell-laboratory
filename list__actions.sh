#!/bin/sh
################################################################################
# List Actions                                                                 #
#                                                                              #
# A set of functions to extract and manipulate lists.                          #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

# TODO Add support for lists with separators.

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

## Gets the line of the specified number in a file or an output.
function get_nth_line {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  [ -z "$p_o_lineNumber" ] &&  __print_missing_parameter_error "line_number"
  echo -e "$p_o_text" | head -"$p_o_lineNumber" | tail -1 # The -e option is needed to preserve newline.
}

## Gets a random line in a file or an output.
function get_random_line {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_text" ] && p_o_text="$(cat $p_o_text)"
  randomLineNumber="$(echo $((($RANDOM+1)% $(echo -e "$p_o_text"|wc -l))))" # Adding 1 to start from 1 instead 0 and to include the last line which equals to the file size.
  echo -e "$p_o_text" | head -$randomLineNumber | tail -1 # The -e option is needed to preserve newline.
}

# Gets a list of rows, each containing a token separated from the string of tokens separated by the separator.
function get_list_from_separated_list {
  [ -z "$p_o_separatedListText" ] && __print_missing_parameter_error "text"
  [ -f "$p_o_separatedListText" ] && p_o_separatedListText="$(cat $p_o_separatedListText)"
  [ -z "$p_o_separator" ] && __print_missing_parameter_error "separator"
  text="$(echo "$p_o_separatedListText"|sed "s/$p_o_separator/\n/g")"
  printf "$text\n"
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
while getopts "ha:l:s:t:n:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ## A string containing a list of tokens separated by the separator indicated by 's'.
    l) p_o_separatedListText=$OPTARG ;;
    ## The number of the line within a text made of lines.
    n) p_o_lineNumber=$OPTARG ;;
    ## A string of characters to be considered as a separator. To be used along with 'l'.
    s) p_o_separator=$OPTARG ;;
    ## A text to be treated as a list.
    t) p_o_text=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && __print_incorrect_action_error
# Generic action call with positional parameters based on available ones.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
