#!/bin/sh
################################################################################
# Wealth Ladder                                                                #
#                                                                              #
# A wealth building tool through gradual, defined, small steps of compounded   #
# interest, taking into consideration the human psychology and the need for    # 
# risk control, all calculated and visualized in a convenient way.             #
#                                                                              #
# Type: Linear Process.                                                        #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#     color__actions.sh.                                                       #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c for config, d for data, and o for output.

#TODO Review order of options.

scriptFile=$0
scriptPath=$(dirname $scriptFile)
color__actions="$scriptPath/""color__actions.sh"

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
  c_o_verbosity=false
  while getopts "i:r:n:l:p:c:o:g:vhw" o; do
    case "$o" in
      ## The initial amount of money used in the investment.
      i) c_r_initialAmount=$OPTARG ;;
      ## The interest rate applied to the running amount after each period.
      r) c_r_interestRate=$OPTARG ;;
      ## The number of period constituting the investment time.
      n) c_r_numberOfIterations=$OPTARG ;;
      ## Stop Loss level in terms of number of levels allowed to regress back to in a losing trade.
      l) c_o_stopLossIterations=$OPTARG ;;
      ## Take Profit in terms of number of levels hoped to jump to in a winning trad.
      p) c_o_takeProfitIterations=$OPTARG ;;
      ## The running amount of money by which the upcoming trade would start.
      c) c_o_currentAmount=$OPTARG ;;
      ## The running amount of money calculated in terms of the opposit (non-notional) currency. Mainly for FOREX and Crypto trades.
      o) c_o_currentOppositeAmount=$OPTARG ;;
      ## The running effective amount (with leverage factor multiplied) in the notional currency; effective in the sense of the amount traded, not owned.
      g) c_o_currentLeveragedAmount=$OPTARG ;;
      ## Be verbose and print the whole ladder of periods and compounded progression plus additional information abou the current position.
      v) c_o_verbosity=true ;;
      ## If true, print raw output (comma-separated) ready to be put as input of other scripts. If false, pretty print the output for clarity.
      w) c_o_isRawOutput=true ;;
      h) __print_help ;;
      *) __print_usage ;;
    esac
  done
  if [ -z $c_r_initialAmount ] || [ -z $c_r_interestRate ] || [ -z $c_r_numberOfIterations ]; then
    __print_usage
  fi 
  if [ -z $c_o_currentAmount ]; then
    c_o_currentAmount=$c_r_initialAmount
  fi
  d_numberOfInterestApplicationPerIteration=1 # Kept as 1 as I want to normalize the calculation with the time interval.
  d_timePeriod=$c_r_numberOfIterations # Since we will reapply the calculation for each iteration, we only need one time period.
  d_amount=$c_r_initialAmount
}

function get_expected_value_equation {
  echo "$d_amount*(1+$c_r_interestRate*$leverageFactor/$d_numberOfInterestApplicationPerIteration)^($d_numberOfInterestApplicationPerIteration*$d_timePeriod)"
}

