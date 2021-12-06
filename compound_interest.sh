#!/bin/bash

#TODO Add intro.
#TODO Add validation of options.

function usage() {
  echo "USAGE: compound_interest.sh -i initial_amount_here -n number_of_iterations_here -r interest_rate_here -p takeprofit_iterations_here -l stoploss_iterations_here [-v]"
  exit
}

if [ -z $1 ]; then # Case of no options at all.
  usage
fi

verbosity=false
while getopts "i:n:r:c:l:p:v" o; do
  case "$o" in
    i) initialAmount=$OPTARG ;;
    n) numberOfIterations=$OPTARG ;;
    r) interestRate=$OPTARG ;;
    c) inputAmount=$OPTARG ;;
    l) stopLossIterations=$OPTARG ;;
    p) takeProfitIterations=$OPTARG ;;
    v) verbosity=true ;;
    *) usage ;;
  esac
done

source color_utilities__sourceable.sh

if [ $verbosity == true ]; then
  echo "Initial Amount: $initialAmount"
  echo "Number of Iterations: $numberOfIterations"
  echo "Interest Rate: $interestRate"
fi

currentIteration=$numberOfIterations
numberOfInterestApplicationPerIteration=1 # Kept as 1 as I want to normalize the calculation with the time interval.
equation=$(echo "$initialAmount*(1+$interestRate/$numberOfInterestApplicationPerIteration)^($numberOfInterestApplicationPerIteration*$numberOfIterations)")

if [ $verbosity == true ]; then
  echo "Equation of Compounded Interest: $equation"
fi
amountAfterIteration=$(echo  "scale=2;"$equation|bc -l)
if [ $verbosity == true ]; then
  echo "Amount after $currentIteration Iteration(s): $amountAfterIteration"
  echo
  echo "REPORT"
fi

currentIteration=1
i=1
referenceIteration=0 # Will indicate the current position.
# This while loop is a duplicate from the one after and used only to get the reference iteration to allow formating the SL iteration which lies in the past. Redundant but cheap.
amount=$initialAmount
while [ "$i" -le "$numberOfIterations" ]; do
   equation=$(echo "$amount*(1+$interestRate/$numberOfInterestApplicationPerIteration)^($numberOfInterestApplicationPerIteration*$currentIteration)")
   expectedValue=$(echo "scale=2;"$equation|bc -l)
   if [ $(echo "$expectedValue>$inputAmount"|bc) == 1 ]; then # Bash doesn't compare floats, therefore bc.
     if [ ! -z $lastDiff ] && [ $(echo "$lastDiff>=$expectedValue-$inputAmount"|bc) == 1 ]; then
       referenceIteration=$i
     else
       referenceIteration=$((i-1))
     fi
     break
   else
     lastDiff=$(echo "$inputAmount-$expectedValue"|bc)
   fi
   amount=$expectedValue
   ((i=i+1))
done

currentIteration=1
i=1
amount=$initialAmount
while [ "$i" -le "$numberOfIterations" ]; do
   equation=$(echo "$amount*(1+$interestRate/$numberOfInterestApplicationPerIteration)^($numberOfInterestApplicationPerIteration*$currentIteration)")
   expectedValue=$(echo "scale=2;"$equation|bc -l)
   row="Iteration $i -- Expected Value: $expectedValue"
   if [ "$i" == "$referenceIteration" ]; then
     print_text_with_color_and_background "$row" 7 246
   elif [ "$i" == $(("$referenceIteration"-"$stopLossIterations")) ]; then
     print_text_with_color_and_background "$row" 7 196
   elif [ "$i" == $(("$referenceIteration"+"$takeProfitIterations")) ]; then
     print_text_with_color_and_background "$row" 7 34
   else
     if [ $verbosity == true ]; then
       printf "$row\n"
     fi
   fi
   amount=$expectedValue
   ((i=i+1))
done

