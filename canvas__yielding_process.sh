#!/bin/bash
################################################################################
# Canvas                                                                       #
#                                                                              #
# A script that allows free movement of the cursor on the terminal screen.     #
# This can be used for artistic endeavors like ASCII drawings, pixel art,      #
# visual poetry, formatting, and emoticons creation.                           #
#                                                                              #
# There is currently a limitation in the quick movement of the cursor          #
# resulting in the display of control characters of the arrow keys on the      #
# screen. Slower movement is a good remedy in that case. Deletion of chars can #
# be achieved by hitting Space bar.                                            #
#                                                                              #
# Type: Yielding Process.                                                      #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developer: Muhammad Moneib                                                   #
################################################################################

#TODO Add support to deleting by backspace and delete.
#TODO Add colored text.
#TODO Add colored fills.
#TODO Make the canvas scrollable.
#TODO Add support for animation frames.
#TODO Add options dialog.

#. ./bind

function exitFunc {
 # Put the cursose at the lowest line in the screen and keep the text present.
 tput cup $(tput lines) 0;
}

function initialize_input {
  # Prevent parsing of input. Mainly for printing space here.
  IFS=''
  # Prevent echoing control characters. Mainly when reading is done, pressing arrows would print control.
  stty -echoctl
  tput clear;
  d_horPos=0;
  d_verPos=0;
 trap exitFunc EXIT;
}

function process_data {
  while read -rsn1 inp; do
      case "$inp" in # n1: reads 1 char only. s: silent. 
      $'\033' ) # To check for ANSI escape char, we can also use x1b instead of 033. The $ is important to ensure you are looking for the escaping pattern.
        read -rsn2 inp2;
        case "$inp2" in
        "[A") 
        if [ $d_verPos == 0 ]; then # Prevents breaking top barrier.
          d_verPos=1
        fi
        tput cup $((--d_verPos)) $d_horPos; #UP
          ;;
        "[B")
        if [ $d_verPos == $(($(tput lines)-1)) ]; then # Prevents breaking bottom barrier.
          d_verPos=$(($(tput lines)-2))
        fi
        tput cup $((++d_verPos)) $d_horPos; #DOWN
          ;;
        "[C") 
        if [ $d_horPos == $(($(tput cols)-1)) ]; then # Prevents breaking left barrier.
          d_horPos=$(($(tput cols)-2))
        fi
        tput cup $d_verPos $((++d_horPos)); #RIGHT
          ;;
        "[D") 
        if [ $d_horPos == 0 ]; then # Prevents breaking left barrier.
          d_horPos=1
        fi
        tput cup $d_verPos $((--d_horPos)); #LEFT
          ;;
        esac
        # No flushing of the rest of the control symbol is needed since the original loop reads one char at a time till it finds \033.
        ;;
        * )
        o_char="$inp"
        output
        d_horPos=$(($d_horPos+1));
      esac
  done
}

function output {
  printf "$inp"
}

initialize_input "$@"
process_data
