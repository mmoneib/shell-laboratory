#!/bin/bash

################################################################################
# Canvas 1.0                                                                   #
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
# Developer: Muhammad Moneib                                                   #
# License: CC BY-SA                                                            #
################################################################################

#TODO Add support to deleting by backspace and delete.
#TODO Add colored text.
#TODO Add colored fills.
#TODO Make the canvas scrollable.
#TODO Add support for animation frames.
#TODO Add options dialog.

tput clear;
horPos=0;
verPos=0;

function exitFunc {
 # Put the cursose at the lowest line in the screen and keep the text pre
 tput cup $(tput lines) 0;
}

trap exitFunc EXIT;

# Prevent parsing of input. Mainly for printing space here.
IFS=''
# Prevent echoing control characters. Mainly when reading is done, pressing arrows woulf print control.
stty -echoctl

while read -rsn1 inp; do
    case "$inp" in # n1: reads 1 char only. s: silent. 
    $'\033' ) # To check for ANSI escape char, we can also use x1b instead of 033. The $ is important to ensure you are looking for the escaping pattern.
      read -rsn2 inp2;
      case "$inp2" in
      "[A") 
      if [ $verPos == 0 ]; then # Prevents breaking top barrier.
        verPos=1
      fi
      tput cup $((--verPos)) $horPos; #UP
        ;;
      "[B")
      if [ $verPos == $(($(tput lines)-1)) ]; then # Prevents breaking bottom barrier.
        verPos=$(($(tput lines)-2))
      fi
      tput cup $((++verPos)) $horPos; #DOWN
        ;;
      "[C") 
      if [ $horPos == $(($(tput cols)-1)) ]; then # Prevents breaking left barrier.
        horPos=$(($(tput cols)-2))
      fi
      tput cup $verPos $((++horPos)); #RIGHT
        ;;
      "[D") 
      if [ $horPos == 0 ]; then # Prevents breaking left barrier.
        horPos=1
      fi
      tput cup $verPos $((--horPos)); #LEFT
        ;;
      esac
      # No flushing of the rest of the control symbol is needed since the original loop reads one char at a time till it finds \033.
      ;;
    * )
      printf "$inp";
      horPos=$(($horPos+1));
    esac
done


#Source: https://unix.stackexchange.com/questions/179191/bashscript-to-detect-right-arrow-key-being-pressed.
#https://unix.stackexchange.com/questions/181937/how-create-a-temporary-file-in-shell-script

Association is no reason for being guilty or proud.
Text Columnizer: Bash script to display text as columns on the screen or in a file.
https://www.tecmint.com/extend-and-reduce-lvms-in-linux/
One must fight the urge to talk to idiots.

