#!/bin/bash

################################################################################
# Text Liquifier v.1.0                                                         #
#                                                                              #
# A bash script to modify the alignment and padding of a text. Alignments are  #
# allowed in all 8 directions and the padding of the empty spaces around the   #
# sentences can be done with any symbol.                                       #
#                                                                              #
# This script is meant to be used on its own or as a source for other scripts. #
#                                                                              #
# Developed by: Muhammad Moneib                                                #
# License: CC BY-SA                                                            #
################################################################################

#TODO Add options for arbitrary (screen-independent) width and height.

leftPaddingSymbol=" ";
rightPaddingSymbol=" ";
numScreenLines=$(tput lines);
numScreenColumns=$(tput cols);
pon_maxCharsToReadPerLine=$numScreenColumns;
[[ ${1:0:1} != "-" ]] && pon_fileParameterPosition=1;
horCenter=$((numScreenColumns/2));
verCenter=$((numScreenLines/2));
horStartFunc='$((horCenter-(numOfColumns/2)))';
verStartFunc='$((verCenter-(numOfLines/2)))';

function echoUsage {
  echo "Usage 1: ./text_liguifier.sh %f [-l %l] [-r %r] [-h %h] [-v %v]";
  echo "Usage 2: cat %f | ./text_liguifier.sh [-l %l] [-r %r] [-h %h] [-v %v]";
  echo "Glossary:"
  echo -e "\t[] -> optional.";
  echo -e "\t%f -> file name.";
  echo -e "\t%l -> left padding symbol. Must be a single character enclose by double quotations. Default is space.";
  echo -e "\t%r -> right padding symbol. Must be a single character enclose by double quotations. Default is space.";  
  echo -e "\t%h -> horizontal alignment. Must be either 'left', 'center', or 'right'. Default is 'center'.";
  echo -e "\t%h -> vertical alignment. Must be either 'top', 'center', or 'botton'. Default is 'center'.";
  exit;
}

if (( ${#@} == 0 )) || [[ "$1" == "--help" ]]; then
  echoUsage;
fi

source piped_or_not__sourced.sh;

[[ ${1:0:1} != "-" ]] && shift # For getOpts to work, I had to get rid of the first custom (non-standard) positional argument.

function chooseHorFunc {
  if [[ "$1" == "left" ]]; then
    horStartFunc='$(echo 0)';
  elif [[ "$1" == "center" ]]; then
    horStartFunc='$((horCenter-(numOfColumns/2)))';
  elif [[ "$1" == "right" ]]; then
    horStartFunc='$((numScreenColumns-numOfColumns))';
  else
    echo "Invalid horizontal option value!";
    exit 1;
  fi
}

function chooseVerFunc {
  if [[ "$1" == "top" ]]; then
    verStartFunc='$(echo 0)';
  elif [[ "$1" == "center" ]]; then
    verStartFunc='$((verCenter-(numOfLines/2)))';
  elif [[ "$1" == "bottom" ]]; then
    verStartFunc='$((numScreenLines-numOfLines))';
  else
    echo "Invalid vertical option value!";
    exit 1;
  fi
}

function initializeWithOptions {
  while getopts h:v:l:r: opt; do
  case $opt in
    h)
      chooseHorFunc $OPTARG;
      ;;	
    v)
      chooseVerFunc $OPTARG;
      ;;
    l) 
      if ((${#OPTARG}>1)); then
        echo "Invalid left padding symbol! A symbol must be a single character."
      fi
      leftPaddingSymbol="$OPTARG";
      ;;
    r)
      if ((${#OPTARG}>1)); then
        echo "Invalid right padding symbol! A symbol must be a single character."
      fi
      rightPaddingSymbol=$OPTARG
      ;;
  esac
  done
  shift $((OPTIND -1))
}

function transformHorizontal {
  currentLine=${pon_outputLines[(($i-$verStart))]};
  numOfColumns=${#currentLine};
  horStart=$(eval echo $horStartFunc);
  for ((j=0;j<numScreenColumns;j++)); do
    if (("$j"<"$horStart")); then
      printf "$leftPaddingSymbol";
    elif (("$horStart"<="$j")) && (("$j"<"$horStart"+numOfColumns)); then
      printf "${currentLine:((j-horStart)):1}";
    else
      printf "$rightPaddingSymbol";
    fi
  done
  echo
}

initializeWithOptions $@;
numOfLines=${#pon_outputLines[@]};
verStart=$(eval echo $verStartFunc);
for ((i=0;i<numScreenLines;i++)); do
  if (("$i"<"$verStart")); then
    echo;
  elif (("$verStart"<="$i")) && (("$i"<"$verStart"+numOfLines)); then
    transformHorizontal;
  else
   echo;
  fi
done
