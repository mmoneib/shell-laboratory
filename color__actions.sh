#!/bin/sh
################################################################################
# Color Actions                                                                #
#                                                                              #
# A set of utility functions to conveniently manipulate the colors of the text #
# output inside the terminal as well as provide information about the          #
# available colors.                                                            #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash), and tput (if not included. #
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
  echo "Validation Error: The provided action is not available. Please check Help for more info.">&2
  exit 1
}

function __print_end_line {
  printf "$(tput init)\n"
}

## Print the number of colors supported by the terminal.
function count_terminal_colors {
  tput colors
}

## Print all colors supported by the terminal in order horizontally.
function print_all_colors_horizontally {
  withNums=$1
  for ((i=0; i<$(count_terminal_colors);i++)); do
    printf "$(tput setab $i)"
    [ ! -z $withNums ] && [ $withNums = true ] && printf " $i " || printf ' '
  done
  __print_end_line
}

## Print all colors supported by the terminal in order horizontally with the equivalent number on each.
function print_all_colors_horizontally_with_nums {
  print_all_colors_horizontally true
}

## Print all colors supported by the terminal in order vertically.
function print_all_colors_vertically {
  withNums=$1
  for ((i=0;i<$(count_terminal_colors);i++)); do
    printf "$(tput setab $i)"
    [ ! -z $withNums ] && [ $withNums = true ] && printf " $i " || printf ' '
    __print_end_line
  done
}

## Print all colors supported by the terminal in order vertically with the equivalent number on each.
function print_all_colors_vertically_with_nums {
  print_all_colors_vertically true
}

## Print text in the screen with a specific font color and background color. 
function print_text_with_color_and_background {
  [ -z "$c_o_text" ] && __print_missing_parameter_error "text"
  [ -z "$c_o_color" ] && __print_missing_parameter_error "color"
  [ -z "$c_o_background" ] && __print_missing_parameter_error "background"
  tput setaf "$c_o_color"
  tput setab "$c_o_background"
  printf "$c_o_text"
  __print_end_line
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  c_o_text="$inp"
  while read inp; do
     c_o_text+="\n$inp"
  done
fi
# Parse options and parameters.
while getopts "ha:b:c:t:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) c_r_action=$OPTARG ;;
    ## The background to be preinted for the text.
    b) c_o_background=$OPTARG ;;
    ## The color of the text.
    c) c_o_color=$OPTARG ;;
    ## The text to be printed on the screen,
    t) c_o_text=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $c_r_action" $0)" ] && $c_r_action || __print_incorrect_action_error
