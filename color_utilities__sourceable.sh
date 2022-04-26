#!/bin/sh
################################################################################
# Color Utilities                                                              #
#                                                                              #
# A set of utility functions to conveniently manipulate the colors of the text #
# output inside the terminal as well as provide information about the          #
# available colors.                                                            #
#                                                                              #
# Type: Utility.                                                               #
# Dependencies: Unix-like Shell (tested with Bash), and tput (if not included. #
# Developed by: Muhammad Moneib                                                #
################################################################################

function usage {
  echo "Usage: color_utilities__sourceable.sh -a action_here [-t text_here - color_number_here]
        Available actions:
          count_terminal_colors
          print_all_colors_horizontally
          print_all_colors_horizontally_with_nums
          print_all_colors_vertically
          print_all_colors_vertically_with_nums
          print_text_with_color_and_background fg_color_num bg_color_num"
  exit 1
}

function _print_end_line {
  printf "$(tput init)\n"
}

function count_terminal_colors {
  tput colors
}

function print_all_colors_horizontally {
  withNums=$1
  for (( i=0; i<$(count_terminal_colors); i++ )); do
    printf "$(tput setab $i)"
    [ ! -z $withNums ] && [ $withNums = true ] && printf " $i " || printf ' '
  done
  _print_end_line
}

function  print_all_colors_horizontally_with_nums {
  print_all_colors_horizontally true
}

function print_all_colors_vertically {
  withNums=$1
  for (( i=0; i<$(count_terminal_colors); i++ )); do
    printf "$(tput setab $i)"
    [ ! -z $withNums ] && [ $withNums = true ] && printf " $i " || printf ' '
    _print_end_line
  done
}

function print_all_colors_vertically_with_nums {
  print_all_colors_vertically true
}

function print_text_with_color_and_background {
  text=$1
  color=$2
  background=$3
  tput setaf $color
  tput setab $background
  printf "$text"
  _print_end_line
}

if [ "$1" != "skip_run" ]; then # Escape condition for sourcing scipts.
  __par=$1
  if [ -z $1 ] || [ "${__par:0:1}" != "-" ] || (( ${#__par} < 2 )); then
    usage
  fi
  
  while getopts "a:" o; do
    case $o in
      a) $OPTARG ;;
      ?) usage ;;
    esac
  done
fi
