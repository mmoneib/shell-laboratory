#!/bin/bash
################################################################################
# Check Options Parameter                                                      #
#                                                                              #
# Description: Parse parameters passed to the script in a customizable and     #
# convenient way without shifting and without getopts.                         #
#                                                                              #
# Type: To be sourced by other scripts.                                        #
# Dependencies: Bash                                                           #
# Developed by: Muhammad Moneib                                                #
################################################################################

cop_options=(); # Potential output.
cop_hasOption=false; # Potential output.
cop_optionValue=; # Potential output.
cop_optionValuePosition=; # Potential output.

_cop_parameters=("$@"); # For internal use.

function _cop_returnOptions {
  #Parameters index atarts at 1.
  for ((i=1;i<=${#@};i++)); do
    tmp=${!i}; # Expands to the content of the parameter inside the loop.
    if [[ "${tmp:0:2}" == "--" ]]; then #Strings index starts at 0.
      #Arrays index starts at 0.
      cop_options+=("${tmp:2:${#tmp}}");
    elif [[ "${tmp:0:1}" == "-" ]]; then
      for ((j=1;j<${#tmp};j++)); do
        cop_options+=("${tmp:$j:1}");
      done
    fi
  done
}

function cop_doesThisOptionExist {
  cop_hasOption=false;
  for((i=0;i<${#cop_options[@]};i++)); do
    if [[ "${cop_options[i]}" == "$1" ]]; then
      cop_hasOption=true; 
    fi
  done
}

function cop_getValueForOption {
  for((i=0;i<${#_cop_parameters[@]};i++)); do
    if [[ "$1" == "${_cop_parameters[i]:1}" ]] || [[ "$1" == "${_cop_parameters[i]:2}" ]]; then
      cop_optionValue="${_cop_parameters[((i+1))]}";
    fi
  done
}

function cop_getValuePositionForOption { # the next index for the option.
  for((i=0;i<${#_cop_parameters[@]};i++)); do
    if [[ "$1" == "${_cop_parameters[i]:1}" ]] || [[ "$1" == "${_cop_parameters[i]:2}" ]]; then
      if ((${#_cop_parameters[@]}>$i+1)); then # to make sure the size of the parameters allow another one (where the value might lie).
        cop_optionValuePosition=$((i+2)); # +2 because parameters are not zero-indexed.
      fi
    fi
  done
}

_cop_returnOptions $@; # passing the parameters to the function.
