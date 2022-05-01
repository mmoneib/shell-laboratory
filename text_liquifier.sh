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

#TODO Add options for arbitrary (screen-independent) width and height.

usage="Usage 1: text_liquifier.sh %f [-l %l] [-r %r] [-h %h] [-v %v]
Usage 2: cat %f | ./text_liguifier.sh [-l %l] [-r %r] [-h %h] [-v %v]"
help=" Modify the alignment and padding of a text. Alignments are allowed in all 8 directions and the padding of the empty spaces around the sentences can be done with any symbol.
Arguments:
\tMandatory
\t-f: path of the input file.
\tOptional
\t-l: left padding symbol. Must be a single character enclose by double quotations. Default is space.
\t-r: right padding symbol. Must be a single character enclose by double quotations. Default is space.
\t-z: horizontal alignment. Must be either 'left', 'center', or 'right'. Default is 'center'.
\t-v: vertical alignment. Must be either 'top', 'center', or 'botton'. Default is 'center'.\n"

function print_usage {
  echo "$usage"
  echo "Try '~script name here~.sh -h' for more information."
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
  d_horCenter=$((d_numScreenColumns/2));
  d_verCenter=$((d_numScreenLines/2));
  c_horStartFunc='$((d_horCenter-(numOfColumns/2)))';
  c_verStartFunc='$((d_verCenter-(numOfLines/2)))';
  d_text=""
  if [ -z $1 ]; then # Case of no options at all.
    while read inp; do
      d_text+="$inp"
    done
  fi
  while getopts f:z:v:l:r:h o; do
    case $o in
      f) d_text="$(cat $OPTARG)"
        ;;
      z)
        if [[ "$OPTARG" == "left" ]]; then
          c_horStartFunc='$(echo 0)';
        elif [[ "$OPTARG" == "center" ]]; then
          c_horStartFunc='$((d_horCenter-(numOfColumns/2)))';
        elif [[ "$OPTARG" == "right" ]]; then
          c_horStartFunc='$((d_numScreenColumns-numOfColumns))';
        else
          echo "Error: Invalid horizontal option value!">&2;
          print_usage;
        fi
        ;;	
      v)
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
}

function process_data {
  while read -n $d_numScreenColumns inp; do # Partitioning into lines fitting the screen.
    pon_outputLines+=("$inp")
  done <<< "$d_text"
numOfLines=${#pon_outputLines[@]};
verStart=$(eval echo $c_verStartFunc);
for ((i=0;i<d_numScreenLines;i++)); do
  if (("$i"<"$verStart")); then
    echo;
  elif (("$verStart"<="$i")) && (("$i"<"$verStart"+numOfLines)); then
  currentLine=${pon_outputLines[(($i-$verStart))]};
  numOfColumns=${#currentLine};
  horStart=$(eval echo $c_horStartFunc);
  for ((j=0;j<d_numScreenColumns;j++)); do
    if (("$j"<"$horStart")); then
      printf "$c_leftPaddingSymbol";
    elif (("$horStart"<="$j")) && (("$j"<"$horStart"+numOfColumns)); then
      printf "${currentLine:((j-horStart)):1}";
    else
      printf "$c_rightPaddingSymbol";
    fi
  done
  echo
  else
   echo;
  fi
done
}

#function raw_output {

#}

function output {
  raw_output
}

initialize_input $@
process_data
#output
