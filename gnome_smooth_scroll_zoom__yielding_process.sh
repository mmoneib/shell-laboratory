#!/bin/bash
################################################################################
# Gnome's Smooth Zoom by Mouse Scroll                                          #
#                                                                              #
# A script to magnify Gnome's screen based on the mouse wheel scrolling and    #
# several HW detection methods. The script modifies Gnome settings for the     #
# magnification. It forks a special process for mouse events while keeping the #
# original for keyboard events, which are more scarce and so, less process     #
# intensive. Inter-process communication is minimal and limited to signalling  #
# in order to avoid writing into the file system. The script is designed also  #
# to run as a startup background application. To do so, one should add an      #
# exception in the sudoers file to allow sudo the script without a password.   #
# In that case, the script should have execution and writing priviliges        #
# assigned only to root. Make sure to edit using visudo.                       #
#   example: your_username_here ALL=(ALL) NOPASSWD:                            #
#     /usr/bin/gnome_smooth_scroll_zoom.sh                                     #
# HW events detection is based on:                                             #
#   libinput: based on the unrecommended debug output. Sluggish, excessive,    # 
#     and subject to change.                                                   #
#                                                                              #
# Type: To be used as a standalone.                                            #
# Dependencies: Bash, Gnome3, Fedora (for now).                                #
# Developed by: Muhammad Moneib                                                #
################################################################################

# TODO Migrate to a yielding process format.
# TODO Graceful exit.
# TODO Better keys combination for activation.

kbd=;
magOnOff=false;
magFactor=1.0;
user=$(who|cut -d ' ' -f 1); # Parses the current user's name.
userID=$(id -u $user); # Gets the user's numeric ID,

function initializeGnomeMagnifierSettings {
  magFactor=1.0;
  # The gsettings program needs to be run as the user and not root. Also, it requires the address' env variable. Using sudo -E wasn't enough due to inner references.
  #sudo -u $user DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$userID/bus" 
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
#  sudo -u $user DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$userID/bus" 
gsettings set org.gnome.desktop.a11y.applications screen-magnifier-enabled $magOnOff;
  if [[ $magOnOff == false ]]; then
    pkill -P $$; # Kill current process and all its children.
  fi
}

function zoomMouseEventDetect { # Forked and piped, so all (even global which are copied) variables are limited to its scope.
  # 4th script-specific sub-process as shown by echo "$BASHPID". Created because libinput creates a process of its own.
  stream=true;
  function resetInput { stream=false;} # On resumption, set the flag to false so as to reset the input stream.
  trap resetInput CONT;
  while (true); do
    while read inp; do
      if [[ $stream != true ]]; then
        break;
      fi
      if [[ ! -z $(echo "$inp" | grep "vert -") ]]; then
        magFactor=$(echo "scale=1;$magFactor+0.1"|bc); # The tool bc is used for decimals calc.
      elif  [[ ! -z $(echo "$inp" | grep "vert") ]]; then
        magFactor=$(echo "scale=1;$magFactor-0.1"|bc);
        if (($(echo "$magFactor<1"|bc)==1)); then
          magFactor=1;
        fi
      fi 
#      sudo -u $user DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$userID/bus" 
gsettings set org.gnome.desktop.a11y.magnifier mag-factor $magFactor;
    done
    read -t 0.5 -N 10000; # Flushing the accumulated date to read anew, because the input is buffered until read. :-/ Not optimal solution.
    stream=true;
  done
}

function zoomKeyboardEventDetect {
  # 3rd script-specific sub-process as shown by echo "$BASHPID". Created because libinput creates a process of its own.
  pkill --signal STOP -P $!; # Default action is to prevent zooming.
  while read -r inp1; do
    if [[ ! -z $(echo "$inp1" | grep -E "KEYBOARD.*pressed") ]]; then # .* to grep with AND.      
      pkill --signal CONT -P $!;
    elif [[ ! -z $(echo "$inp1" | grep -E "KEYBOARD.*released") ]]; then
      pkill --signal STOP -P $!; # Interrupt forked child process. (keeps values of variables as the process won't die)
    fi
  done
}

function tryToDetectKeyboard {
  kbd=$(ls -l /dev/input/by-path/ | grep kbd | tail -1); # $() executes the enclosed command and put the output in a variable.  
  kbd=${kbd:((${#kbd}-1)):${#kbd}};
  if [[ ! -z $kbd ]]; then
    kbd="/dev/input/event"$kbd;
  fi
}

trap initializeGnomeMagnifierSettings EXIT;
initializeGnomeMagnifierSettings;
tryToDetectKeyboard;
# stdbuf is used to remove the buffering and allow detection of the continuous stream.
# The & is for forking the child process as the mouse detection of libinput produces more events.
(stdbuf -oL sudo libinput debug-events | stdbuf -oL grep "POINTER_SCROLL_WHEEL" | zoomMouseEventDetect)&  # 2nd script-specific sub-process as shown by echo "$BASHPID".
stdbuf -oL sudo libinput debug-events $kbd --show-keycodes | stdbuf -oL grep "KEY_LEFTALT" | zoomKeyboardEventDetect; # Main (top) process as shown by echo $$.

#TODO Add hot support for lense mode.
#TODO Add touchpad and touch screen pinching support.
#TODO Add other backends other than libinput.
#TODO Add event number parameters for forcing speciific mouse and keyboard.
