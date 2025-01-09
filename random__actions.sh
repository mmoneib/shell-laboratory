#!/bin/sh
################################################################################
# Random Actions                                                               #
#                                                                              #
# A set of functions to perfom simple random simulations or provide tools for  #
# Monte Carlo simulations and random sampling.                                 #
#                                                                              #
# Type: Actions                                                                #
# Dependencies: Unix-like Shell (tested with Bash)                             #
#	bash, bc.                                                              #
# Developed by: Muhammad Moneib                                                #
################################################################################

#TODO Avoid using bc in case of nod decimals.
#TODO Catch when 0 is returned due to out of boundaries result.

# Positional parameters inside action functions are used especially for the case of sourcing.
# Required parameters are denoted with the p_r_ prefix.
# Optional parameters are denoted with the p_o_ prefix.

function __print_usage {
  sh $(dirname $0)/help__actions.sh -a print_actions_usage -t $0
  exit
}

function __print_help {
  sh $(dirname $0)/help__actions.sh -a print_actions_help -t $0
  exit
}

function __print_missing_parameter_error {
  sh $(dirname $0)/help__actions.sh -a print_missing_parameter_error -p $1
  exit 1
}

function __print_incorrect_action_error {
  sh $(dirname $0)/help__actions.sh -a print_incorrect_action_error
  exit 1
}

function __has_decimal_point {
  result=$(echo "$1" | grep "[0-9]\.[0-9]")
  [ -z $result ] && echo "false" || echo "true"
}

