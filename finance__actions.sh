#!/bin/sh
################################################################################
# Finance Actions                                                              #
#                                                                              #
# A set of functions to perform financial calculations.                        #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     bc.                                                                      #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

# TODO Add validation of the values.

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

## Calculate breakeven factor. The amount provided should be between 0 and 1 and represents the loss portion (percentage in decimals).
function calculate_breakeven_factor {
  [ -z "$p_r_operand" ] && __print_missing_parameter_error "operand"
  result="$(echo "scale=2;1/(1-$p_r_operand)"|bc -l)"
  echo "$result"
}

## Calculate breakeven factor. The amount provided should be between 0 and 1 and represents the loss portion (percentage in decimals).
function calculate_breakeven_percentage {
  result="$(calculate_breakeven_factor)"
  result="$(echo "scale=2;$result-1"|bc -l)"
  printf "%.2f\n" "$result" # FOrmatting using prontf to ensure leading zero.
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  p_r_operand="$inp"
  while read inp; do
     p_r_operand+="\n$inp"
  done
fi
# Parse options and parameters.
while getopts "ha:o:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ## Amount as an operand on which the calculation is done.
    o) p_r_operand=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && __print_incorrect_action_error:wqwqwwqwwwqww:wq
# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
