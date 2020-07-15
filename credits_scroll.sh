#!/bin/bash
################################################################################
# Credits Scroller                                                             #
#                                                                              #
# An in-place, bottom-up text scroller for Linux command-line as in end        #
# credits of a movie. It can be used in a piping context or on its own.        #
#                                                                              #
# Type: To be used as a standalone.                                            #
# Dependencies: Bash, check_option_parameter__sourced.sh,                      # 
#   piped_or_not__sourced.sh.                                                  #
# Developed by: Muhammad Moneib.                                               #
################################################################################

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
    #clear;
    tput cup 0 0; # Restores the position of the cursor to the origin to start writing over. More efficient than clear at high frame rates.
    for ((i=$offset;i<$offset+$windowLinesCount-1;i++)); do # the viewable window.
      printf "\033[K"; # Used in combination with tput's origin to clear each line before writing over it. Avoids leftovers.
      if ((i<0 || i>=${#lines[@]})); then
        echo;
      else
        echo "${lines[i]}";
      fi
    done
    ((offset++));
    read -N 1 -s -t "$sleepTime" keyPress </dev/tty; # Read one character silently with a timeout equals to the sleeping time. Used instead of sleep for scheduling echoes.
    if [[ ! -z $keyPress && $keyPress == ' ' ]]; then
      while (true); do
        read -N 1 -s keyPress </dev/tty; # Force reading from stdin to allow interactivity in the case of pipinr. Here, the user can resume the scrolling.
        if [[ ! -z $keyPress && $keyPress == ' ' ]]; then
          break;
        fi
      done
    fi
  done
}

printLines "${pon_outputLines[@]}"; # The double-quotations are important as they will wrap each element in its own double-quotations.
