#!/bin/bash

#TODO Add intro.
#TODO Add validation of options.

# Namspaces: c for config, d for data, and o for output.

function print_usage {
  echo "USAGE: compouninterest.sh -i initial_amount_here -n number_of_iterations_here -r interest_rate_here -p takeprofit_iterations_here -l stoploss_iterations_here -g leverageamount_here -o opposite_amount_here [-v]"
  exit
}

function calculate {
  d_expectedValue=$(echo "scale=2;"$d_equation|bc -l)
}

function set_equation {
  d_equation="$d_amount*(1+$c_interestRate/$d_numberOfInterestApplicationPerIteration)^($d_numberOfInterestApplicationPerIteration*$d_timePeriod)"
}

function initialize_input {
  if [ -z $1 ]; then # Case of no options at all.
    print_usage
  fi
  c_verbosity=false
  while getopts "i:r:n:l:p:c:v" o; do
    case "$o" in
      i) c_initialAmount=$OPTARG ;;
      r) c_interestRate=$OPTARG ;;
      n) c_numberOfIterations=$OPTARG ;;
      l) c_stopLossIterations=$OPTARG ;;
      p) c_takeProfitIterations=$OPTARG ;;
      c) c_inputAmount=$OPTARG ;;
      v) c_verbosity=true ;;
      *) print_usage ;;
    esac
  done
  source color_utilities__sourceable.sh # Sourcing before would hijack the input parameters.
  d_numberOfInterestApplicationPerIteration=1 # Kept as 1 as I want to normalize the calculation with the time interval.
  d_timePeriod=1 # Since we will reapply the calculation for each iteration, we only need one time period.
  d_amount=$c_initialAmount
}

function process_data {
  o_expectedValues=[]
  set_equation
  o_equation=$d_equation
  calculate
  o_amountAfterIteration=$d_expectedValue
  d_timePeriod=1 # Since we will reapply the calculation for each iteration, we only need one time period.
  i=1
  d_referenceIteration=0 # Will indicate the current position.
  # This while loop is a duplicate from the one after and used only to get the reference iteration to allow formating the SL iteration which lies in the past. Redundant but cheap.
  while [ "$i" -le "$c_numberOfIterations" ]; do
     set_equation
     calculate
     o_expectedValues[$i]=$d_expectedValue
     if  [ $d_referenceIteration -eq 0 ] && [ $(echo "$d_expectedValue>$c_inputAmount"|bc) == 1 ]; then # Bash doesn't compare floats, therefore bc.
       if [ $(echo "$lastDiff>=$d_expectedValue-$c_inputAmount"|bc) == 1 ]; then
         d_referenceIteration=$i
       else
         d_referenceIteration=$((i-1))
       fi
     else
       lastDiff=$(echo "$c_inputAmount-$d_expectedValue"|bc)
     fi
     d_amount=$d_expectedValue # Why d_timePeriod is set to 1 above.
     ((i=i+1))
  done
}

function send_output {
  if [ $c_verbosity == true ]; then
    echo "Initial Amount: $c_initialAmount"
    echo "Number of Iterations: $c_numberOfIterations"
    echo "Interest Rate: $c_interestRate"
    echo "Equation of Compounded Interest: $o_equation"
    echo "Amount after $c_numberOfIterations Iteration(s): $o_amountAfterIteration"
    echo "******"
    echo "REPORT"
    echo "******"
  fi
  i=1
  while [ "$i" -le "$c_numberOfIterations" ]; do
     row="Iteration $i -- Expected Value: ${o_expectedValues[$i]}"
     if [ "$i" == "$d_referenceIteration" ]; then
       print_text_with_color_and_background "$row" 7 246 # White on grey
     elif [ "$i" == $(("$d_referenceIteration"-"$c_stopLossIterations")) ]; then
       print_text_with_color_and_background "$row" 7 196 # White on red
     elif [ "$i" == $(("$d_referenceIteration"+"$c_takeProfitIterations")) ]; then
       print_text_with_color_and_background "$row" 7 34 # White on green
     else
       if [ $c_verbosity == true ]; then
         printf "$row\n"
       fi
     fi
     ((i=i+1))
  done
}

initialize_input $@
process_data
send_output
