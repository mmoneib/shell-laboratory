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

#TODO Add namespaces comment.
# Positional parameters inside action functions are used especially for the case of sourcing.

function print_usage {
  sh $(dirname $0)/help_actions.sh -a print_actions_usage_exiting -t $0
}

function print_help {
  sh $(dirname $0)/help_actions.sh -a print_actions_help -t $0
}

## Gets the line of the specified number in a file or an output.
function get_nth_line {
  while read -t 0.1 inp; do # For the case of piping.
    p_r_text+="$inp\n"
  done
  [ -z "$p_r_text" ] && p_r_text="$1"
  [ -z "$p_o_lineNumber" ] && p_o_lineNumber="$2"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
  echo -e "$p_r_text" | head -$p_o_lineNumber | tail -1 # The -e option is needed to preserve newline.
}

## Gets a random line in a file or an output.
function get_random_line {
  while read -t 0.1 inp; do # For the case of piping.
    p_r_text+="$inp\n"
  done
  [ -z "$p_r_text" ] && p_r_text="$1"
  [ -f "$p_r_text" ] && p_r_text="$(cat $p_r_text)"
  randomLineNumber="$(echo $((($RANDOM+1)% $(echo -e "$p_r_text"|wc -l))))" # Adding 1 to start from 1 instead 0 and to include the last line which equals to the file size.
  echo -e "$p_r_text" | head -$randomLineNumber | tail -1 # The -e option is needed to preserve newline.
}

if [ "$1" != "skip_run" ]; then
  if [ -z $1 ]; then
    read -t 0.1 inp;
    [ -z $inp ] && print_usage
  fi
  while getopts "a:t:n:h" o; do
    case $o in
      a) p_r_action=$OPTARG ;; ## action_name_here
      n) p_o_lineNumber=$OPTARG ;; ## line_number_here
      t) p_r_text=$OPTARG ;; ## text_here
      h) print_help ;;
      *) print_usage ;;
    esac
  done
  # Generic action call with positional parameters based on available ones.
  $p_r_action $p_r_text $p_o_lineNumber
fi
