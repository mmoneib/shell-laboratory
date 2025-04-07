#!/bin/sh
################################################################################
# Tag Actions                                                                  #
#                                                                              #
# A set of fanctions for enhancing files with searchable metadata.             #    
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

#TODO Add incorrect parameter error.
#TODO Add prefix for constants.

function __print_usage {
  sh $(dirname $0)/help__actions.sh -a print_actions_usage -t $0
  exit
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_actions_help -t $0
  exit
}

function __print_missing_parameter_error {
  sh $(dirname $0)/help__actions.sh -a print_missing_parameter_error -p $1
  exit 1
}

function __print_incorrect_action_error {
  sh $(dirname $0)/help__actions.sh -a print_incorrect_action_error
  exit 1
}

## Appends the specified list of tags to the specified file's metadata.
function add_tag_to_file {
  [ -z "$p_r_path" ] &&  __print_missing_parameter_error "path"
  [ -z "$p_o_tags" ] &&  __print_missing_parameter_error "tags"
  tagFilePath="$(dirname $p_r_path)/.$(basename $p_r_path)$tagsFilePostfix"
  if [ ! -f "$tagFilePath" ]; then
    touch $tagFilePath
  fi
  IFS=,; read -a tagsArr <<< "$p_o_tags"
  newTagsStr="$separator"
  for (( i=0; i<${#tagsArr[@]}; i++ )); do
    if [ ! -z "${tagsArr[i]}" ] && [ -z "$(grep "$separator${tagsArr[i]}$separator" $tagFilePath)" ]; then # Validate the tag and prevent duplication.
      newTagsStr="$newTagsStr${tagsArr[i]}$separator" # Consecutive separators will eventually transfor to a single empty tag, thanks to 'tr' command.
    fi
  done
  [ "$newTagsStr" == "," ] && newTagsStr=""
  oldTagsStr="$(cat $tagFilePath)"
  tagsStr="$(echo "$newTagsStr$oldTagsStr"|tr "$separator" '\n'|sort|tr '\n' "$separator")" # Sort all tags before persistence.
  tagsStr="$(echo "$tagsStr"|sed "s/$separator$separator/$separator/g"|sed "s/$separator$separator/$separator/g")" # Remove accumulation of separator from 'tr' operation.
  echo "$tagsStr" > $tagFilePath
  echo "File: $p_r_path"
  echo "Tags: $tagsStr"
}

## Search for files whose metadata include the specified tags.
function find_files_with_tags {
  [ -z "$p_r_path" ] &&  __print_missing_parameter_error "path"
  [ -z "$p_o_tags" ] &&  __print_missing_parameter_error "tags"
  sortedTagsStr="$(echo "$p_o_tags"|tr ',' '\n'|sort|tr '\n' ',')"
  IFS=,; read -a tagsArr <<< "$sortedTagsStr"
  queryCommand="grep -H '$separator${tagsArr[0]}$separator' $p_r_path/.*$tagsFilePostfix 2>/dev/null" # Divert error messages away.
  for (( i=1; i<${#tagsArr[@]}; i++ )); do
    queryCommand+="|grep '$separator${tagsArr[i]}$separator'" # Single quotes to deny scrip tinjection.
  done
  queryCommand+="|cut -d : -f 1|sed 's/\/\.\(.*\)$tagsFilePostfix/\/\1/g'"
  echo "Executing the command $queryCommand"
  eval "$queryCommand"
}


## Gets the value of the specified key of key=value tag associated with the specified file.
function get_tagged_value_of_file {
  [ -z "$p_r_path" ] &&  __print_missing_parameter_error "path"
  [ -z "$p_o_tags" ] &&  __print_missing_parameter_error "tags"
  tagFilePath="$(dirname $p_r_path)/.$(basename $p_r_path)$tagsFilePostfix"
  value="$(cat $tagFilePath|tr "$separator" '\n'|grep $p_o_tags'='|cut -d '=' -f 2)"
  echo "$value"
}

function __get_tags_file_path {
  path=$1
  echo "$(dirname $path)/.$(basename $path)$tagsFilePostfix" 
}

## Show the combined sorted list of all unique tags used across all files in the specified directory.
function list_all_tags {
  [ -z "$p_r_path" ] &&  __print_missing_parameter_error "path"
  tagsList="$(cat $p_r_path"/".*$tagsFilePostfix|tr -d '\n'|tr ',' '\n'|sort|uniq)"
  echo "${tagsList:1}" # Skipping the first character which is an empty line.
}

## Remove the specified list of tags from the specified file's metadata.
function remove_tag_from_file {
  [ -z "$p_r_path" ] &&  __print_missing_parameter_error "path"
  [ -z "$p_o_tags" ] &&  __print_missing_parameter_error "tags"
  tagFilePath="$(dirname $p_r_path)/.$(basename $p_r_path)$tagsFilePostfix"
  IFS=,; read -a tagsArr <<< "$p_o_tags"
  for (( i=0; i<${#tagsArr[@]}; i++ )); do
    sed -i '' "s/$separator${tagsArr[i]}$separator/$separator/g" $tagFilePath # Tags are removed separately as they might not lie consecutively.
  done
  tagsStr="$(cat $tagFilePath)"
  echo "File: $p_r_path"
  echo "Tags: $tagsStr"
}

## Report all files and their tags of the specified directory as one document.
function report_files_and_tags {
  [ -z "$p_r_path" ] &&  __print_missing_parameter_error "path"
  echo "--BEGIN-REPORT------"
  while read inp; do
    echo "--------------------"
    filePath="$p_r_path/$inp"
    echo "File: $filePath"
    cat $filePath
    tagsFilePath="$(__get_tags_file_path $filePath)"
    echo "Tags file: $tagsFilePath"
    cat $tagsFilePath
    echo "--------------------"
  done <<< "$(ls -1 $p_r_path|sort -n)"
  echo "--END-REPORT--------"
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  p_o_tags="$inp"
  while read inp; do
    p_o_tags+="\n$inp"
  done 
fi
# Constants
separator=","
tagsFilePostfix="__tags"
# Parse options and parameters.
while getopts "a:p:t:h" inp; do
  case $inp in
    ## Action to be performed.
    a) p_r_action=$OPTARG ;;
    ## The path of the file to be tagged or the directory to be searched. 
    p) p_r_path=$OPTARG ;;
    ## A comma-separated list of tags.
    t) p_o_tags=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && __print_incorrect_action_error

# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ]  && $p_r_action || __print_incorrect_action_error
