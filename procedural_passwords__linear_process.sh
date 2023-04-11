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
#     Parameters: 1- "alias" or "secret" indicating the text to manipulate.    #
#                 2- 0 for even capitals, 1 for odd ones.                      #
#     Name: rollChars                                                          #
#     Description: Similar to a Caesar cipher, rolling chars based on unicode. #
#     Parameters: 1- "alias" or "secret" indicating the text to manipulate.    #
#                 2- Integer specifying the steps of the roll.                 #
#     Name: mixChars                                                           #
#     Description: Insert char of another string after each char of source.    #
#     Parameters: 1- "alias" or "secret" indicating the text to manipulate.    #
#                 2- Other string, "alias" or "secret"                         # 
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
  altCapsParameterStmt="-a flip_case -t {1}"
  rollCharsParameterStmt="-a roll_chars -t {1}"
  mixCharsParameterStmt="-a mix_chars -t {1}"
  while getopts "ha:p:s:" o; do
    case "$o" in
    ## A string or file containing the personal alias alluding to the target. Example: personal_google_account, MyGmail...etc.
    a) c_r_alias=$OPTARG ;;
    ## The length of the password in chars. Defaults to 12.
    l) c_o_size=$OPTARG ;;
    ## A semicolon-separated list string or file containing procedures and their parameters (separated by comma) for character manipulation in the specified order.
    p) c_r_procedures=$OPTARG ;;
    ## A file containing the secret text. 
    s) c_r_secret=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  [ -z "$c_r_alias" ] && echo "ERROR: Missing required parameter 'alias'." >&2
  [ -z "$c_r_secret" ] && echo "ERROR: Missing required parameter 'secret'." >&2
  [ -z "$c_r_procedures" ] && echo "ERROR: Missing required parameter 'procedures'." >&2
  # Validation and stream preparation
  IFS=";"; read -a procedures  <<< "$c_r_procedures"
  commandsTokens=() # A single array provides flexibility as it is agnostic to the underlying commands and their order.
  for entry in "${procedures[@]}"; do
    IFS=","; read -a procedureTokens  <<< "$entry"
    #commandsTokens+=("${procedureTokens[1]}") # Indicating the variable to be manipulated by the commmand.
    if [ "${procedureTokens[0]}" != "altCaps" ] && [ "${procedureTokens[0]}" != "rollChars" ] && [ "${procedureTokens[0]}" != "mixChars" ]; then
      echo "ERROR: Incorrect name of a procedure, ${procedureTokens[0]}'." >&2
      exit 1
    elif [ "${procedureTokens[1]}" != "alias" ] && [ "${procedureTokens[1]}" != "secret" ]; then
      echo "ERROR: Incorrect value of first parameter, ${procedureTokens[1]}; must be either the word 'secret' or 'alias'." >&2 && exit 1
    else
      commandsTokens+=("COMMAND") # Separator to emulate 2D array.
      for token in $entry; do
        commandsTokens+=("$token")
      done
    fi
  done
  # Preparation of the commands.
  paramsValues=""
  isCommandStart="false"
  oldCommandNameToPrepare="" # The one for which $paramsValues are being prepared.
  currentCommandNameToPrepare=""
  d_varsAndCommands=() # 
  for ((i=0;i<${#commandsTokens[@]};i++)); do
    [ "${commandsTokens[i]}" == "COMMAND" ] && isCommandStart="true" && continue
    if [ "$isCommandStart" == "true" ]; then
      oldCommandNameToPrepare="$currentCommandNameToPrepare"
      currentCommandNameToPrepare="${commandsTokens[i]}"
      if [ ! -z "$paramsValues" ]; then
        #TODO Add the first variable as key and add the text of the full comman after replacing the placeholders.
        paramStmtVar='$'"$oldCommandNameToPrepare""ParameterStmt" # Dynamic assignment of the command, for brevity.
        paramStmt="$paramStmtVar"
        d_varsAndCommands+=("$(eval echo $paramStmt)")
        paramsValues=""
      fi
      isCommandStart="false"
    else
      paramsValues+="${commandsTokens[i]},"
    fi
  done
  d_secret="$c_r_secret"
  d_alias="$c_r_alias"
}

function process_data {
  echo "${d_varsAndCommands[@]}"
  #~processing of data here~
  #~processing of data continued here~
  #~o_ variables initialization here~
}

function pretty_output {
  #~human readable and formatted output here~
  echo "Secret: $d_secret"
  echo "Alias: $d_alias"
}

function raw_output {
  #~plain data structural output here~
echo
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
