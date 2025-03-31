#!/bin/sh
################################################################################
# Tag Actions                                                                  #
#                                                                              #
# A set of fanctions for enhancing files with searchable metadata.             #    
#                                                                              #
# Type: Actions                                               .                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

#TODO Add incorrect parameter error.
#TODO Make reading arrays work for zsh.

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
  [ -z "$p_r_tags" ] &&  __print_missing_parameter_error "tags"
  tagFilePath="$(dirname $p_r_path)/.$(basename $p_r_path)__tags"
  if [ ! -f "$tagFilePath" ]; then
    touch $tagFilePath
  fi
  IFS=,; read -a tagsArr <<< "$p_r_tags"
  newTagsStr="$separator"
  for (( i=0; i<${#tagsArr[@]}; i++ )); do
    if [ ! -z "${tagsArr[i]}" ] && [ -z "$(grep "${tagsArr[i]}" $tagFilePath)" ]; then
      newTagsStr="$newTagsStr${tagsArr[i]}$separator" # Consecutive separators will eventually transfor to a single empty tag, thanls to 'tr' command.
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
  [ -z "$p_r_tags" ] &&  __print_missing_parameter_error "tags"
  IFS=,; read -A tagsArr <<< "$p_r_tags"
  tagsStr=","
  for (( i=0; i<${#tagsArr[@]}; i++ )); do
    tagsStr="$p_r_tagsStr${tagsArr[i]}"
  done
  grep -l "$p_r_tagsStr" --include "*__tags" 2>/dev/null # Divert error messages away.
}

## Remived the specified list of tags from the specified file's metadata.
function remove_tag_from_file {
  [ -z "$p_r_path" ] &&  __print_missing_parameter_error "path"
  [ -z "$p_r_tags" ] &&  __print_missing_parameter_error "tags"
  tagFilePath="$(basename $p_r_path)\.$(dirname $p_r_path)__tags"
  IFS=,; read -A tagsArr <<< "$p_r_tags"
  for (( i=0; i<${#tagsArr[@]}; i++ )); do
    sed -i '' "s/$separator${tags[i]}$separator//g" $tagFilePath # Tags are removed separately as they might not lie consecutively.
  done
}

[ -z "$1" ] && __print_usage
# Check if input is piped.
read -t 0.1 inp; # Doesn't read more than a line.
if [ ! -z "$inp" ]; then
  p_r_tags="$inp"
  while read inp; do
    p_r_tags+="\n$inp"
  done 
fi
separator=","
# Parse options and parameters.
while getopts "a:p:t:h" inp; do
  case $inp in
    # Action to be performed.
    a) p_r_action=$OPTARG ;;
    # The path of the file to be tagged or the directory to be searched. 
    p) p_r_path=$OPTARG ;;
    # A comma-separated list of tags.
    t) p_r_tags=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && __print_incorrect_action_error

# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ]  && $p_r_action || __print_incorrect_action_error
