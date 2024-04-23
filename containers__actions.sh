#!/bin/sh
################################################################################
# Containers Actions                                                           #
#                                                                              #
# A set of actions to conveniently manage containers using Docker and other    #
# tools.                                                                       #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     docker, du                                                               #
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

## Remove any Docker image not associated to a Docker container
function remove_all_dangling_docker_images {
  docker image prune -a
}

## Remove any Docker image not associated to a Docker container, any stopped container, any network not used, and all build cache.
function remove_all_docker_inactive_components {
  docker system prune -a -f
}

## Remove any stopped Docker container
function remove_all_stopped_docker_containers {
  docker container prune
}

## Remove any unused Docker volume
function remove_all_stopped_containers {
  docker volume prune
}

## Show detailed report of Docker's images, containers, volumes, and caches, and their disk space usage.
function show_report_of_docker_components {
  docker system df -v 
}

## Show size of Docker's Overlay filesystem, where image and container layers are stored and shared.
function show_size_of_overlayFS {
  sudo du -hs /var/lib/docker/overlay2|sed s/\\t.*//g
}

[ -z "$1" ] && __print_usage
# Parse options and parameters.
while getopts "ha:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    #~description of parameter here~
    #~parameter character here~) ~parameter variable here~=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
# Validate parameters.
[ -z "$p_r_action" ] && _print_incorrect_action_error
#~further parameters validation here~
# Set parameters defaults, if needed.
#~setting parameters defaults here~

# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
