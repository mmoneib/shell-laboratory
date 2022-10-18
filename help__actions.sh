#!/bin/sh
################################################################################
# Help Actions                                                                 #
#                                                                              #
# Actions to analyze code and display help and documentation accordingly.      #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     ~additional dependenies here~                                            #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

#TODO Combine common code between Process and Actions docs generation..
#TODO Make print line at the end of the help component (like optionalParamsListText) instead of in the beginning of each component.
#TODO Add actions for utlities help generation.

function print_incorrect_action_error {
  echo "Validation Error: The provided action is not available. Please check Help for more info.">&2
}

function print_missing_parameter_error {
  echo "Validation Error: Missing the '$p_o_parameter' parameter required for this action.">&2
  exit 1
}

## Print the usage statement for actions without exiting.
function print_actions_usage {
 [ -z "$p_o_fileContent" ] && p_o_fileContent="$(basename $0)"
 function __print_usage {
   #grep "$1" $p_o_fileContent |grep -v "grep -v"|sed s/\).*\#\#\ /\ /g|sed s/^\ *[\ ]/-/g |tr "\n" " "|sed s/\ $//g 
   grep -o ".) $1.*=" $p_o_fileContent|grep -v "grep -v"|sed "s/\(.\)) $1/-\1 /g"|sed "s/\([A-Z]\)/_\L\1/g"|sed "s/=$/_here/g"|tr '\n' ' '|sed "s/\ $//g"
 }
 requiredOptionsText="$(__print_usage 'p_r_')"
 optionalOptionsText="$(__print_usage 'p_o_')"
 echo "Usage: $p_o_fileContent $requiredOptionsText [$optionalOptionsText]"|sed s/\\[\\]//g
}

## Print the usage statement for actions without exiting.
function print_process_usage {
 [ -z "$p_o_fileContent" ] && p_o_fileContent="$(basename $0)"
 function __print_usage {
   #grep "$1" $p_o_fileContent |grep -v "grep -v"|sed s/\).*\#\#\ /\ /g|sed s/^\ *[\ ]/-/g |tr "\n" " "|sed s/\ $//g 
   grep -o ".) $1.*=" $p_o_fileContent|grep -v "grep -v"|sed "s/\(.\)) $1/-\1 /g"|sed "s/\([A-Z]\)/_\L\1/g"|sed "s/=$/_here/g"|tr '\n' ' '|sed "s/\ $//g"
 }
 requiredOptionsText="$(__print_usage 'c_r_')"
 optionalOptionsText="$(__print_usage 'c_o_')"
 echo "Usage: $p_o_fileContent $requiredOptionsText [$optionalOptionsText]"|sed s/\\[\\]//g
}

