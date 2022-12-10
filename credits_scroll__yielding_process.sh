#!/bin/bash
################################################################################
# Credits Scroller                                                             #
#                                                                              #
# An in-place, bottom-up text scroller for Linux command-line as in end        #
# credits of a movie. It can be used in a piping context or on its own.        #
#                                                                              #
# Type: Yielding Process   .                                                   #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib.                                               #
################################################################################

# Namspaces: c for config, d for data, and o for output.

function __print_usage {  
  sh $(dirname $0)/help__actions.sh -a print_process_usage -t $0
  exit
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_process_help -t $0
  exit
}

function initialize_input {
  if [ -z $1 ]; then # Case of no options at all.
    __print_usage
  fi
  c_o_framePause=1
  # Check if input is piped.
  IFS= read -t 0.1 inp; # Doesn't read more than a line. IFS= to preserve spaces.
  if [ ! -z "$inp" ]; then
    c_r_text="$inp"
    while IFS= read -r inp; do # IFS= to preserve spaces.
      c_r_text+="\n$inp"
    done
  fi
  while getopts "hr:t:" o; do
    case "$o" in
    ## The pause period of each frame while scrolling in seconds; this is inversely related to the frame rate.
    r) c_o_framePause=$OPTARG ;;
    ## The text to be scrolled. This can be a text file, a piped text, or an in-line text enclosed by quotes in the command.
    t) c_r_text=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
    esac
  done
  [ -z "$c_r_text" ] &&  __print_usage
  [ -f "$c_r_text" ] && text="$(cat $c_r_text)" || text="$c_r_text"
  o_lines=()
  count=0
    while IFS= read -r line; do # IFS= to preserve spaces.
     o_lines[$count]="$line"
     ((count++))
    done <<< "$(printf "$text")" # Used printf here rather than the text directly to benifit from printf's interpretation of \n as a newline.
  trap clear EXIT; # Shutdown hook to clear the screen.
}

function process_data {
  o_windowLinesCount=$(tput lines) # $() used to evaluate the script, as lines is not a command or option. The command tput queries the terminfo database for info about the current  terminal.
  o_offset=-$o_windowLinesCount;
  while (($o_offset<=${#o_lines[@]}+$o_windowLinesCount&&$o_offset<${#o_lines[@]})); do
    output
    ((o_offset++))
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
  for ((i=$o_offset;i<$o_offset+$o_windowLinesCount-1;i++)); do # the viewable window.
    printf "\033[K"; # Used in combination with tput's origin to clear each line before writing over it. Avoids leftovers.
    if ((i<0 || i>=${#o_lines[@]})); then
      echo;
    else
      echo "${o_lines[i]}"
    fi
  done
}

initialize_input $@
process_data
