#!/bin/bash
################################################################################
# Tagger is a simple Digital Resources Management System.
# Tag resources (like files) and search for them in a semi-structured manner.
# Each resource has many tags which may follow certain conventions and are 
# indexed in files pointing to their resources. Each resource type has one 
# an action attached to it.
#
# Developer: Muhammad Moneib
################################################################################

declare -a typeActions;
pathForResources="resources/tagger/";

function initializeTypeActions {
 actions["TagTextFile"]=cat;
}

function getLastUid {
  if [[ ! -z $pathForResources"last_uid" ]]; then
    echo $pathForResources"last_uid";
  else
    echo 0;
  fi
}

## Underlying, generic tagging implementation.
function tag {
  local object=$1;
  shift;
  local type=$2;
  local action=${typeActions["Tag"$type]};
  shift;
  local tags=();
  while [[ -z $3 ]]; do
    tags+=$1;
  done
  # TODO Check if resource already exists.
  last_uid=$(getLasUid);
  uid=$((last_uid+1));
  $uid > $pathForResources"last_uid";
  $type > $uid;
  $action $object >> $pathForResource"objects/"$uid;
  ${tags[@]} > $pathForResources"objects/"$uid"_tags";
  for tag in ${tags[@]}; do
    echo "$uid" >> $pathForResources"tags/"$tag;
  done
}

function searchObjectsByTags {
  declare -a queried_objects;
  latest_returned_objects=();
  local num_of_tags=${#@};
  local c=0;
  while [[ ! -z $1 ]]; do
    # TODO Optimize line reading.
    current_count=echo ${queried_objects[$(head -$c $pathForResources"tags/"$1 | tail -1)]};
    queried_objects[$(head -$c $pathForResources"tags/"$1 | tail -1)]=[[ -z $current_count ]] && 0 || $((current_count+1));
  done
  for k in ${!queriedObject[@]}; do
    if (( ${queried_objects[$k]} == $num_of_tags )); do
      latest_returned_objects+=("${queried_objects[$k]}");
    done
  done
}

#TODO Paging in display.
function displayObjects {
  
}

