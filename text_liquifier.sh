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
#TODO Validae options types.
#TODO Modify horizonal and vertical starts options to allow for arbitrary numbers.
#TODO Add ability to have lines widths controlled by a mathematical functions to allow liquification into shapes.

usage="Usage 1: text_liquifier.sh -f file_name_here [-l left_padding_symbol_here] [-r right_padding_symbol_here] [-z horizontal_alignment_here] [-v vertical_alignment_here]
Usage 2: cat text_file_here | ./text_liguifier.sh [-l left_padding_symbol_here] [-r right_padding_symbol_here] [-z horizontal_alignment_here] [-v vertical_alignment_here]"
help=" Modify the alignment and padding of a text. Alignments are allowed in all 8 directions and the padding of the empty spaces around the sentences can be done with any symbol.
Arguments:
\tMandatory
\t-f: path of the input file.
\tOptional
\t-b: limit of characters (without paddings) as subtracted from the screen columns per line. Default is 0.
\t-l: left padding symbol. Must be a single character enclose by double quotations. Default is space.
\t-r: right padding symbol. Must be a single character enclose by double quotations. Default is space.
\t-z: horizontal alignment. Must be either 'left', 'center', or 'right'. Default is 'center'.
\t-v: vertical alignment. Must be either 'top', 'center', or 'botton'. Default is 'center'.\n"

function print_usage {
  echo "$usage"
  echo "Try './text_liquifier.sh -h' for more information."
  exit
}

function print_help {
  echo "$usage"
  printf "$help"
  exit
}

function initialize_input {
  d_numScreenColumns=$(tput cols);
  d_numScreenLines=$(tput lines);
  c_leftPaddingSymbol=" ";
  c_rightPaddingSymbol=" ";
  c_columnsLimitation=0
  d_horCenter=$((d_numScreenColumns/2));
  d_verCenter=$((d_numScreenLines/2));
  c_horStartFunc='$((d_horCenter-(d_numOfColumns/2)))';
  c_verStartFunc='$((d_verCenter-(numOfLines/2)))';
  d_text=""
  if [ -z $1 ]; then # Case of no options at all, to allow piping..
    while read -t 1 inp; do
      d_text+="$inp"
    done
    if [ -z "$d_text" ]; then
      print_usage
    fi
  fi
  while getopts f:z:v:l:r:b:h o; do
    case $o in
      f) d_text="$(cat $OPTARG)" ;;
      b) c_columnsLimitation=$OPTARG ;;
      z) # polymorphism.
        if [[ "$OPTARG" == "left" ]]; then
          c_horStartFunc='$(echo 0)';
        elif [[ "$OPTARG" == "center" ]]; then
          c_horStartFunc='$((d_horCenter-(d_numOfColumns/2)))';
        elif [[ "$OPTARG" == "right" ]]; then
          c_horStartFunc='$((d_numScreenColumns-d_numOfColumns))';
        else
          echo "Error: Invalid horizontal option value!">&2;
          print_usage;
        fi
        ;;	
      v) # polymorphism.
        if [[ "$OPTARG" == "top" ]]; then
          c_verStartFunc='$(echo 0)';
        elif [[ "$OPTARG" == "center" ]]; then
          c_verStartFunc='$((d_verCenter-(numOfLines/2)))';
        elif [[ "$OPTARG" == "bottom" ]]; then
          c_verStartFunc='$((d_numScreenLines-numOfLines))';
        else
          echo "Error: Invalid vertical option value!">&2;
          print_usage;
        fi
        ;;
      l) 
        if ((${#OPTARG}>1)); then
          echo "Error: Invalid left padding symbol! A symbol must be a single character.">&2
          print_usage
        fi
        c_leftPaddingSymbol="$OPTARG";
        ;;
      r)
        if ((${#OPTARG}>1)); then
          echo "Error: Invalid right padding symbol! A symbol must be a single character.">&2
          print_usage
        fi
        c_rightPaddingSymbol=$OPTARG
        ;;
      h) print_help ;;
      *) print_usage ;;
    esac
  done
  if [ -z "$d_text" ]; then
    print_usage
  fi
}

function process_data {
  o_lines=()
  while read -n $((d_numScreenColumns-c_columnsLimitation)) inp; do # Partitioning into lines fitting the screen.
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
          o_lines[l]+="$c_leftPaddingSymbol"
        else
          o_lines[l]+="$c_rightPaddingSymbol"
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

initialize_input $@
process_data
output
