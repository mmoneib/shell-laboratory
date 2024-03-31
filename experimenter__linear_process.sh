#!/bin/sh
################################################################################
# Experimenter                                                                 #
#                                                                              #
# A process to execute a command in successive iterations with optional        #
# variation of its input parameters and perform aggregate functions on the     #
# output.                                                                      #
#                                                                              #
# Type: Progressive Process.                                                   #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     ~additional dependenies here~                                            #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c_r for required config, c_o for opritonal config, d for data, and o for output.

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
  while getopts "hc:f:i:n:p:rD" o; do
    case "$o" in
    ## The command to be executed. Parameter placeholders are indicated by positional braces (i.e. {}). The output should be raw CSV.
    c) c_r_command=$OPTARG ;;
    ## Comma-separated list of functions to be performed on each corresponding parameter (i.e. first funciton for first parameter...etc.). Supported functions are 'sum' and 'average'.
    f) c_r_parameterFunctionsList=$OPTARG ;; 
    ## Number of iterations in which the command will be executed and upon which aggregation will be done.
    i) c_r_numOfIterations=$OPTARG ;;
    ## Optional comma-separated list of names specifying the corresponding parameters, for reporting purposes.
    n) c_o_parameterNamesList=$OPTARG ;;
    ## Semicolon-separated list of parameter values, each will replace the corresponding placeholder in the command specified.
    p) c_r_parameterValuesList=$OPTARG ;;
    ## If specified, raw output will be in CSV format.
    r) c_o_isRawOutput=true ;;
    ## If DEBUG putput is to be allowed.
    D) c_o_isDebug=true ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  #TODO Validate equal size of parameter values, names, and functions.
  d_command="$(./string__actions.sh -a replace_positional_placeholders -t "$c_r_command" -l "$c_r_parameterValuesList")"
  IFS=, read -a d_parameterFunctionsList <<< "$c_r_parameterFunctionsList"
  #~o_ variables (immutable) initialization here~
  #~hooks for adding a certain behaviour at a specific event (like trapping EXIT to clear)~
}

function process_data {
  [ ! -z $c_o_isDebug ] && echo "DEBUG(evaluated_command): $d_command"
  allOutput=""
  for (( i=0; i<c_r_numOfIterations; i++ )); do
    output="$(eval "$d_command"|tail -1)"
    allOutput="$allOutput$output\n"
    [ ! -z $c_o_isDebug ] && echo "DEBUG(command_iterative_output): $output"
  done
  toBeAggregatedList=()
  while read line; do
    IFS=, read -a tokens <<< "$line"
    for (( i=0; i<${#tokens[@]}; i++ )); do
      toBeAggregatedLists[$i]+="${tokens[$i]},"
    done
  done <<< "$(printf $allOutput)" # Using "printf" allows "read" to interpret \n as new line. 
  o_commandReport=()
  for (( i=0; i<${#d_parameterFunctionsList[@]}; i++ )); do
    o_commandReport[$i]="$(./math__actions.sh -a ${d_parameterFunctionsList[$i]} -l ${toBeAggregatedLists[$i]})"
  done
  o_command="$d_command"
  o_commandOutput="${allOutput:0:$(( ${#allOutput}-2 ))}" # Removes "\n"
}

function output {
  commandReportText=""
  for (( i=0; i<${#o_commandReport[@]}; i++ )); do
    commandReportText="$commandReportText,${o_commandReport[$i]}"
  done
 commandReportText="${commandReportText:1:${#commandReportText}}"
  if [ $c_o_isRawOutput ]; then
    template="$o_command,$commandReportText\n"
  else
    template="Processed Command:\n$o_command\nOutput:\n$o_commandOutput\nReport:\n$c_o_parameterNamesList\n$c_r_parameterFunctionsList\n$commandReportText\n"
  fi
  printf "$template"
}

initialize_input "$@"
process_data
output
