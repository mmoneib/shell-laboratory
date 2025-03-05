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
#TODO: Option for horizontal graph.
#TODO: Interactive mode to highlight bars and show labels.

function __print_required_parameter_missing_value_error {
  echo "Validation Error: The required parameter '$1' is required but missing. Please check Help for more info.">&2
  exit 1
}

function __print_incorrect_parameter_value_error {
  echo "Validation Error: The provided value '$1' is not supported by this parameter '$2'. Please check Help for more info.">&2
  exit 1
}

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
  while getopts "hd:ils:" o; do
    case "$o" in
    ## List of keys and/or values separated by spaces.
    d) c_r_dictLabelsValues=$OPTARG ;;
    ## Display labels inline with the bars.
    i) c_o_isInline="true" ;;
    ## Indicator that the dictionary parameter doesn't hold labels, but only values.
    l) c_o_isList="true" ;;
    ## Separator between entries of the dictionary.
    s) c_r_entrySeparator=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  [ -z "$c_r_dictLabelsValues" ] && __print_required_parameter_missing_value_error "dictLabelsValues"
  [ -z "$c_r_entrySeparator" ] && __print_required_parameter_missing_value_error "entrySeparator"
  inputDictAsLines="$(echo "$c_r_dictLabelsValues"|sed "s/$c_r_entrySeparator/\n/g")"
  d_labels=()
  d_values=()
  c=0
  while read inp; do
    if [ -z "$c_o_isList" ]; then
      [ "$((c%2))" == "0" ] && d_labels+=("$inp")
      [ "$((c%2))" == "1" ] && d_values+=("$inp")
    else
      d_values+=("$inp")
    fi
    ((c++))
  done <<< "$inputDictAsLines"
  o_output=""
  #~hooks for adding a certain behaviour at a specific event (like trapping EXIT to clear)~
}

function process_data {
  width=$(tput cols)
  if [ "$c_o_isInline" == "true" ] && [ "${#d_labels[@]}" -gt "0" ]; then
    maxLabelLength=0
    for l in ${d_labels[@]}; do
      [ "${#l}" -gt "$maxLabelLength" ] && maxLabelLength="${#l}"
    done
    width=$(( width - maxLabelLength ))
  fi
  negativeWidth=0 # The distance from leftmost to the origin. Defaults to zero, assuming no negative values.
  normalizedMax=0 # The largest absolute value which would be normalized to fit the screen and to which all other valio are recalculated.
  max=0
  min=0
  for i in ${d_values[@]}; do # Getting both min and max for the possibility of a double sided graph in case of negative values.
    [ $max -lt $i ] && max=$i
    [ $min -gt $i ] && min=$i
  done
  [ $(( -1*$min )) -gt $max ] && normalizedMax=$(( -1*$min )) || normalizedMax=$max
  if [ $min -lt 0 ]; then
    negativeWidth=$(( $width/2 ))
  fi
  width=$(( $width-$negativeWidth ))
  c=0
  for i in ${d_values[@]}; do
    if [ ! -z "$maxLabelLength" ]; then
      for (( j=0; j<$maxLabelLength; j++ )); do
        o="${d_labels[c]}"
        oc="${o:j:1}"
        [ ! -z "$oc" ] && o_output+="$oc" || o_output+=" " # Pad with spaces if the label is less than the maximum.
      done
    else
      [ ${#d_labels[@]} -gt 0 ] && o_output+="${d_labels[c]}\n"
    fi
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
    (( c++ ))
  done
}

function output {
  printf "$o_output"
}

initialize_input "$@"
process_data
output
