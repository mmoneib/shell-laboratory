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
  ~c_ variables defaults here~
  while getopts "h~getopts parameter string here" o; do
    case "$o" in
    ~description of parameter here~
    ~parameter character here~) ~c_ parameter variable (immutable) here~=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  ~options validation here~
  ~d_ variables (mutable by process_data) initialization here~
  ~o_ variables (immutable) initialization here~
  ~hooks for adding a certain behaviour at a specific event (like trapping EXIT to clear)~
}

function process_data {
nums=( 333 43 531 -1000 5233 6 1299 34 15 6 767)
  width=$(tput cols)
  negativeWidth=0
  normalizedMax=0
  max=0
  min=0
  for i in ${nums[@]}; do
    [ $max -lt $i ] && max=$i
    [ $min -gt $i ] && min=$i
  done
  [ $(( -1*$min )) -gt $max ] && normalizedMax=$(( -1*$min )) || normalizedMax=$max
  if [ $min -lt 0 ]; then
    negativeWidth=$(( $width/2 ))
  fi
  width=$(( $width-$negativeWidth ))
  for i in ${nums[@]}; do
    if [ $min -lt 0 ]; then
      if [ $i -lt 0 ]; then
        for (( j=0; j<$width+($i*$negativeWidth/$normalizedMax); j++ )); do
      printf " "
        done
        for (( j=$width+($i*$negativeWidth/$normalizedMax); j<$negativeWidth; j++ )); do
      printf "|"
        done
      else
        for (( j=0; j<$negativeWidth; j++ )); do
      printf " "
        done
      fi
    fi
    for (( j=0; j<i*$width/$normalizedMax; j++ )); do
      printf "|"
    done
    printf "\n"
  done
}

function pretty_output {
  ~human readable and formatted output here~
}

function raw_output {
  ~plain data structural output here~
}

function output {
  if [ $c_isRawOutput ]; then
    raw_output
  else
    pretty_output
  fi
}

initialize_input "$@"
process_data
output
