#!/bin/sh
# TODO Move to Metaphor.
#TODO Add proper description and help which follows the convention.
usage="Usage: .$(basename $0) -c choices_here _n number_of_iterations_here -v choice_values_here -w weights_pf_iterations_here [-s stop_choice_pattern_here] [-m multiplication_indicator_here] [-p compounding_indicator_here]"
while getopts "n:c:v:w:h:s:mp" o; do
  case "$o" in
    m) isMultiplication="true" ;;
    p) isCompounding="true" ;;
    n) numOfIterations="$OPTARG" ;;
    s) stopPattern="$OPTARG" ;;
    w) weightsPar="$OPTARG" ;;
    c) choicesPar="$OPTARG" ;;
    v) valuesPar="$OPTARG" ;;
    h) echo "Help: ." && exit ;;
    *) echo "$usage">&2 && exit 1 ;;
  esac
done
IFS=,
read -a choices <<< "$choicesPar"
read -a weights <<< "$weightsPar"
read -a values <<< "$valuesPar"
numOfChoices=${#choices[@]}
numOfRows="$(echo "$numOfChoices^$numOfIterations"|bc)"
elements=()
output=""
for((i=$numOfIterations;i>0;i--)); do
  index=0
  flipper="$(echo "($numOfChoices^$i)/2"|bc)"
  for ((j=1;j<=$numOfRows;j++)); do
    elements+=("${choices[$index]}")
    if [ "$flipper" != "0" ] && [ "$(echo "$j%$flipper"|bc)" == "0" ]; then
      index=$((($index+1)%${#choices[@]}))
    fi
  done
done
for((i=0;i<$numOfRows;i++)); do
 for((j=0;j<$numOfIterations;j++)); do
   index=$(((($i+1)+($j*$numOfRows))-1))
   output+="${elements[$index]}"
#   printf "${elements[$index]}"
 done
 output+="\n"
# printf "\n"
done
#printf "$output"
while read inp; do
  if [ ! -z "$stopPattern" ]; then
    inp="$(echo $inp|sed s/$stopPattern.*/$stopPattern/g)"
  fi
  equation=""
  for((i=0;i<${#inp};i++)); do
    choice=${inp:$i:1}
    choiceIndex=-1
    for((j=0;j<${#choices};j++)); do
      [ "${choices[$j]}" == "$choice" ] && choiceIndex="$j" && break
    done
    value="${values[$choiceIndex]}"
    weight="${weights[$i]}"
    if [ "$isMultiplication" == "true" ]; then
      equation+="($value*$weight)*"
    elif [ "$isCompounding" == "true" ]; then
      [ "${value:0:1}" == "-" ] && weight="$(echo "2-$weight"|bc -l)" && value="1"
      equation+="($value*$weight)*"
      #equation+="($value*$weight)"
      #equation+="+($equation)*"
    else
      equation+="$value*$weight+"
    fi
  done
  #echo "$equation"
  echo "$inp->$(echo $equation|sed s/\+$//g|sed s/\*$//g|bc -l)"
done <<< "$(printf "$output")"

