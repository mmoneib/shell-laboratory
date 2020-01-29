#!/bin/bash
###########################################################################
# A depth-first-search implementation with option to provide the order    #
# of putting, or removing the elements. This allows different utilities   #
# like searching from the root outwards (putting) or from the leaves      #
# inwards (removing).                                                     #
# This script is meant to be used on its own and as a sourcing one.       #
# Author: Muhammad Moneib                                                 #
###########################################################################

source stack__sourceable.sh;

declare -A dfs_alllChildrenMap; # Input: Should be associative array of element and their children as comma-serparated strings.
dfs_root=;  # Input: The name of the root element.
dfs_orderMode="Outwards"; # Default order is from the root outwards. Other possible values are "Inwards and "Both".
dfs_orderedExecution=(); # Output

function dfs_printOrderAfterSearch {
  st_print;
}

function dfs_search {
  declare -A dfs_visitedFringe; # The fringe containing all the visited nodes.
  st_put $dfs_root;
  [[ "$dfs_orderMode" == "Outwards" || "$dfs_orderMode" == "Both" ]] && dfs_orderedExecution+=($st_topElement);
  while (true); do
    dfs_currentChildrenArr=(); # Show the current children being checked.
    for ((i=1;;i++)); do  # Loop to parse a comma-separated string into an array.
      tmpCut=$(cut -d "," -f $i <<< ${dfs_alllChildrenMap[$st_topElement]});
      if [[ ! -z $tmpCut ]]; then
        dfs_currentChildrenArr[(($i-1))]=$tmpCut;
      else
        break;
      fi
    done
    if [[ ! -z ${dfs_visitedFringe[$st_topElement]} ]] || [[ "${#dfs_currentChildrenArr[@]}" == "0" ]]; then
      [[ "$dfs_orderMode" == "Inwards" || "$dfs_orderMode" == "Both" ]] && dfs_orderedExecution+=($st_topElement);
      st_remove;
      if [[ -z $st_topElement ]]; then
        break; # Base case, when the stack is empty.
      else
        continue;
      fi
    fi
    dfs_visitedFringe[$st_topElement]=1; # Mark visited nodes. Nodes without children are not marked as it is not needed.
    for ((i=${#dfs_currentChildrenArr[@]}-1;i>=0;i--)); do # Reversed to keep the order of the siblings.
      st_put ${dfs_currentChildrenArr[$i]};
      [[ "$dfs_orderMode" == "Outwards" || "$dfs_orderMode" == "Both" ]] && dfs_orderedExecution+=($st_topElement);
    done
  done
}

#TODO Add test case.
#TODO Add the ability to injecct functionality.
