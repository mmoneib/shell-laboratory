#!/bin/sh
################################################################################
# Help Actions                                                                 #
#                                                                              #
# Actions to analyze code and display help and documentation accordingly.      #
#                                                                              #
# Type: Actions            .                                                   #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     ~additional dependenies here~                                            #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.

## Print the usage statement without exiting.
function print_actions_usage {
 [ -z "$p_r_fileContent" ] && p_r_fileContent="$1"
 [ -z "$p_r_fileContent" ] && p_r_fileContent="$(basename $0)"
 function __print_usage {
   #grep "$1" $p_r_fileContent |grep -v "grep -v"|sed s/\).*\#\#\ /\ /g|sed s/^\ *[\ ]/-/g |tr "\n" " "|sed s/\ $//g 
   grep -o ".) $1.*=" $p_r_fileContent|grep -v "grep -v"|sed "s/\(.\)) $1/-\1 /g"|sed "s/\([A-Z]\)/_\L\1/g"|sed "s/=$/_here/g"|tr '\n' ' '|sed "s/\ $//g"
 }
 requiredOptionsText="$(__print_usage 'p_r_')"
 optionalOptionsText="$(__print_usage 'p_o_')"
 echo "Usage: $p_r_fileContent $requiredOptionsText [$optionalOptionsText]"|sed s/\\[\\]//g
}

## Print the usage statement while exiting.
function print_actions_usage_exiting {
 [ -z "$p_r_fileContent" ] && p_r_fileContent="$1"
 [ -z "$p_r_fileContent" ] && p_r_fileContent="$(basename $0)"
  print_actions_usage
  exit 1
}

## Printed extended help include basic general usage, available actions, and their required parameters.
function print_actions_help {
  [ -z "$p_r_fileContent" ] && p_r_fileContent="$1"
  [ -z "$p_r_fileContent" ] && p_r_fileContent=$(basename $0)
  print_actions_usage
  fileText="$(cat $p_r_fileContent)"
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
  done <<< "$(grep -v "grep" $p_r_fileContent|grep -B1 ") p_r_"|grep -v "\-\-"|sed "s/^.*\#\# //g"|sed "s/.*\([a-z,A-Z]\)\().*\)/\1/g")"
  [ ! -z "$requiredParamsListText" ] && requiredParamsListText="\n\tRequired Parameters:\n${requiredParamsListText:0:$((${#requiredParamsListText}-2))}"
  optionalParamsListText=""
  description=""
  parameter=""
  while read l; do
    [ -z "$description" ] && description="$l" && continue
    [ -z "$parameter" ] && parameter="$l" && optionalParamsListText+="\t\t$parameter -> $description\n" && description="" && parameter=""
  done <<< "$(grep -v "grep" $p_r_fileContent|grep -B1 ") p_o_"|grep -v "\-\-"|sed "s/^.*\#\# //g"|sed "s/.*\([a-z,A-Z]\)\().*\)/\1/g")"
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
  done <<< "$(grep '^function' -B1 $p_r_fileContent|grep '##' -A1)"
  actionListText=${actionsListText:0:$((${#actionsListText}-2))}
  actionParamMatrix="\tAction/Parameter Matrix:\n"
  while read l; do
    #echo "${l:0:8}"
    if [ "${l:0:8}" == "function" ] && [ "${l:0:11}" != "function __" ]; then
      func="$(echo $l|sed "s/\(^function \)\(.*\)\( {.*\)/\2/g")"
      [ ! -z "$func" ] && actionParamMatrix+="\t\t$func --> "
    elif [ "${l:0:9}"  == "[ -z \"\$p_" ]; then
      param="$(echo $l|sed "s/\(^ *\[ -z \"\\$\)\(p_._.*\)\(\" \].*\)/\2/g")"
      param="$(grep ".) $param" $p_r_fileContent|sed "s/\(^.*\)\(.\))\(.*\)/\2/g")"
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

while getopts "a:t:h" o; do
  case $o in
    ## Action parameter indicates which function to be called.
    a) p_r_action=$OPTARG ;;
    ## FileContent parameter contains the path of the file whose Help needs to be generated.
    t) p_r_fileContent=$OPTARG $p_r_file_content ;;
    h) print_actions_help ;;
    *) print_actions_usage_exiting ;;
  esac
done
[ -z $1 ] && print_actions_usage_exiting
# Generic action call with positional parameters based on available ones.
$p_r_action $p_r_fileContent
