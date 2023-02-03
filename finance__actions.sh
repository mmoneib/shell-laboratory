#!/bin/sh
################################################################################
# Finance Actions                                                              #
#                                                                              #
# A set of functions to perform financial calculations.                        #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     ~additional dependenies here~                                            #
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

## ~comment describing the action here~
function ~action function name here~ {
  [ -z "~parameter variable here~" ] && __print_missing_parameter_error ~parameter_name_here~
  ~further validation of optional parameters or for types here~
  ~repitition~
  ~repitition~
  ~action implementation here~
}

~repitition~

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  ~input text parameter here~="$inp"
  while read inp; do
     ~input text parameter here~+="\n$inp"
  done
fi
# Parse options and parameters.
while getopts "ha:~getopts parameter string here~" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ~description of parameter here~
    ~parameter character here~) ~parameter variable here~=$OPTARG ;;
    ~repitition~
    ~repitition~
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && __print_incorrect_action_error:wqwqwwqwwwqww:wq
# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
