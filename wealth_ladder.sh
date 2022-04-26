#!/bin/sh
################################################################################
# Wealth Ladder                                                                #
#                                                                              #
# A wealth building tool through gradual, defined, small steps of compounded   #
# interest, taking into consideration the human psychology and the need for    # 
# risk control, all calculated and visualized in a convenient way.             #
#                                                                              #
# Type: Process.                                                               #
# Dependencies: Unix-like Shell (tested with Bash), and                        #
#     color_utilities__sourceable.sh.                                          #
# Developed by: Muhammad Moneib                                                #
################################################################################

# Namspaces: c for config, d for data, and o for output.

# Sourcing from anywhere.
scriptFile=$0
followedScriptFile=$(readlink $scriptFile)
while [ ! -z $followedScriptFile ]; do
  scriptFile=$followedScriptFile
  followedScriptFile=$(readlink "$followedScriptFile")
done
scriptPath=$(dirname $scriptFile)
source "$scriptPath/"color_utilities__sourceable.sh "skip_run" # The parameter skips initialization output.

#TODO Move to resources.
usage="Usage: wealth_ladder.sh -i initial_amount_here -n number_of_iterations_here -r interest_rate_here [-c notional_amount_here [-p takeprofit_iterations_here] [-l stoploss_iterations_here] [-g leveraged_amount_here] [-o exchange_rate_here]] [-v]"
help="A simple investment mathematical plan through compounded interest accumulation based on the user's arguments. The plan is meant only to be used as a mathematical reference and not as a financial advice.
Arguments:
\tMandatory
\t-i: The initial notional amount at the start of the investment plan.
\t-n: The number of time periods during the planned investment at the beginning of which the interest would be applied.
\t-r: The fixed interest rate.
\t-c: The notional amount of the current trade.
\tOptional
\t-p: The number of step after which the current trade should be closed to take profit. Requires c.
\t-l: The number of step after which the current trade should be closed to stop loss. Requires c.
\t-g: The leveraged amount in the notional currency at the current investment. Requires c.
\t-o: The opposite amount in the quote currency at the current investment. Requires c.
\t-v: Show all the steps and details. Without, a minimalist output will show only the current step, the TP step, if enabled, and the SL step, if enabled.\n"

function print_usage {
  echo "$usage"
  echo "Try 'wealth_ladder.sh -h' for more information."
  exit
}

function print_help {
  echo "$usage"
  printf "$help"
  exit
}

function calculate_expected_value {
  d_expectedValue=$(echo "scale=6;"$d_equation|bc -l)
}

function set_compound_interest_equation {
  d_equation="$d_amount*(1+$c_interestRate/$d_numberOfInterestApplicationPerIteration)^($d_numberOfInterestApplicationPerIteration*$d_timePeriod)"
}

#TODO: Limit leakage of namespace variables.

function initialize_input {
  if [ -z $1 ]; then # Case of no options at all.
    print_usage
  fi
  c_verbosity=false
  while getopts "i:r:n:l:p:c:o:g:vh" o; do
    case "$o" in
      i) c_initialAmount=$OPTARG ;;
      r) c_interestRate=$OPTARG ;;
      n) c_numberOfIterations=$OPTARG ;;
      l) c_stopLossIterations=$OPTARG ;;
      p) c_takeProfitIterations=$OPTARG ;;
      c) c_currentAmount=$OPTARG ;;
      o) c_currentOppositeAmount=$OPTARG ;;
      g) c_currentLeveragedAmount=$OPTARG ;;
      v) c_verbosity=true ;;
      h) print_help ;;
      *) print_usage ;;
    esac
  done
  if [ -z $c_initialAmount ] || [ -z $c_interestRate ] || [ -z $c_numberOfIterations ]; then
    print_usage
  fi 
  if [ -z $c_currentAmount ]; then
    c_currentAmount=$c_initialAmount
  fi

  d_numberOfInterestApplicationPerIteration=1 # Kept as 1 as I want to normalize the calculation with the time interval.
  d_timePeriod=1 # Since we will reapply the calculation for each iteration, we only need one time period.
  d_amount=$c_initialAmount

}

