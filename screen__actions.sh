#!/bin/sh
################################################################################
# Screen Actions                                                               #
#                                                                              #
# A set of functions to conveniently present graphics and text on the screen   #
# output inside the terminal as well as provide information about the          #
# terminal's capabilities.                                                     #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash), and tput (if not included. #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

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

function __print_end_line {
  printf "$(tput init)\n"
}

## Print the number of colors supported by the terminal.
function count_terminal_colors {
  tput colors
}

## Should be called from a process initialized by tput clear to treat the screen as canvas.
function paint_point {
  [ -z "$p_o_grid" ] && __print_missing_parameter_error "grid"
  [ -z "$p_o_background" ] && __print_missing_parameter_error "background"
  [ -z "$p_o_horizontalPos" ]
  [ -z "$p_o_verticalPos" ]
  tput cup $p_o_verticalPos $p_o_horizontalPos
  tput setab "$p_o_background"
  printf " "
}

## Print all colors supported by the terminal in order horizontally.
function print_all_colors_horizontally {
  withNums=$1
  for ((i=0; i<$(count_terminal_colors);i++)); do
    printf "$(tput setab $i)"
    [ ! -z $withNums ] && [ $withNums = true ] && printf " $i " || printf ' '
  done
  #__print_end_line
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
    #__print_end_line
  done
}

## Print all colors supported by the terminal in order vertically with the equivalent number on each.
function print_all_colors_vertically_with_nums {
  print_all_colors_vertically true
}

## Print a color only. 
function print_color {
  [ -z "$p_o_background" ] && __print_missing_parameter_error "background"
  tput setab "$p_o_background"
  printf " "
  #__print_end_line
}

## Print text in the screen with a specific font color and background color. 
function print_text_with_color_and_background {
  [ -z "$p_o_text" ] && __print_missing_parameter_error "text"
  [ -z "$p_o_color" ] && __print_missing_parameter_error "color"
  [ -z "$p_o_background" ] && __print_missing_parameter_error "background"
  tput setaf "$p_o_color"
  tput setab "$p_o_background"
  printf "$p_o_text"
#  __print_end_line
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
while getopts "ha:b:c:g:t:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ## The background to be preinted for the text.
    b) p_o_background=$OPTARG ;;
    ## The color of the text.
    c) p_o_color=$OPTARG ;;
    ## Dimensions of the grid representing the screen in terms of sections. Example: 5*3. If available, h and v are expected to denote a sections.
    g) p_o_grid=$OPTARG ;;
    ## The text to be printed on the screen,
    t) p_o_text=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
# Validate parameters.
[ -z "$p_r_action" ] && __print_incorrect_action_error
# Set parameters defaults.
if [ ! -z "$p_o_grid" ]; then # Abstracting the screen's size into a virtual grid understood by the user. Allows virtual scaling and responsive design.
  horizontalGrid="$(echo "$p_o_grid" | cut -d"*" -f 1)" 
  verticalGrid="$(echo "$p_o_grid" | cut -d"*" -f 2)"
  colsPerGrid=$((($(tput cols)/$horizontalGrid)))
  [ -z "$p_o_horizontalPos" ] && p_o_horizontalPos=$(($horizontalGrid/2)) # To default close to center. No +1 as positions are zero-based.
  p_o_horizontalPos=$(($colsPerGrid*$p_o_horizontalPos-($colsPerGrid/2)))
  linesPerGrid=$((($(tput lines)/$verticalGrid)))
  [ -z "$p_o_verticalPos" ] && p_o_verticalPos=$(($verticalGrid/2))  # To default close to center. No +1 as positions are zero-based.
  p_o_verticalPos=$(($linesPerGrid*$p_o_verticalPos-($linesPerGrid/2)))
echo "$linesPerGrid $p_o_verticalPos"
fi

# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
__print_end_line
