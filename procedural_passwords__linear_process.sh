#!/bin/sh
################################################################################
# Procedural Passwords                                                         #
#                                                                              #
# A password generator based on an alias, a secret text, and a customizable    #
# procedure of successive manipulations. The aim is to generate passwords      #
# which are hard for a computer to guess, yet easy for a human to deduce.      #
# Available procedures are:                                                    #
#     Name: altCaps                                                            #
#     Description: Alternate case of chars of a source.                        #
#     Parameters: 0 for even capitals, 1 for odd ones.                         #
#     Name: rollChars                                                          #
#     Description: Similar to a Caesar cipher, rolling chars based on unicode. #
#     Parameters: Integer specifying the steps of the roll.                    #
#     Name: mixChars                                                           #
#     Description: Insert char of another string after each char of source.    #
#     Parameters: Other string.                                                # 
# The order in which those procedures are specified is imporant and affects    #
# the outcome passowrd. Each procedure produces a string which becomes the     #
# input for the next one, starting with the alias as the source.               #
#                                                                              #
# Type: Linear Process.                                                        #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     string__actions.                                                         #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c for config, d for data, and o for output.

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
  c_o_noCaps="false"
  c_o_noChars="false"
  c_o_noNums="false"
  c_o_noSpecial="false"
  c_o_size=12
  while getopts "ha:p:s:" o; do
    case "$o" in
    ## A string or file containing the alias alluding to the target. Example: personal_google_account.
    a) c_r_alias=$OPTARG ;;
    ## The length of the password in chars. Defaults to 12.
    l) c_o_size=$OPTARG ;;
    ## A comma-separated list string or file containing procedures and their parameters for character manipulation in the specified order.
    p) c_r_procedures=$OPTARG ;;
    ## A string or file containing the secret text. 
    s) c_r_secret=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  ~options validation here~
  ~d_ variables (mutable by process_data) initialization here~
  ~o_ variables (immutable) initialization here~
  ~hooks for adding a certain behavour at a specific event (like trapping EXIT to clear)~
}

function process_data {
  ~processing of data here~
  output
  ~processing of data continued here~
  ~o_ variables initialization here~
}

function pretty_output {
  ~human readable and formatted output here~
}

function raw_output {
  ~plain data structural output here~
}

function output {
  if [ $c_isRawOutput ]; then
    raw_output
  else
    pretty_output
  fi
}

initialize_input $@
process_data
output
