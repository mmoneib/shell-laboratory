	#!/bin/sh
################################################################################
# OS Actions                                                                   #
#                                                                              #
# Collection of actions to manipulate or tweak the functionality of Linux.     #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     Linux                                                                    #
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

## Enable the awakeness of the laptop when the lid is down with power.
function keep_awake_when_lid_down_with_power {
  path="/etc/systemd/logind.conf.d/"
  [ ! -d "$path" ] && mkdir "$path"
  printf "[Login]\nHandleLidSwitchExternalPower=ignore\n">"$path""custom.conf"
  echo "The file $path/custom.conf created with the below content:"
  cat "/etc/systemd/logind.conf.d/custom.conf"
  systemctl reload systemd-logind
}

## Set to default the awakeness of the laptop when the lid is down with power.
function set_to_default_when_lid_down_with_power {
  isUpdated="false"
  path="/etc/systemd/logind.conf.d/"
  [ -d "$path" ] && rm -r "$path" && isUpdated="true" && systemctl reload systemd-logind
  [ "$isUpdated" == "true" ] && echo "HandleLidSwitchExternalPower is set to default." || "Ignoring as $path was not found."
}

[ -z "$1" ] && __print_usage
# Parse options and parameters.
while getopts "ha:v:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    # The value by which the action will modify the property.
    v) p_o_value=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
# Validate parameters.
[ -z "$p_r_action" ] && _print_incorrect_action_error

# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
