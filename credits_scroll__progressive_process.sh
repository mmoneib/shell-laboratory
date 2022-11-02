#!/bin/bash
################################################################################
# Credits Scroller                                                             #
#                                                                              #
# An in-place, bottom-up text scroller for Linux command-line as in end        #
# credits of a movie. It can be used in a piping context or on its own.        #
#                                                                              #
# Type: Progressive Process.                                                   #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib.                                               #
################################################################################

# Namspaces: c for config, d for data, and o for output.
#TODO Fix prefixes of variables.
#TODO Secure parameters input.

function __print_usage {  
  sh $(dirname $0)/help__actions.sh -a print_process_usage -t $0
  exit
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_process_help -t $0
  exit
}

trap clear EXIT; # Shutdown hook to clear the screen.

function initialize_input {
  #if [ -z $1 ]; then # Case of no options at all.
  #  __print_usage
  #fi
  c_o_framePause=1
  while getopts "hr:t:" o; do
    case "$o" in
    ## The pause period of each frame while scrolling; this is inversely related to the frame rate.
    r) c_o_framePause=$OPTARG ;;
    t) c_r_text=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  #TODO Add validation of options.
  o_lines=()
  count=0
  while IFS= read -r line; do
   o_lines[$count]="$line"
   ((count++))
  done < $c_r_text
}

function process_data {
  d_windowLinesCount=$(tput lines) # $() used to evaluate the script, as lines is not a command or option. The command tput queries the terminfo database for info about the current  terminal.
  d_windowColumnsCount=$(tput cols)
  o_offset=-$d_windowLinesCount;
  while (($o_offset<=${#o_lines[@]}+$d_windowLinesCount&&$o_offset<${#o_lines[@]})); do
    output
    read -N 1 -s -t "$c_o_framePause" keyPress </dev/tty; # Read one character silently with a timeout equals to the sleeping time. Used instead of sleep for scheduling echoes.
    if [[ ! -z $keyPress && $keyPress == ' ' ]]; then
      while (true); do
        read -N 1 -s keyPress </dev/tty; # Force reading from stdin to allow interactivity in the case of piping. Here, the user can resume the scrolling.
        if [[ ! -z $keyPress && $keyPress == ' ' ]]; then
          break;
        fi
      done
    fi
  done
}

function output {
  tput cup 0 0; # Restores the position of the cursor to the origin to start writing over. More efficient than clear at high frame rates.
  for ((i=$o_offset;i<$o_offset+$d_windowLinesCount-1;i++)); do # the viewable window.
    printf "\033[K"; # Used in combination with tput's origin to clear each line before writing over it. Avoids leftovers.
    if ((i<0 || i>=${#o_lines[@]})); then
      echo;
    else
      echo "${o_lines[i]}";
    fi
  done
  ((o_offset++));
}

initialize_input $@
process_data
output
