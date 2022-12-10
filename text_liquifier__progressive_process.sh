#!/bin/sh
################################################################################
# Text Liquifier                                                               #
#                                                                              #
# Modify the alignment and padding of a text. Alignments are allowed in all 8  #
# directions and the padding of the empty spaces around the sentences can be   #
# done with any symbol.                                                        #
#                                                                              #
# Type: Progressive Process.                                                   #
# Dependencies: Unix-like Shell (tested with Bash), and tput.                  #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c for config, d for data, and o for output.

#TODO Add padding of empty lines.
#TODO Allow symbols disallowed by the terminal to be used as pads (e.g. *).
#TODO Add option to disallow cutting words.
#TODO Review order of options.
#TODO Validate options types.
#TODO Modify horizontal and vertical starts options to allow for arbitrary numbers.
#TODO Add ability to have lines widths controlled by a mathematical functions to allow liquification into shapes.

function __print_incorrect_parameter_value_error {
  echo "Validation Error: The provided value $1 is not supported by this parameter $2. Please check Help for more info.">&2
  exit 1
}

function __print_usage {  
  sh $(dirname $0)/help__actions.sh -a print_process_usage -t $0
  exit
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_process_help -t $0
  exit
}

function initialize_input {
  d_numScreenColumns=$(tput cols)
  d_numScreenLines=$(tput lines)
  c_o_leftPaddingSymbol=" "
  c_o_rightPaddingSymbol=" "
  c_o_columnsLimitation=0
  d_horCenter=$((d_numScreenColumns/2))
  d_verCenter=$((d_numScreenLines/2))
  c_horStartFunc='$((d_horCenter-(d_numOfColumns/2)))'
  c_verStartFunc='$((d_verCenter-(numOfLines/2)))'0
  d_text=""
  [ -z "$1" ] && __print_usage
  # Check if input is piped.
  read -t 0.1 inp; # Doesn't read more than a line.
  if [ ! -z "$inp" ]; then
    c_r_text="$inp"
    while read inp; do
      c_r_text+="\n$inp"
    done
  fi
  while getopts f:z:v:l:r:b:h o; do
    case $o in
      ## Path of the input file.
      t) c_r_text="$OPTARG" ;;
      ## Limit of characters (without paddings) as subtracted from the screen columns per line. Default is 0.
      b) c_o_columnsLimitation="$OPTARG" ;;
      ## Horizontal alignment. Must be either 'left', 'center', or 'right'. Default is 'center'.
      z) c_o_horizontalAlignment="$OPTARG" ;;
      ## Vertical alignment. Must be either 'top', 'center', or 'botton'. Default is 'center'.
      v) c_o_verticalAlignment="$OPTARG" ;;
      ## Left padding symbol. Must be a single character enclose by double quotations. Default is space.
      l) c_o_leftPaddingSymbol="$OPTARG" ;;
      ## Right padding symbol. Must be a single character enclose by double quotations. Default is space.
      r) c_o_rightPaddingSymbol="$OPTARG" ;;
      h) __print_help ;;
      *) __print_usage ;;
    esac
  done
  [ -z "$c_r_text" ] &&  __print_usage
  [ -f "$c_r_text" ] && d_text="$(cat $c_r_text)" || d_text="$c_r_text"
  # Polymorphism
  if [[ "$c_o_horizontalAlignment" == "left" ]]; then
    d_horStartFunc='$(echo 0)'
  elif [[ "$c_o_horizontalAlignment" == "center" ]]; then
    d_horStartFunc='$((d_horCenter-(d_numOfColumns/2)))'
  elif [[ "$c_o_horizontalAlignment" == "right" ]]; then
    d_horStartFunc='$((d_numScreenColumns-d_numOfColumns))'
  else
    __print_incorrect_parameter_value_error "$c_o_horizontalAlignment" "horizontal_alignment"
  fi 
  # Polymorphism
  if [[ "$v_horizontalAlignment" == "top" ]]; then
    d_verStartFunc='$(echo 0)'
  elif [[ "$v_horizontalAlignment" == "center" ]]; then
    d_verStartFunc='$((d_verCenter-(numOfLines/2)))'
  elif [[ "$v_horizontalAlignment" == "bottom" ]]; then
    d_verStartFunc='$((d_numScreenLines-numOfLines))'
  else
    __print_incorrect_parameter_value_error "$c_o_verticalAlignment" "vertical_alignment"
  fi
  (($c_o_leftPaddingSymbol>1)) &&  __print_incorrect_parameter_value_error "$c_o_leftPaddingSymbol" "left_padding_symbol"
} 

function process_data {
  o_lines=()
  while read -n $((d_numScreenColumns-c_o_columnsLimitation)) inp; do # Partitioning into lines fitting the screen.
    lines+=("$inp")
  done <<< "$d_text"
  numOfLines=${#lines[@]};
  verStart=$(eval echo $c_verStartFunc);
  for ((l=0;l<d_numScreenLines;l++)); do
    o_lines[l]=""
    if (("$verStart"<="$l")) && (("$l"<"$verStart"+numOfLines)); then
      currentLine=${lines[(($l-$verStart))]}; # Relative to the populated lines.
      d_numOfColumns=${#currentLine} # Number of characters in the current line.
      horStart=$(eval echo $c_horStartFunc);
      for ((c=0;c<d_numScreenColumns;c++)); do
        if (("$horStart"<="$c")) && (("$c"<"$horStart"+d_numOfColumns)); then
          o_lines[l]+="${currentLine:((c-horStart)):1}"; # Relative to the populated characters.
        elif (("$horStart">"$c")); then
          o_lines[l]+="$c_o_leftPaddingSymbol"
        else
          o_lines[l]+="$c_o_rightPaddingSymbol"
        fi
      done
    fi
  done
}

function raw_output {
  for ((l=0;l<${#o_lines[@]};l++)); do
    if [ "${o_lines[l]}" == "" ]; then
      printf "\n"
    else
      echo "${o_lines[l]}"
    fi
  done
}

function output {
  raw_output
}

initialize_input "$@"
process_data
output
