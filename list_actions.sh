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

function print_usage {
  sh $(dirname $0)/help_actions.sh -a  print_actions_usage -t $0
}

function print_help {
  sh $(dirname $0)/help_actions.sh -a print_actions_help -t $0
}

## Gets the line of the specified number in a file or an output.
function get_nth_line {
  while read -t 0.1 inp; do # For the case of piping.
    text+="$inp\n"
  done
  [ -z "$text" ] && text="$1"
  [ -z "$lineNumber" ] && lineNumber="$2"
  [ -f "$text" ] && text="$(cat $text)"
  echo -e "$text" | head -$lineNumber | tail -1 # The -e option is needed to preserve newline.
}

## Gets a random line in a file or an output.
function get_random_line {
  while read -t 0.1 inp; do # For the case of piping.
    text+="$inp\n"
  done
  [ -z "$text" ] && text="$1"
  [ -f "$text" ] && text="$(cat $text)"
  randomLineNumber="$(echo $((($RANDOM+1)% $(echo -e "$text"|wc -l))))" # Adding 1 to start from 1 instead 0 and to include the last line which equals to the file size.
  echo -e "$text" | head -$randomLineNumber | tail -1 # The -e option is needed to preserve newline.
}

if [ "$1" != "skip_run" ]; then
  while getopts "a:t:n:h" o; do
    case $o in
      a) action=$OPTARG ;;
      n) lineNumber=$OPTARG ;;
      t) text=$OPTARG ;;
      h) print_help ;;
      *) print_usage ;;
    esac
  done
  # Generic action call with positional parameters based on available ones.
  $action $text $lineNumber
fi
