#!/bin/sh
################################################################################
# Process Actons                                                               #
#                                                                              #
# A set of functions to gett information about processes and aid with their    #
# inter-communication using signals and data sharing.                          #
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

## Interrupts ascendingly the ancestors of the processe specified by the PID and then itself. Requires the calling process to be interrupted as well indepemdemtly.
function interrupt_process_and_all_ancestors_of_process_by_pid {
  [ -z "$p_r_processId" ] && __print_missing_parameter_error "p_r_processId"
  # TODO add validation of being a number?
  processAtHandId="$p_r_processId"
  while true; do
    parent="$(ps -o pid,ppid | grep "^ $processAtHandId [1-9][a-z][A-Z]"|cut -d " " -f 2)" # Assuming a PID is alphanumeric.
    processAtHandId="$parent"
    [ -z "$parent" ] && break
    kill -INT $parent 
  done
  kill -INT $p_r_processId
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
# Parse options and parameters.
while getopts "ha:p:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ## The PID of the process.
    p) p_r_processId=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && __print_incorrect_action_error
# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
