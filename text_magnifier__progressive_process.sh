#!/bin/sh
################################################################################
# Text Magnifier                                                               #
#                                                                              #
# A magnifier of characters and symbols through mutliplication of the simplest #
# form of an ASCII-like graphical representation.                              #
#                                                                              #
# Type: Progressive Process.                                                   #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c for config, d for data, and o for output.

usage=""
help=""

function print_usage {
  echo "$usage"
  echo "Try $(basename $0) -h' for more information."
  exit 1
}

function print_help {
  echo "$usage"
  printf "$help"
  exit
}

function initialize_input {
  if [ -z $1 ]; then # Case of no options at all.
    print_usage
  fi
  c_horMagnification=1
  c_verMagnification=1
  c_charsDirectory="templates/text/magnifiable_ascii/"
  while getopts "H:d:t:V:h" o; do
    case $o in
      H) c_horMagnification="$OPTARG" ;;
      d) c_charsDirectory="$OPTARG" ;;
      t) c_text="$OPTARG" ;;
      V) c_verMagnification="$OPTARG" ;;
      i) c_isWrap=true ;;
      h) print_help ;;
      *) print_usage ;;
    esac
  done
  if [ -f "$c_text"  ]; then
    d_text="$(cat $c_text)"
  else
    d_text="$c_text"
  fi
}

function process_data {
  o_lines=()
  firstChar=true
  for ((c=0;c<${#d_text};c++)); do
    char=$(echo ${d_text:$c:1} | tr '[:lower:]' '[:upper:]')
    case $char in
       "") char_file=$c_charsDirectory/space ;;
       * ) char_file=$c_charsDirectory/$char ;;
    esac
    symbol_char_text=$(cat $char_file);
    symbolCharLines=()
    while IFS="" read symbol_char_line; do
      newSymbolCharLine=""
      while IFS="" read -n1 symbol_inner_char; do
        for ((i=0;i<$c_horMagnification;i++)); do
          newSymbolCharLine+="$symbol_inner_char"
        done
      done <<< "$symbol_char_line"
      for ((i=0;i<$c_verMagnification;i++)); do
        symbolCharLines+=("$newSymbolCharLine")
      done
    done <<< "$symbol_char_text"
    betweenCharsSpace=""
     [ $firstChar == false ] && for ((i=0;i<$c_horMagnification;i++)); do # Scaling spaces between scaled characters.
      betweenCharsSpace+=" "
    done
    for ((i=0;i<${#symbolCharLines[@]};i++)); do
      o_lines[$i]="${o_lines[$i]}$betweenCharsSpace${symbolCharLines[$i]}"
    done
    firstChar=false
  done
} 

function raw_output {
  windowWidth=$(tput cols)
  windowStart=0
  windowEnd=$windowWidth
  while [ $windowStart -lt ${#o_lines[0]} ]; do
    for ((i=0;i<${#o_lines[@]};i++)); do
      echo "${o_lines[$i]:$windowStart:(($windowEnd-$windowStart))}"
    done
    windowStart=$(($windowEnd))
    windowEnd=$(($windowStart+$windowWidth))
    [ $windowEnd -gt ${#o_lines[0]} ] && windowEnd=${#o_lines[0]} # To have no trailing spaces.
    [ $windowStart -lt ${#o_lines[0]} ] && echo # Line spacing.
  done
}

function output {
  raw_output
}

initialize_input "$@"
process_data
output
