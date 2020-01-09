#!/bin/bash
###########################################################################################################
# A script to magnify Gnome's screen based on the mouse wheel scrolling and several HW detection methods. #
# The script modifies Gnome settings for the magnification.                                               #
# HW events detection is based on:                                                                        #
#   libinput: based on the unrecommended debug output. Sluggish, excessive, and subject to change.        #
# Developed by: Muhammad Moneib                                                                           #
###########################################################################################################

magOnOff=false;
magFactor=1.0;

function initializeGnomeMagnifierSettings {
  magFactor=1.0;
  gsettings set org.gnome.desktop.a11y.magnifier mag-factor $magFactor;
  switchGnomeMagnifierOnOff;
}

function switchGnomeMagnifierOnOff {
  # Switching on at startup and off with the exit trap. The value shouldn't change at any other time.
  if [[ $magOnOff == false ]]; then
    magOnOff=true;
  else
    magOnOff=false;
  fi
  gsettings set org.gnome.desktop.a11y.applications screen-magnifier-enabled $magOnOff;
}

function zoomWithLibinput {
    function zoom {
      while read -r inp; do
        if [[ ! -z $(echo "$inp" | grep -E "KEYBOARD.*pressed") ]]; then # .* to grep with AND.
          magMode=true;
        elif [[ ! -z $(echo "$inp" | grep -E "KEYBOARD.*released") ]]; then
          magMode=false;
        elif [[ $magMode == true ]] && [[ ! -z $(echo "$inp" | grep "vert -") ]]; then
          magFactor=$(echo "scale=1;$magFactor+0.1"|bc); # The tool bc is used for decimals calc.
        elif [[ $magMode == true ]] && [[ ! -z $(echo "$inp" | grep "vert") ]]; then
          magFactor=$(echo "scale=1;$magFactor-0.1"|bc);
          if (($(echo "$magFactor<1"|bc)==1)); then
            magFactor=1;
          fi
        fi 
        gsettings set org.gnome.desktop.a11y.magnifier mag-factor $magFactor;
      done
  }
  # stdbuf is used to remove the buffering and allow detection of the continuous stream.
  sudo libinput debug-events --show-keycodes | stdbuf -oL grep "wheel\|KEY_LEFTCTRL" | zoom; # \| to grep with OR. 
}

trap initializeGnomeMagnifierSettings EXIT;
initializeGnomeMagnifierSettings;
zoomWithLibinput;

#TODO Listen to the keyboard only until CTRL is pressed. (performance)
#TODO Try to combine the streams from the keyboard and mouse only for libinput
#TODO Add other backbones than libinput.
#TODO Investigate why libinput's output only comes after mouse movement (even for keyboard!)