## Calculate aggregate of a random walk based on numerical choices added to an aggregate with each iteration. Choices must be numerical.
function arithmetic_random_walk_aggregate {
  [ -z "$p_o_separatedChoicesText" ] && __print_missing_parameter_error "separated_choices_text"
  [ -z "$p_o_numberOfTries" ] && __print_missing_parameter_error "number_of_tries"
  IFS=","; read -a choices <<< "$p_o_separatedChoicesText"
  numberOfTries=$p_o_numberOfTries
  aggregation=0
  while [ $numberOfTries -gt 0 ]; do 
    choiceIndex=$(( RANDOM%${#choices[@]} ))
    aggregation=$(( aggregation+${choices[choiceIndex]} ))
    numberOfTries=$(( numberOfTries-1 ))
  done
  echo $aggregation
}

## Generate a random sequence out of the choices provided and with the specified separator inbetween.
function generate_random_sequence {
  [ -z "$p_o_separatedChoicesText" ] && __print_missing_parameter_error "separated_choices_text"
  [ -z "$p_o_numberOfTries" ] && __print_missing_parameter_error "number_of_tries"
  [ -z "$p_o_separator" ] && [ "$p_o_separator" != "" ] && __print_missing_parameter_error "separator"
  IFS=","; read -a choices <<< "$p_o_separatedChoicesText"
  numberOfChoices=${#choices[@]}
  count=0
  output=""
  while [ $count -lt $p_o_numberOfTries ]; do
    choice="${choices[(( RANDOM%numberOfChoices ))]}"
    output+="$choice$p_o_separator"
    (( count++ ))
  done
  echo "$output"
}

## Generate a random sequence out of mixed case english alphabet with digits and with the specified separator inbetween.
function generate_random_sequence_of_chars_and_digits {
  [ -z "$p_o_numberOfTries" ] && __print_missing_parameter_error "number_of_tries"
  [ -z "$p_o_separator" ] && [ "$p_o_separator" != "" ] && __print_missing_parameter_error "separator"
  p_o_separatedChoicesText="q,w,e,r,t,y,u,i,o,p,a,s,d,f,g,h,j,k,l,z,x,c,v,,b,n,m,Q,W,E,R,T,Y,U,I,O,P,A,S,D,F,G,H,J,K,L,Z,X,C,V,B,N,M,0,1,2,3,4,5,6,7,8,9"
  generate_random_sequence
}

## Generate a random sequence out of lower case english alphabet and with the specified separator inbetween.
function generate_random_sequence_of_chars_lower_case {
  [ -z "$p_o_numberOfTries" ] && __print_missing_parameter_error "number_of_tries"
  [ -z "$p_o_separator" ] && [ "$p_o_separator" != "" ] && __print_missing_parameter_error "separator"
  p_o_separatedChoicesText="q,w,e,r,t,y,u,i,o,p,a,s,d,f,g,h,j,k,l,z,x,c,v,,b,n,m"
  generate_random_sequence
}

## Generate a random sequence out of mixed case english alphabet and with the specified separator inbetween.
function generate_random_sequence_of_chars_mixed_case {
  [ -z "$p_o_numberOfTries" ] && __print_missing_parameter_error "number_of_tries"
  [ -z "$p_o_separator" ] && [ "$p_o_separator" != "" ] && __print_missing_parameter_error "separator"
  p_o_separatedChoicesText="q,w,e,r,t,y,u,i,o,p,a,s,d,f,g,h,j,k,l,z,x,c,v,,b,n,m,Q,W,E,R,T,Y,U,I,O,P,A,S,D,F,G,H,J,K,L,Z,X,C,V,B,N,M"
  generate_random_sequence
}

## Generate a random sequence out of upper case english alphabet and with the specified separator inbetween.
function generate_random_sequence_of_chars_upper_case {
  [ -z "$p_o_numberOfTries" ] && __print_missing_parameter_error "number_of_tries"
  [ -z "$p_o_separator" ] && [ "$p_o_separator" != "" ] && __print_missing_parameter_error "separator"
  p_o_separatedChoicesText="Q,W,E,R,T,Y,U,I,O,P,A,S,D,F,G,H,J,K,L,Z,X,C,V,B,N,M"
  generate_random_sequence
}

## Generate a random sequence out of digits and with the specified separator inbetween.
function generate_random_sequence_of_digits {
  [ -z "$p_o_numberOfTries" ] && __print_missing_parameter_error "number_of_tries"
  [ -z "$p_o_separator" ] && [ "$p_o_separator" != "" ] && __print_missing_parameter_error "separator"
  p_o_separatedChoicesText="0,1,2,3,4,5,6,7,8,9"
  generate_random_sequence
}

## Calculate product of a random walk based on numerical choices added to an aggregate with each iteration. Choices must be numerical.
function geometric_random_walk_product {
  #echo "$(__has_decimal_point $p_o_separatedChoicesText)"
  [ -z "$p_o_separatedChoicesText" ] && __print_missing_parameter_error "separated_choices_text"
  [ -z "$p_o_numberOfTries" ] && __print_missing_parameter_error "number_of_tries"
  IFS=","; read -a choices <<< "$p_o_separatedChoicesText"
  numberOfTries=$p_o_numberOfTries
  product=1
  while [ $numberOfTries -gt 0 ]; do 
    choiceIndex=$(( RANDOM%${#choices[@]} ))
    product=$(echo "scale=5;$product*${choices[choiceIndex]}"|bc -l)
    numberOfTries=$(( numberOfTries-1 ))
  done
  echo $product
}

[ -z "$1" ] && __print_usage
# Parse options and parameters.
while getopts "ha:c:n:s:" o; do
  case $o in
    ## The name of the function to be triggered.
    a) p_r_action=$OPTARG ;;
    ## Number of tries or iterations.
    n) p_o_numberOfTries=$OPTARG ;;
    ## List of choices separated by a comma.
    c) p_o_separatedChoicesText=$OPTARG ;;
    ## Separator to separate entries in an output sequence.
    s) p_o_separator=$OPTARG ;;
    h) __print_help ;;
    *) __print_usage ;;
  esac
done
[ -z "$p_r_action" ] && __print_incorrect_action_error
# Generic action call with protection against script injection.
[ ! -z "$(grep "^function $p_r_action" $0)" ] && $p_r_action || __print_incorrect_action_error
