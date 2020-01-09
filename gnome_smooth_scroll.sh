#!/bin/bash
###########################################################################################################
# A script to magnify Gnome's screen based on the mouse wheel scrolling and several HW detection methods. #
# The script so far uses libinput for HW events and modifies Gnome settings for the magnification.        #
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
        if [[ ! -z $(echo "$inp" | grep -E "KEYBOARD.*pressed") ]]; then
          magMode=true;
        elif [[ ! -z $(echo "$inp" | grep -E "KEYBOARD.*released") ]]; then
          magMode=false;
        elif [[ $magMode == true ]] && [[ ! -z $(echo "$inp" | grep "vert -") ]]; then
          magFactor=$(echo "scale=1;$magFactor+0.1"|bc);
        elif [[ $magMode == true ]] && [[ ! -z $(echo "$inp" | grep "vert") ]]; then
          magFactor=$(echo "scale=1;$magFactor-0.1"|bc);
          if (($(echo "$magFactor<1"|bc)==1)); then
            magFactor=1;
          fi
        fi 
        gsettings set org.gnome.desktop.a11y.magnifier mag-factor $magFactor;
      done
  }
  sudo libinput debug-events --show-keycodes | stdbuf -oL grep "wheel\|KEY_LEFTCTRL" | zoom; 
}

trap initializeGnomeMagnifierSettings EXIT;
initializeGnomeMagnifierSettings;
zoomWithLibinput;

#TODO Listen to the keyboard only until CTRL is pressed. (performance)
#TODO Try to combine the streams from the keyboard and mouse only for libinput
#TODO Add other backbones than libinput.
#TODO Investigate why libinput's output only comes after mouse movement (even for keyboard!)
