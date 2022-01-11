#!/bin/bash
################################################################################
# Tagger                                                                       #
#                                                                              #
# Tagger is a simple Digital Resources Management System.                      #
# Tag resources (like files) and search for them in a semi-structured manner.  #
# Each resource has many tags which may follow certain conventions and are     #
# indexed in files pointing to their resources. Each resource type has one     #
# an action attached to it.                                                    #
#                                                                              #
# Type: To be used as a standalone.                                            #
# Dependencies: Bash.                                                          #
# Developed by: Muhammad Moneib.                                               #
################################################################################

## Initialization
declare -a typeActions;
pathForResources="$HOME/tagger/";
function checkForDirectory {
  if [ ! -d $1 ]; then
    mkdir $1
    echo "INFO: Resources directory created as $1."
  fi
}
function checkForFile {
  if [ ! -f $1 ]; then
    touch $1
    echo "INFO: Resources file created as $1."
  fi
}
function initializeTypeActions {
 typeActions["TagTextFile"]="cat";
}
checkForDirectory $pathForResources
checkForDirectory $pathForResources"objects/"
checkForDirectory $pathForResources"tags/"
checkForDirectory $pathForResources"tag_words/"
checkForFile $pathForResources"last_uid"}
initializeTypeActions

function updateLastUid {
  if [[ ! -z $(cat $pathForResources"last_uid") ]]; then
    lastUid=$(tail -1 $pathForResources"last_uid")
    echo "DEBUG: Last UID found to be $lastUid"
  else
    lastUid=0;
    echo "DEBUG: Last UID not found. Using 0 instead."
  fi
}

## Generic Tagging.
function tag {
  local object=$1;
  shift;
  local type=$1;
  local action=${typeActions["Tag"$type]};
  shift;
  local tags=();
  while [[ ! -z $1 ]]; do
    tags+=("$1");
    shift
  done
  # TODO Check if resource already exists.
  # TODO Allow spaces inside tags.
  updateLastUid;
  uid=$(($lastUid+1));
  echo "$uid" > $pathForResources"last_uid";
  checkForFile $pathForResources"objects/"$uid
  echo $($action "$object") > $pathForResources"objects/"$uid;
  checkForFile $pathForResources"tags/"$uid	
  for tag in ${tags[@]}; do
    checkForFile $pathForResources"tags/"$uid
    echo "$tag " >> $pathForResources"tags/"$uid
    checkForFile $pathForResources"tag_words/"$tag;
    echo "$uid" >> $pathForResources"tag_words/"$tag;
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
    if (( ${queried_objects[$k]} == $num_of_tags )); then
      latest_returned_objects+=("${queried_objects[$k]}");
    fi
  done
}

#TODO Paging in display.
#function displayObjects {
#  
#}

tag "$HOME/Chess.log" "TextFile" "Chess" "failure" "log"
