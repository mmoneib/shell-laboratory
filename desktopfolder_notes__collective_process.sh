#!/bin/sh
################################################################################
# DesktopFolder Notes Actions                                                  #
#                                                                              #
# Actions toolset to create, view, and modify the desktop sticky notes used    #
# by the application DesktopFolder.                                            #
#                                                                              #
# Type: Actions            .                                                   #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     DesktopFolder                                                            #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Positional parameters inside action functions are used especially for the case of sourcing.
#TODO Add creation of new notes.
#TODO Add editing on the fly.

usage="Usage: ./desktopfolder_notes_actions.sh -a action_name_here [-f note_file_name_here] [-t text_file_name_here]"
help="A tool to view and modify the desktop nots of DesktopFolder from the convenience of the command line.
  Parameters:
    a -> name of action to be performed (see list of actions below).
    d -> path to desktop directory.
    f -> path to desktop note file.
    m -> path to text file.
    t -> path to text directory.
  Actions
    desktopNoteToText -> parses the note out of the text file and formats it for viewing.
    desktopNoteToTextFile -> parses the note out of the text file and iformats it for saving as plain text in the specified directory.
    textFileToDesktopNote -> 
  Action/Parameter Matrix:
    ==================================
    | Action / Parameter     | f | t |
    ==================================
    | desktopNoteToText      | * |   |
    ----------------------------------
    | desktopNoteToTextiFile | * | * |
    ----------------------------------
"

function print_usage {
  echo $usage
  exit 1
}

function print_help {
  echo "$usage"
  printf "$help"
  exit
}


function desktopNoteToText {
 [ -z $noteFile ] && noteFile="$1"
 cat $noteFile |grep -o text\":\".*|sed s/text\".\"//g|sed s/\".\"on-.*//g|sed s/\\\\\"/\"/g|sed s/\\\\n/\\n/g
}

function desktopNoteToTextFile {
  [ -z $noteFile ] && noteFile="$1"
  [ -z $textDirectory ] && textDirectory="$2"
  name=$(basename $noteFile|sed s/\.desktopnote//g)
  if [ ! -d $textDirectory ]; then
    mkdir $textDirectory
  fi
  desktopNoteToText>"$textDirectory/$name"
}

function textFileToDesktopNote {
  [ -z $noteDirectory ] && noteDirectory="$1"
  [ -z $textFile ] && textFile="$2"
  name=$(basename $textFile)
  fileText=$(cat $textFile|sed s/\"/\\\\\"/g|sed -z s/\\n/\\\\n/g)
  noteFile=$noteDirectory/$name.desktopnote
  metaPrefix=$(cat $noteFile|grep -o "^.*text\":\"")
  metaPostfix=$(cat $noteFile|grep -o "\",\"on-.*")
  rm $noteFile
  sleep 1
  echo "$metaPrefix$fileText$metaPostfix">$noteFile
}

if [ "$1" != "skip_run" ]; then
  while getopts "a:d:f:m:t:x:h" o; do
    case $o in
      a) action=$OPTARG ;;
      d) noteDirectory=$OPTARG ;;
      f) noteFile=$OPTARG ;;
      t) textDirectory=$OPTARG ;;
      x) textFile=$OPTARG ;;
      h) print_help ;;
      *) print_usage ;;
    esac
  done
  $action $noteDirectory $noteFile $textFileName $textDirectory $textFile
fi
