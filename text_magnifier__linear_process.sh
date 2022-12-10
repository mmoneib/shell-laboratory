#!/bin/sh
################################################################################
# Text Magnifier                                                               #
#                                                                              #
# A magnifier of characters and symbols through mutliplication of the simplest #
# form of an ASCII-like graphical representation.                              #
#                                                                              #
# Type: Linear Process.                                                        #
# Dependencies: Unix-like Shell (tested with Bash)                             #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c for config, d for data, and o for output.

usage=""
help=""

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
  c_o_horMagnification=1
  c_o_verMagnification=1
  c_o_charsDirectory="templates/text/magnifiable_ascii/"
  while getopts "H:d:t:V:ih" o; do
    case $o in
      ## The horizontal magnification factior.
      H) c_o_horMagnification="$OPTARG" ;;
      ## The directory containing the ASCII drawings representing the chars.
      d) c_o_charsDirectory="$OPTARG" ;;
      ## The text to be magnified.
      t) c_r_text="$OPTARG" ;;
      ## The vertical magnification factor.
      V) c_o_verMagnification="$OPTARG" ;;
      ## Whether a letter to be wrapped in the next line if cut by the edge of the screen or not.
      i) c_o_isWrap=true ;;
      h) __print_help ;;
      *) __print_usage ;;
    esac
  done
  if [ -f "$c_r_text"  ]; then
    d_text="$(cat $c_r_text)"
  else
    d_text="$c_r_text"
  fi
}

function process_data {
  o_lines=()
  firstChar=true
  for ((c=0;c<${#d_text};c++)); do
    char=$(echo ${d_text:$c:1} | tr '[:lower:]' '[:upper:]')
    case $char in
       "") char_file=$c_o_charsDirectory/space ;;
       * ) char_file=$c_o_charsDirectory/$char ;;
    esac
    symbol_char_text=$(cat $char_file);
    symbolCharLines=()
    while IFS="" read symbol_char_line; do
      newSymbolCharLine=""
      while IFS="" read -n1 symbol_inner_char; do
        for ((i=0;i<$c_o_horMagnification;i++)); do
          newSymbolCharLine+="$symbol_inner_char"
        done
      done <<< "$symbol_char_line"
      for ((i=0;i<$c_o_verMagnification;i++)); do
        symbolCharLines+=("$newSymbolCharLine")
      done
    done <<< "$symbol_char_text"
    betweenCharsSpace=""
     [ $firstChar == false ] && for ((i=0;i<$c_o_horMagnification;i++)); do # Scaling spaces between scaled characters.
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