## Print extended help for Actions scripts, including general usage, input parameters, available actions, and their required parameters.
function print_actions_help {
  [ -z "$p_o_fileContent" ] && p_o_fileContent=$(basename $0)
  print_actions_usage
  fileText="$(cat $p_o_fileContent)"
  title="$(echo "$fileText"|head -3|tail -1|sed s/\#\ //g|sed s/\ *\#$//g)"
  descriptionText=""
  for ((ln=5;ln<10;ln++)); do # 10 is arbitrary but reasonable as the description should be in the first 10 lines.
    potentialDescriptionLine="$(echo "$fileText"|head -$ln|tail -1|sed s/\#\ //g|sed s/\ *\#$/\ /g)"
    [ " " == "$potentialDescriptionLine" ] && break
    descriptionText+="$potentialDescriptionLine"
  done
  requiredParamsListText=""
  while read l; do
    [ -z "$description" ] && description="$l" && continue
    [ -z "$parameter" ] && parameter="$l" && requiredParamsListText+="\t\t$parameter -> $description\n" && description="" && parameter=""
  done <<< "$(grep -v "grep" $p_o_fileContent|grep -B1 ") p_r_"|grep -v "\-\-"|sed "s/^.*\#\# //g"|sed "s/.*\([a-z,A-Z]\)\().*\)/\1/g")"
  [ ! -z "$requiredParamsListText" ] && requiredParamsListText="\n\tRequired Parameters:\n${requiredParamsListText:0:$((${#requiredParamsListText}-2))}"
  optionalParamsListText=""
  description=""
  parameter=""
  while read l; do
    [ -z "$description" ] && description="$l" && continue
    [ -z "$parameter" ] && parameter="$l" && optionalParamsListText+="\t\t$parameter -> $description\n" && description="" && parameter=""
  done <<< "$(grep -v "grep" $p_o_fileContent|grep -B1 ") p_o_"|grep -v "\-\-"|sed "s/^.*\#\# //g"|sed "s/.*\([a-z,A-Z]\)\().*\)/\1/g")"
  [ ! -z "$optionalParamsListText" ] && optionalParamsListText="\n\tOptional Parameters:\n${optionalParamsListText:0:$((${#optionalParamsListText}-2))}"
  actionsListText="\n\tActions:\n"
  while read l; do
    if [ "${l:0:2}" == "##" ]; then
      funcDesc="${l:2:${#l}}"
    elif [ "${l:0:8}" == "function" ]; then
      funcName="$(echo $l|sed s/function\ //g|sed s/\ \{//g)"
      if [ ! -z "$funcDesc" ] && [ ! -z "$funcName" ]; then
        actionsListText+="\t\t$funcName -> $funcDesc\n"
      fi  
      funcDesc=""
      funcName=""
    fi  
  done <<< "$(grep '^function' -B1 $p_o_fileContent|grep '##' -A1)"
  actionListText=${actionsListText:0:$((${#actionsListText}-2))}
  actionParamMatrix="\tAction/Parameter Matrix:\n"
  while read l; do
    # echo "${l:0:9}"
    if [ "${l:0:8}" == "function" ] && [ "${l:0:11}" != "function __" ]; then
      func="$(echo $l|sed "s/\(^function \)\(.*\)\( {.*\)/\2/g")"
      [ ! -z "$func" ] && actionParamMatrix+="\t\t$func --> "
    elif [ "${l:0:9}"  == "[ -z \"\$p_" ]; then
      param="$(echo $l|sed "s/\(^ *\[ -z \"\\$\)\(p_._.*\)\(\" \].*\)/\2/g")"
      param="$(grep ".) $param" $p_o_fileContent|sed "s/\(^.*\)\(.\))\(.*\)/\2/g")"
      [ -z "$(echo "$actionParamMatrix"|grep "$func.*$param,")" ] && actionParamMatrix+="$param,"
    elif [ "$l" == "}" ]; then
      [ ! -z "$func" ] && actionParamMatrix=${actionParamMatrix:0:$((${#actionParaMatrix}-1))}"\n"
      func=""
      param=""
   fi
 done <<< "$fileText"
actionParamMatrix=${actionParamMatrix:0:$((${#actionParamMatrix}-2))}
helpText="$title: $descriptionText$requiredParamsListText$optionalParamsListText$actionsListText$actionParamMatrix
"
  printf "$helpText"
  exit
}

## Print extended help for Process scripts, including description, general usage, aand configuration parameters.
function print_process_help {
  [ -z "$p_o_fileContent" ] && p_o_fileContent=$(basename $0)
  print_process_usage
  fileText="$(cat $p_o_fileContent)"
  title="$(echo "$fileText"|head -3|tail -1|sed s/\#\ //g|sed s/\ *\#$//g)"
  descriptionText=""
  for ((ln=5;ln<10;ln++)); do # 10 is arbitrary but reasonable as the description should be in the first 10 lines.
    potentialDescriptionLine="$(echo "$fileText"|head -$ln|tail -1|sed s/\#\ //g|sed s/\ *\#$/\ /g)"
    [ " " == "$potentialDescriptionLine" ] && break
    descriptionText+="$potentialDescriptionLine"
  done
  requiredParamsListText=""
  while read l; do
    [ -z "$description" ] && description="$l" && continue
    [ -z "$parameter" ] && parameter="$l" && requiredParamsListText+="\t\t$parameter -> $description\n" && description="" && parameter=""
  done <<< "$(grep -v "grep" $p_o_fileContent|grep -B1 ") c_r_"|grep -v "\-\-"|sed "s/^.*\#\# //g"|sed "s/.*\([a-z,A-Z]\)\() c_r_.*\)/\1/g")"
  [ ! -z "$requiredParamsListText" ] && requiredParamsListText="\n\tRequired Parameters:\n${requiredParamsListText:0:$((${#requiredParamsListText}-2))}"
  optionalParamsListText=""
  description=""
  parameter=""
  while read l; do
    [ -z "$description" ] && description="$l" && continue
    [ -z "$parameter" ] && parameter="$l" && optionalParamsListText+="\t\t$parameter -> $description\n" && description="" && parameter=""
  done <<< "$(grep -v "grep" $p_o_fileContent|grep -B1 ") c_o_"|grep -v "\-\-"|sed "s/^.*\#\# //g"|sed "s/.*\([a-z,A-Z]\)\() c_o_.*\)/\1/g")"
  [ ! -z "$optionalParamsListText" ] && optionalParamsListText="\n\tOptional Parameters:\n${optionalParamsListText:0:$((${#optionalParamsListText}-2))}"
  helpText="$title: $descriptionText$requiredParamsListText$optionalParamsListText"
  printf "$helpText"
  echo
  exit
}

[ -z $1 ] && print_actions_usage
# Parse options and parameters.
while getopts "ha:t:" o; do
  case $o in
    ## Action parameter indicates which function to be called.
    a) p_r_action=$OPTARG ;;
    ## Parameter parameter indicates the parameter fot which a help message to be generated.
    p) p_o_parameter=$OPTARG ;;
    ## FileContent parameter contains the path of the file whose Help needs to be generated.
    t) p_o_fileContent=$OPTARG $p_r_file_content ;;
    h) print_actions_help ;;
    *) print_actions_usage ;;
  esac
done
# Generic action call with positional parameters based on available ones.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
