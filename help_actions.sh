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
 [ -z $p_r_fileContent ] && p_r_fileContent="$1"
 [ -z $p_r_fileContent ] && p_r_fileContent="$(basename $0)"
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
 [ -z $p_r_fileContent ] && p_r_fileContent="$1"
 [ -z $p_r_fileContent ] && p_r_fileContent="$(basename $0)"
  print_actions_usage
  exit 1
}

## Printed extended help include basic general usage, available actions, and their required parameters.
function print_actions_help {
  [ -z $p_r_fileContent ] && p_r_fileContent="$1"
  [ -z $p_r_fileContent ] && p_r_fileContent=$(basename $0)
  print_actions_usage
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
  actionsListText=""
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
  fileText="$(cat $p_r_fileContent)"
  descriptionText=""
  for ((ln=5;ln<10;ln++)); do # 10 is arbitrary but reasonable as the description should be in the first 10 lines.
    potentialDesciptionLine="$(echo "$fileText"|head -$ln|tail -1|sed s/\#\ //g|sed s/\ *\#$/\ /g)"
    [ " " == "$potentialDescriptionLine" ] && break
    descriptionText+="$potentialDescriptionLine"
 done
 helpText="$(echo "$fileText"|head -3|tail -1|sed s/\#\ //g|sed s/\ *\#$//g): $descriptionText$requiredParamsListText$optionalParamsListText
\tActions:
${actionsListText:0:$((${#actionsListText}-2))}
\tAction/Parameter Matrix:
\t\t===========================================================================
\t\t| Action / Parameter          | ~parameter character here! | ~repitition~ |
\t\t===========================================================================
\t\t| ~action function name here~ | ~asterisk if used here~    | ~repitition~ |
\t\t---------------------------------------------------------------------------
\t\t| ~repitiition~               | ~repitiition~              | ~repitition~ |
\t\t---------------------------------------------------------------------------
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
