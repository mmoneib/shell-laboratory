#!/bin/bash
##################################################################################
# A parser of raw files which takes care of division into chunks and repetitions
# and detecting repetitions based on a given format. The purpose is to allow the
# user to visualize and stream the raw data and uses it as he wants without 
# a fuss and in a simple way.
# Author: Muhammad Moneib
##################################################################################

source check_option_parameter__sourced.sh;
source depth_first_search__sourceable.sh;

declare -A childrenMap; # Hashmap
declare -A repetitionMap; # Hashmap
declare -A referenceRepetitionMap; # Hashmap to kepp the original values of repetitions immutable.
declare -A sizeMap; # Hashmap
declare -A levelMap; # Hashmap

cop_getValueForOption "t"
_erf_template=cat $cop_optionValue;
cop_getValueForOption "s"
_erf_static=cat $cop_optionValue;
cop_doesThisOptionExist "test";
_erf_isTest=$cop_hasOption;
cop_doesThisOptionExist "verbose_out";
_erf_isVerboseOut=$cop_hasOption;

function buildFileTree {
  currentParents=();
  currentParents[0]="RootElement";
  currentLevel=0;
  while read inp; do
    elementName=$(cut -d ',' -f 2 <<< $inp);
    if [[ -z $elementName ]]; then
      continue;
    fi
    currentLevel=$(cut -d ',' -f 1 <<< $inp);
    elementSize=$(cut -d ',' -f 3 <<< $inp);
    elementRepeatability=$(cut -d ',' -f 4 <<< $inp);
    currentParents[$currentLevel]=$elementName; # Can overwrite.
    parent=${currentParents[(($currentLevel-1))]}; # The parent from the level above.
    if [[ ! -z $parent ]]; then
      childrenMap[$parent]+=$elementName",";
    fi
    repetitionMap[$elementName]=$([[ -z $elementRepeatability ]] && echo 1 || echo $elementRepeatability);
    sizeMap[$elementName]=$elementSize;
    levelMap[$elementName]=$currentLevel;
  done
} <<< $_erf_template;

function copyAssociativeArray { #TODO Source into array utils.
  for k in "${!repetitionMap[@]}"; do
    referenceRepetitionMap[$k]=${repetitionMap[$k]};
  done
}

function prepareForDfs {
  dfs_root="RootElement";
  declare -n dfs_alllChildrenMap=childrenMap;
  dfs_orderMode="Inwards";
  dfs_search;
}

function echoFile { # Expects a string streamed by <<< or piped.
  for ((i=0;i<${#dfs_orderedExecution[@]};i++)) do
    element=${dfs_orderedExecution[$i]};
    sizeToRead=${sizeMap[$element]};
    if ((${#childrenMap[$element]}==0)); then # Size only matters for the leaf nodes. The rest is discarded.
        count=${repetitionMap[$element]}; # Repetitions fpr leaf nodes are dealt with immediately, so they need not keep a state.
       while (( $count >= 1 )); do
          read -N $sizeToRead out;
          if [[ $_erf_isVerboseOut == true ]]; then
            echo $element
          fi
          echo $out;
          count=$(($count-1)); 
       done
    else
      repetitionMap[$element]=$((${repetitionMap[$element]}-1)); 
      if [[ "${repetitionMap[$element]}" == "n" ]]; then
        echo "Repeat indefinitely or till a mark." #TODO
      elif (( ${repetitionMap[$element]} >= 1 )); then 
        elementLevel=${levelsMap[$element]};
        tempLevel=${levelMap[${dfs_orderedExecution[$i]}]};
        for ((j=$i;j>=0;j--)); do
          if (($j==0 || ${levelMap[${dfs_orderedExecution[$((j-1))]}]}<=$tempLevel)); then
            i=$(($j-1));
            break;
          fi
        done	
      else
        repetitionMap[$element]=${referenceRepetitionMap[$element]}; # Reset for case of non-leaf node to be repeated due to parent.
      fi
    fi
  done
} <<< $_erf_static;

if [[ $_erf_isTest == true ]]; then
  _erf_template="1,Header,2,
1,Body,,
2,Chunk,,6
3,ChunkHeader,1,
3,Data,4,2
1,Tailer,,
2,TailerChunk,,8
3,TailerChunkHeader,3,
4,TailerChunkData,,4
5,TailerChunkDataHeader,4,
5,TailerChunkDataTail,1,2";
  buildFileTree;
  copyAssociativeArray;
  prepareForDfs;
  echo "Order of execution is ${dfs_orderedExecution[@]}."
  _erf_static="00110001000000000000000001000000001110101000000001111111110101001001010101011110010010010101000101001101010001010101010010101000000000000000000001010101110101011000101010100001010111010101111111111110111100000011101010100101010011";
  echoFile; 
  exit;
fi

buildFileTree;
copyAssociativeArray;
prepareForDfs;
echoFile;
