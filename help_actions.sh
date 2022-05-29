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

usage="Usage: $(basename $0) -a action_name_here ~additional optional actions here~ ~repitition~"

## Print the usage statement. 
function print_actions_usage {
  echo "$usage"
  exit 1
}

## Printed extended help include basic general usage, available actions, and their required parameters.
function print_actions_help {
 [ -z $text ] && text="$1"
 [ -z $text ] && text=$(basename $0)
 echo "$usage"
 aht=""
  while read l; do
    if [ "${l:0:2}" == "##" ]; then
      ca="${l:2:${#l}}"
    elif [ "${l:0:8}" == "function" ]; then
      cd="$(echo $l|sed s/function\ //g|sed s/\ \{//g)"
      if [ ! -z "$ca" ] && [ ! -z "$cd" ]; then
        aht+="\t\t$cd -> $ca\n"
      fi  
      ca=""
      cd=""
    fi  
  done <<< "$(grep '^function' -B1 $text|grep '##' -A1)"
  f="$(cat $text)"
  dht=""
  for ((ln=5;ln<10;ln++)); do
    pl="$(echo "$f"|head -$ln|tail -1|sed s/\#\ //g|sed s/\ *\#$/\ /g)"
    dht+="$pl"
    [ " " == "$pl" ] && break
  done
  h="$(echo "$f"|head -3|tail -1|sed s/\#\ //g|sed s/\ *\#$//g): $dht
\tParameters:
\t\t~parameter character here~ -> ~description of parameter here~.
\t\t~repition~
\tActions
${aht:0:$((${#aht}-2))}
\tAction/Parameter Matrix:
\t\t===========================================================================
\t\t| Action / Parameter          | ~parameter character here! | ~repitition~ |
\t\t===========================================================================
\t\t| ~action function name here~ | ~asterisk if used here~    | ~repitition~ |
\t\t---------------------------------------------------------------------------
\t\t| ~repitiition~               | ~repitiition~              | ~repitiition~|
\t\t---------------------------------------------------------------------------
"
  printf "$h"
  exit
}

if [ "$1" != "skip_run" ]; then
  while getopts "a:t:h" o; do
    case $o in
      a) action=$OPTARG ;;
      t) text=$OPTARG ;;
      h) print_actions_help ;;
      *) print_actions_usage ;;
    esac
  done
  # Generic action call with positional parameters based on available ones.
  $action $text
fi
