#!/bin/sh
################################################################################
# Experimenter                                                                 #
#                                                                              #
# A process to execute a command in successive iterations with optional        #
# variation of its input parameters and perform aggregate functions on the     #
# output.                                                                      #
#                                                                              #
# Type: Yielding Process.                                                      #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     ~additional dependenies here~                                            #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c_r for required config, c_o for opritonal config, d for data, and o for output.

#TODO Save output without DEBUG to default path with a descriptive filename.

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
    ## Comma-separated lists of functions to be performed on each corresponding parameter (i.e. first funciton for first parameter...etc.). Supported functions are 'sum' and 'average'.
    f) c_r_parameterFunctionsList=$OPTARG ;; 
    ## Number of iterations in which the command will be executed and upon which aggregation will be done.
    i) c_r_numOfIterations=$OPTARG ;;
    ## Optional comma-separated list of names specifying the corresponding parameters, for reporting purposes.
    n) c_o_parameterNamesList=$OPTARG ;;
    ## Semicolon-separated list of comam-separated parameter value lists; each parameter will replace the corresponding placeholder in the command specified.
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
  IFS=, read -a d_parameterFunctionsLists <<< "$c_r_parameterFunctionsList"
  IFS=, read -a d_parameterValuesLists <<< "$(echo $c_r_parameterValuesList|tr "," "\`"|tr ";" ","|tr "\`" ";")" # Until string__action separator is fixed to default to ,.
  o_count=0
  #~hooks for adding a certain behaviour at a specific event (like trapping EXIT to clear)~
}

function process_data {
  for (( t=0; t<${#d_parameterValuesLists[@]}; t++ )); do
    command="$(./string__actions.sh -a replace_positional_placeholders -t "$c_r_command" -l "${d_parameterValuesLists[$t]}")"
    [ ! -z $c_o_isDebug ] && echo "DEBUG(evaluated_command): $command"
    allOutput=""
    for (( i=0; i<c_r_numOfIterations; i++ )); do
      output="$(eval "$command"|tail -1)"
      allOutput="$allOutput$output\n"
      [ ! -z $c_o_isDebug ] && echo "DEBUG(command_iterative_count): $i"
      [ ! -z $c_o_isDebug ] && echo "DEBUG(output_count): $o_count"
      [ ! -z $c_o_isDebug ] && echo "DEBUG(command_iterative_output): $output"
    done
    toBeAggregatedLists=()
    while read line; do
      IFS=, read -a tokens <<< "$line"
      for (( i=0; i<${#tokens[@]}; i++ )); do
        toBeAggregatedLists[$i]+="${tokens[$i]},"
      done
    done <<< "$(printf $allOutput)" # Using "printf" allows "read" to interpret \n as new line. 
    o_commandReport=()
    for (( i=0; i<${#d_parameterFunctionsLists[@]}; i++ )); do
      o_commandReport[$i]="$(./math__actions.sh -a ${d_parameterFunctionsLists[$i]} -l ${toBeAggregatedLists[$i]})"
    done
    o_command="$command"
    o_commandOutput="${allOutput:0:$(( ${#allOutput}-2 ))}" # Removes "\n"
    output
  done
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
  o_count=$(( o_count+1 ))
  [ -z $c_o_isRawOutput ] && printf "********************\n" # Separator between reports.
}

initialize_input "$@"
process_data
