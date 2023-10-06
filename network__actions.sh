#!/bin/sh
################################################################################
# Network Actions                                                              #
#                                                                              #
# A set of functions to perform analysis and manipulation of the network.      #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     ifconfig, nmap                                                           #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

function __print_usage {
  sh $(dirname $0)/help__actions.sh -a print_actions_usage -t $0
  exit 1
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_actions_help -t $0
  exit 1
}

function __print_missing_parameter_error {
  sh $(dirname $0)/help__actions.sh -a print_missing_parameter_error -p $1
  exit 1
}

function __print_incorrect_action_error {
  sh $(dirname $0)/help__actions.sh -a print_incorrect_action_error
  exit 1
}

## Get IP of the current host (IPv4)
function get_ip_v4_of_current_host {
  echo "$(ifconfig|grep -v 127.0.0.1|grep -v inet6|grep inet|sed "s/^\ *//g"|cut -d " " -f 2)"
}

## Get IP of the current host (IPv16)
function get_ip_v16_of_current_host {
  echo "$(ifconfig|grep inet6|grep -v "::1"|sed "s/^\ *//g"|cut -d " " -f 2)"
}


[ -z "$1" ] && __print_usage
# Parse options and parameters.
while getopts "ha:~getopts parameter string here~" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && _print_incorrect_action_error

# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
