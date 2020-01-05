#!/bin/bash
#############################################################################################
# An in-place, bottom-up text scroller for Linux command-line as in end credits of a movie. #
# It can be used in a piping context or on its own.                                         #
# Developed by: Muhammad Moneib.                                                            #
#############################################################################################

windowLinesCount=$(tput lines); # $() used to evaluate the script, as lines is not a command or option. The command tput queries the terminfo database for info about the current terminal.
windowColumnsCount=$(tput cols);
sleepTime=1; # Like frame rate.

source check_option_parameter__sourced.sh
cop_doesThisOptionExist "s";
if [[ $cop_hasOption == true ]]; then
  cop_getValueForOption "s";
  sleepTime=$cop_optionValue;
fi
cop_getValuePositionForOption "f";

pon_fileParameterPosition=$cop_optionValuePosition;
pon_maxCharsToReadPerLine=$windowColumnsCount;
source piped_or_not__sourced.sh;

trap clear EXIT; # Shutdown hook to clear the screen.

function printLines {
  lines=("$@");
  offset=-$windowLinesCount;
  while (($offset<=${#lines[@]}+$windowLinesCount&&$offset<${#lines[@]})); do
    clear;
    for ((i=$offset;i<$offset+$windowLinesCount;i++)); do # the viewable window.
      if ((i<0 || i>=${#lines[@]})); then
        echo;
      else
        echo "${lines[i]}";
      fi
    done
    ((offset++));
    sleep "$sleepTime"s;
  done
}

printLines "${pon_outputLines[@]}"; # The double-quotations are important as they will wrap each element in its own double-quotations.
