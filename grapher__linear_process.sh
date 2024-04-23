#!/bin/sh
################################################################################
# Grapher                                                                      #
#                                                                              #
# Draw graphs on the terminal.                                                 #
#                                                                              #
# Type: Progressive Process.                                                   #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c for config, d for data, and o for output.

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
  #~c_ variables defaults here~
  while getopts "hl:" o; do
    case "$o" in
    ## List of values separated by spaces.
    l) c_r_listOfValues=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  #~options validation here~
  d_listOfValues=($c_r_listOfValues)
  #~o_ variables (immutable) initialization here~
  o_output=""
  #~hooks for adding a certain behaviour at a specific event (like trapping EXIT to clear)~
}

function process_data {
  width=$(tput cols)
  negativeWidth=0
  normalizedMax=0
  max=0
  min=0
  for i in ${d_listOfValues[@]}; do
    [ $max -lt $i ] && max=$i
    [ $min -gt $i ] && min=$i
  done
  [ $(( -1*$min )) -gt $max ] && normalizedMax=$(( -1*$min )) || normalizedMax=$max
  if [ $min -lt 0 ]; then
    negativeWidth=$(( $width/2 ))
  fi
  width=$(( $width-$negativeWidth ))
  for i in ${d_listOfValues[@]}; do
    if [ $min -lt 0 ]; then
      if [ $i -lt 0 ]; then
        for (( j=0; j<$width+($i*$negativeWidth/$normalizedMax); j++ )); do
          o_output+=" "
        done
        for (( j=$width+($i*$negativeWidth/$normalizedMax); j<$negativeWidth; j++ )); do
          o_output+="|"
        done
      else
        for (( j=0; j<$negativeWidth; j++ )); do
          o_output+=" "
        done
      fi
    fi
    for (( j=0; j<i*$width/$normalizedMax; j++ )); do
      o_output+="|"
    done
    o_output+="\n"
  done
}

function output {
  printf "$o_output"
}

initialize_input "$@"
process_data
output