function process_data {
  o_expectedValues=[]
  o_overallProfits=[]
  if [ ! -z "$c_o_currentAmount" ] && [ ! -z "$c_o_currentLeveragedAmount" ]; then
    leverageFactor=$(echo "scale=2;$c_o_currentLeveragedAmount/$c_o_currentAmount"|bc -l)
  else
    leverageFactor=1 # Better to avoid branching in the code.
  fi
  d_expectedValueEquation=$(get_expected_value_equation)
  o_equation=$d_expectedValueEquation # For printing purposes.
  o_amountAfterIteration=$(echo "scale=6;$d_expectedValueEquation"|bc -l)
  if [ ! -z "$c_o_currentAmount" ] && [ ! -z "$c_o_currentOppositeAmount" ]; then
    if [ "$leverageFactor" != "1" ]; then
      factor=$c_o_currentLeveragedAmount
    else
      factor=$c_o_currentAmount
    fi
    exchangeRate=$(echo "scale=6;$c_o_currentOppositeAmount/$factor"|bc -l)
  fi
  d_timePeriod=1 # Since we will reapply the calculation for each iteration, we only need one time period.
  i=1
  d_referenceCurrentIteration=0 # Will indicate the current position.
  currentMinusPreviousAmount=0
  while [ "$i" -le "$c_r_numberOfIterations" ]; do
     d_expectedValueEquation=$(get_expected_value_equation)
     d_expectedValue=$(echo "scale=6;$d_expectedValueEquation"|bc -l)
     o_expectedValues[$i]=$d_expectedValue
     o_overallProfits[$i]=$(echo "scale=6;($d_expectedValue)-$c_r_initialAmount"|bc -l)
     if [ ! -z "$exchangeRate" ]; then
       factor="$exchangeRate*$leverageFactor"
       o_oppositeValues[$i]=$(echo "scale=6;$d_expectedValue*$factor"|bc -l)
     fi
     if [ $d_referenceCurrentIteration -eq 0 ] && [ $(echo "$d_expectedValue>$c_o_currentAmount"|bc) == 1 ]; then # Bash doesn't compare floats, therefore bc.
       if [ $(echo "$currentMinusPreviousAmount>=$d_expectedValue-$c_o_currentAmount"|bc) == 1 ]; then #
         d_referenceCurrentIteration=$i
       else
         d_referenceCurrentIteration=$((i-1))
       fi
     else
       currentMinusPreviousAmount=$(echo "$c_o_currentAmount-$d_expectedValue"|bc)
     fi
     d_amount=$d_expectedValue # Reason why d_timePeriod is set to 1 above.
     ((i=i+1))
  done
  o_referenceCurrentIteration=$d_referenceCurrentIteration
  o_exchangeRate=$exchangeRate
  o_leverageFactor=$leverageFactor
}

function pretty_output {
  if [ $c_o_verbosity == true ]; then
    echo "Initial Amount: $c_r_initialAmount"
    echo "Number of Iterations: $c_r_numberOfIterations"
    echo "Interest Rate: $c_r_interestRate"
    echo "Leverage Factor: $o_leverageFactor""X"
    echo "Equation of Compounded Interest: $o_equation"
    echo "Amount after $c_r_numberOfIterations Iteration(s): $o_amountAfterIteration"
    [ ! -z $o_exchangeRate ] && echo "Exchange Rate: $o_exchangeRate"
    echo "******"
    echo "REPORT"
    echo "******"
  fi
  i=1
  while [ "$i" -le "$c_r_numberOfIterations" ]; do
     row="Iteration $i -- Expected Value: ${o_expectedValues[$i]}"
     if [ ! -z "$o_exchangeRate" ]; then
       row="$row -- Opposite Leveraged Value: ${o_oppositeValues[$i]}"
     fi
     row="$row -- Overall Profit: ${o_overallProfits[$i]}"
     if [ "$i" == "$o_referenceCurrentIteration" ]; then
       sh $color__actions -a print_text_with_color_and_background -t "$row" -c 7 -b 246 # White on grey
     elif [ ! -z "$c_o_stopLossIterations" ] && [ "$i" == $(("$o_referenceCurrentIteration"-"$c_o_stopLossIterations")) ]; then
       sh $color__actions -a print_text_with_color_and_background -t "$row" -c 7 -b 196 # White on red
     elif [ ! -z "$c_o_takeProfitIterations" ] && [ "$i" == $(("$o_referenceCurrentIteration"+"$c_o_takeProfitIterations")) ]; then #TODO Calc should move to processing.
       sh $color__actions -a print_text_with_color_and_background -t "$row" -c 7 -b 34 # White on green
     else
       if [ $c_o_verbosity == true ]; then
         printf "$row\n"
       fi
     fi
     ((i=i+1))
  done
}

# TODO Escape commas or use generic separator
function raw_output {
  echo "leverageFactor,$o_leverageFactor"
  echo "equation,$o_equation"
  echo "amountAfterIteration,$o_amountAfterIteration"
  echo "exchangeRate,$o_exchangeRate"
  for (( i=0;i<${#o_expectedValues[@]};i++ )); do
    echo "expectedValues[$i],${o_expectedValues[i]}"
  done
  for (( i=0;i<${#o_oppositeValues[@]}; i++ )); do
    echo "oppositeValues[$i],${o_oppositeValues[i]}"
  done
  for (( i=0;i<${#o_overallProfits[@]}; i++ )); do
    echo "overallProfits[$i],${o_overallProfits[i]}"
  done
}

function output {
  if [ $c_o_isRawOutput ]; then
    raw_output
  else
    pretty_output
  fi
}

initialize_input $@
process_data
output
