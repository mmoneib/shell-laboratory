#!/bin/sh
################################################################################
# Text Actions                                                                 #
#                                                                              #
# ~extensive description of script here~                                       #
#                                                                              #
# Type: Actions            .                                                   #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     ~additional dependenies here~                                            #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.

usage="Usage: ./~script name here.sh~ -a action_name_here ~additional optional actions here~ ~repitition~"
help="~description of script here~.
  Parameters:
    ~parameter character here~ -> ~description of parameter here~.
    ~repition~
  Actions
    ~action function name here~ -> ~action description here~.
    ~repitition~
  Action/Parameter Matrix:
    ===========================================================================
    | Action / Parameter          | ~parameter character here! | ~repitition~ |
    ===========================================================================
    | ~action function name here~ | ~asterisk if used here~    | ~repitition~ |
    ---------------------------------------------------------------------------
    | ~repitiition~               | ~repitiition~              | ~repitiition~|
    ---------------------------------------------------------------------------
"

function print_usage {
  echo $usage
  exit 1
}

function print_help {
  echo "$usage"
  printf "$help"
  exit
}

function magnify_text {
  [ -z ~parameter variable here~ ] && ~parameter variable here~="~function positional parameter here~"
  ~action implementation here~
}

~repitition~

if [ "$1" != "skip_run" ]; then
  while getopts "~getopts parameter string here~" o; do
    case $o in
      a) action=$OPTARG ;;
      t) text=$OPTARG
      h) print_help ;;
      *) print_usage ;;
    esac
  done
  # Generic action call with positional parameters based on available ones.
  $action ~parameter variable here~ ~repitition~
fi
