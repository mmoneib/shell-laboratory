#!/bin/bash
#####################################################################################################
# A script to detect whether the program should read the input from a pipe or a parameterized file. #
# Meant to be sourced into other scripts. The piping criteria can be set in the sourcing scripts    #
# to detect whether a file input parameter is present or not.                                       #
# The value pon_fileParameterPosition must be initialized.                                          #
# Developed by: Muhammad Moneib                                                                     #
#####################################################################################################

pon_outputLines=(); # Output.

function readLineByLineDelimiter {
  while read -r inp; do
    pon_outputLines+=("$inp");
  done
}

function readLineByCharacterNumberOrLineDelimiter {
  while read -r inp; do
    inlineIndex=0;
    while (($inlineIndex<=${#inp})); do
      pon_outputLines+=("${inp:inlineIndex:$pon_maxCharsToReadPerLine}");
      inlineIndex=$((inlineIndex+pon_maxCharsToReadPerLine));
    done
  done
}

if [[ ! -z $pon_maxCharsToReadPerLine ]]; then
  func="readLineByCharacterNumberOrLineDelimiter";
else
  func="readLineByLineDelimiter";
fi

if [[ -z $pon_fileParameterPosition ]]; then # Input. Should be initialized, otherwise, piping will always be expected.
  # To deal with piped input like from a cat operation.
  $func;
else
  $func < "${!pon_fileParameterPosition}";
fi
