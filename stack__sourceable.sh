#!/bin/bash
###########################################################################
# A simple stack implementation with the pointer pointing to the space    #
# above the top-most element.                                             #
# This script is meant to be used on its own and as a sourcing one.       #
# Author: Muhammad Moneib                                                 #
###########################################################################

st_stackArr=();
st_topElement=;
st_pointer=0;

function st_put {
  st_topElement=$1;
  st_stackArr[$st_pointer]=$st_topElement;
  ((st_pointer++));
}

function st_remove {
  ((st_pointer--));
  st_stackArr[$st_pointer]=;
  if [[ $st_pointer < 0 ]]; then
    st_pointer=0;
  fi
  st_topElement=${st_stackArr[(($st_pointer-1))]};
}

function st_print {
  echo ${st_stackArr[@]};
}

function st_test {
  st_stackArr=();
  st_put "A";
  st_put "B";
  st_put "C";
  st_remove;
  [[ "$(echo $st_topElement)" == "B" ]] && echo true || echo false;
  st_remove;
  st_put "E";
  st_put "F";
  [[ "$(st_print)" == "A E F" ]] && echo true || echo false; 
}
