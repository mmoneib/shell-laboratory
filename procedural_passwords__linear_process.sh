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
#                 2- "even" for even capitals, "odd" for odd ones.             #
#     Name: invCaps                                                            #
#     Description: Inverse case of chars of a source.                          #
#     Parameters: 1- "alias" or "secret" indicating the text to manipulate.    #
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

#TODO Propagate error messages to help__actions?
#TODO Limit char rolling to only alphabet and numbers.

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
  altCapsParameterStmt="-a set_case_procedurally -t {1} -p {2]"
  invCapsParameterStmt="-a flip_case -t {1}"
  rollCharsParameterStmt="-a roll_chars -t {1} -o {2}"
  mixCharsParameterStmt="-a mix_chars -t {1} -T {2}"
  while getopts "ha:lp:s:" o; do
    case "$o" in
    ## A string or file containing the personal alias alluding to the target. Example: personal_google_account, MyGmail...etc.
    a) c_r_alias="$OPTARG" ;;
    ## The length of the password in chars. Defaults to 12.
    l) c_o_size="$OPTARG" ;;
    ## A semicolon-separated list string or file containing procedures and their parameters (separated by comma) for character manipulation in the specified order.
    p) c_r_procedures="$OPTARG" ;;
    ## A file containing the secret text. 
    s) c_r_secret="$OPTARG" ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  [ -z "$c_r_alias" ] && echo "ERROR: Missing required parameter 'alias'." >&2
  [ -z "$c_r_secret" ] && echo "ERROR: Missing required parameter 'secret'." >&2
  [ -z "$c_r_procedures" ] && echo "ERROR: Missing required parameter 'procedures'." >&2
  # Validation and stream preparation
  # TODO Move the validation to strings__actions action "contains" to loop over possibilities.
  [ -z "$(echo "$c_r_procedures"|grep "mixChars")" ] && echo "ERROR: One of the following procedures must be included for mixing aliases with secrets: mix_chars." >&2 && exit 1
  IFS=";"; read -a procedures  <<< "$c_r_procedures"
  commandsTokens=() # A single array provides flexibility as it is agnostic to the underlying commands and their order.
  for entry in "${procedures[@]}"; do
    IFS=","; read -a procedureTokens  <<< "$entry"
    #commandsTokens+=("${procedureTokens[1]}") # Indicating the variable to be manipulated by the commmand.
    if [ "${procedureTokens[0]}" != "altCaps" ] && [ "${procedureTokens[0]}" != "invCaps" ] && [ "${procedureTokens[0]}" != "rollChars" ] && [ "${procedureTokens[0]}" != "mixChars" ]; then
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
  # To get the last command in the loop below without having to simulate a do-while.
  commandsTokens+=("COMMAND") 
  commandsTokens+=("DUMMY") # Much more readable than post-loop retrieval of the last element. Indirect Programming.
  # Preparation of the commands.
  paramsValues=()
  isCommandStart="false"
  oldCommandNameToPrepare="" # The one for which $paramsValues are being prepared.
  currentCommandNameToPrepare=""
  d_varsAndCommands=() # 
  for ((i=0;i<${#commandsTokens[@]};i++)); do
    [ "${commandsTokens[i]}" == "COMMAND" ] && isCommandStart="true" && continue
    if [ "$isCommandStart" == "true" ]; then
      oldCommandNameToPrepare="$currentCommandNameToPrepare"
      currentCommandNameToPrepare="${commandsTokens[i]}"
      if [ ${#paramsValues[@]} -gt 0 ]; then
        paramStmtVar='$'"$oldCommandNameToPrepare""ParameterStmt" # Dynamic assignment of the command, for brevity. Metaprogramming.
        d_varsAndCommands+=("d_${paramsValues[0]}") # Values secret or alias.
        command=("$(eval echo $paramStmtVar)")
        c=0
        for param in ${paramsValues[@]}; do
          ((c++))
          if [ "$param" == "secret" ] || [ "$param" == "alias" ]; then
            param='$d_'"$param" # Passing as placeholder without valuation to allow cascaded processing over the same variable.
          fi 
          command=$(echo $command|sed "s/{$c}/\"$param\"/g")
        done
        d_varsAndCommands+=("$command")
        paramsValues=()
      fi
      isCommandStart="false"
    else
      paramsValues+=("${commandsTokens[i]}")
    fi
  done
  d_secret="$c_r_secret"
  d_alias="$c_r_alias"
}

function process_data {
  d_secret="$(echo "$d_secret"|sed 's/\ /_/g')" # Replacing spaces with underscores.
  d_alias="$(echo "$d_alias"|sed 's/\ /_/g')" # Replacing spaces with underscores.
  for ((i=0;i<${#d_varsAndCommands[@]};i=i+2)); do
    commandOpts="$(echo "${d_varsAndCommands[$((i+1))]}"|sed "s/\$d_secret/$d_secret/g"|sed "s/\$d_alias/$d_alias/g")"
    tmpResult="$(eval "sh string__actions.sh $commandOpts")"
    eval "${d_varsAndCommands[$i]}=\"$tmpResult\""
  done
  o_secret="$d_secret"
  o_alias="$d_alias"
  o_result="$tmpResult" # The output result is the output of the last of procedures.
}

function pretty_output {
  echo "Manipulated Alias: $o_alias"
  echo "Manipulated Secret: $o_secret"
  echo "Produced Password: $o_result"
}

function raw_output {
  echo "$o_result"
}

function output {
  if [ $c_isRawOutput ]; then
    raw_output
  else
    pretty_output
  fi
}

initialize_input "$@"
process_data
output