function process_data {
  o_expectedValues=[]
  o_overallProfits=[]
  if [ ! -z "$c_currentOppositeAmount" ]; then
    exchangeRate=$(echo "scale=6;$c_currentOppositeAmount/$c_currentAmount"|bc -l)
  fi
  set_compound_interest_equation
  o_equation=$d_equation
  calculate_expected_value
  o_amountAfterIteration=$d_expectedValue
  if [ ! -z "$c_currentAmount" ] && [ ! -z "$c_currentLeveragedAmount" ]; then
    leverageFactor=$(echo "scale=2;$c_currentLeveragedAmount/$c_currentAmount"|bc -l)
  fi
  d_timePeriod=1 # Since we will reapply the calculation for each iteration, we only need one time period.
  i=1
  d_referenceIteration=0 # Will indicate the current position.
  lastDiff=0
  while [ "$i" -le "$c_numberOfIterations" ]; do
     set_compound_interest_equation
     calculate_expected_value
     #TODO Add step profit and overall profit as differential amount.
     if [ ! -z $leverageFactor ]; then
       o_expectedValues[$i]=$(echo "scale=6;$d_expectedValue*$leverageFactor"|bc -l)
       o_overallProfits[$i]=$(echo "scale=6;(${o_expectedValues[$i]}/$leverageFactor)-$c_initialAmount"|bc -l)
     else
       o_expectedValues[$i]=$d_expectedValue
       o_overallProfits[$i]=$(echo "scale=6;${o_expectedValues[$i]}-$c_initialAmount"|bc -l)
     fi
     if [ ! -z "$exchangeRate" ]; then
       #TODO Factorize
       if [ ! -z $leverageFactor ]; then
         o_oppositeValues[$i]=$(echo "scale=6;$d_expectedValue*$exchangeRate*$leverageFactor"|bc -l)
       else
         o_oppositeValues[$i]=$(echo "scale=6;$d_expectedValue*$exchangeRate"|bc -l)
       fi
     fi
     if [ $d_referenceIteration -eq 0 ] && [ $(echo "$d_expectedValue>$c_currentAmount"|bc) == 1 ]; then # Bash doesn't compare floats, therefore bc.
       if [ $(echo "$lastDiff>=$d_expectedValue-$c_currentAmount"|bc) == 1 ]; then
         d_referenceIteration=$i
       else
         d_referenceIteration=$((i-1))
       fi
     else
       lastDiff=$(echo "$c_currentAmount-$d_expectedValue"|bc)
     fi
     d_amount=$d_expectedValue # Why d_timePeriod is set to 1 above.
     ((i=i+1))
  done
  o_referenceIteration=$d_referenceIteration
  o_exchangeRate="$exchangeRate"
  o_leverageFactor=$leverageFactor
}

function send_output {
  if [ $c_verbosity == true ]; then
    echo "Initial Amount: $c_initialAmount"
    echo "Number of Iterations: $c_numberOfIterations"
    echo "Interest Rate: $c_interestRate"
    echo "Equation of Compounded Interest: $o_equation"
    echo "Amount after $c_numberOfIterations Iteration(s): $o_amountAfterIteration"
    [ ! -z $o_exchangeRate ] && echo "Exchange Rate: $o_exchangeRate"
    [ ! -z $o_leverageFactor ] && echo "Leverage Factor: $o_leverageFactor""X"
    echo "******"
    echo "REPORT"
    echo "******"
  fi
  i=1
  while [ "$i" -le "$c_numberOfIterations" ]; do
     row="Iteration $i -- Expected Value: ${o_expectedValues[$i]}"
     if [ ! -z "$o_exchangeRate" ]; then
       row="$row -- Opposite Value: ${o_oppositeValues[$i]}"
     fi
     row="$row -- Overall Profit: ${o_overallProfits[$i]}"
     if [ "$i" == "$o_referenceIteration" ]; then
       print_text_with_color_and_background "$row" 7 246 # White on grey
     elif [ ! -z "$c_stopLossIterations" ] && [ "$i" == $(("$o_referenceIteration"-"$c_stopLossIterations")) ]; then
       print_text_with_color_and_background "$row" 7 196 # White on red
     elif [ ! -z "$c_takeProfitIterations" ] && [ "$i" == $(("$o_referenceIteration"+"$c_takeProfitIterations")) ]; then
       print_text_with_color_and_background "$row" 7 34 # White on green
     else
       if [ $c_verbosity == true ] || [ "$i" == $(("$o_referenceIteration"-"$c_stopLossIterations")) ] || [ "$i" == $(("$o_referenceIteration"+"$c_takeProfitIterations")) ]; then
         printf "$row\n"
       fi
     fi
     ((i=i+1))
  done
}

initialize_input $@
process_data
send_output
