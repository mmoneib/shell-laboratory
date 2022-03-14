#!/bin/bash

################################################################################
# Fluid To Do
################################################################################

RESOURCE_DIR="resources/fluid_todo/"
LIST_FILE_NAME="fluid_todo_list"
FILE_PATH="$RESOURCE_DIR/$LIST_FILE_NAME"
TODAY="TODAY"
LATER="LATER"
ACTIONS=( "add_task" "print_raw_list" "show_tasks" "modify_task" )
SEPARATOR="|"
HEADER="N. DueDate'$SEPARATOR'Task'$SEPARATOR'StarvationTolerance"
NUM_OF_FIELDS=3

function usage() {
  echo "USAGE: fluid_todo.sh action_here [parameters]
         Actions:
           add_task task_here due_date_here starvation_tolerance_here
           print_raw_list
           show_tasks
           modify_task task_number_here
         Paramters:
           task: The summary of the task.
           due_date: Only 2 values are allowed, 'today' or 'later'.
           starvation_tolerance: Any integer between 0 and 100 inclusive. This controls the probability of a task being forcibly marked for 'today'.
           task_number: The line number of the task in the raw file as shown with the action 'print_raw_list'.
        "
}

function initialize {
  if [ -z "$1" ] || [ "-h" == "$1" ] || [ "--help" == "$1" ]; then
    usage
    exit
  fi
  isThere=0
  for action in ${ACTIONS[@]}; do
    if [ "$action"  ==  "$1" ]; then
      isThere=1
    fi
  done
  if [ $isThere == 0 ]; then
    usage
    exit 1
  fi
  if [ ! -d $RESOURCE_DIR ]; then
    mkdir $RESOURCE_DIR
  fi
  touch "$RESOURCE_DIR/$LIST_FILE_NAME"

}

function validate_entry {
 dueDate=$1
 starvationTolerance=$2
 if [ "${dueDate^^}" != "$TODAY" ] && [ "${dueDate^^}" != "$LATER" ]; then
    echo "PARAMETER_VALIDATION_ERROR: DUE DATE MUST BE 'TODAY' OR 'LATER' CASE INSENSITIVE." >&2
    echo "false" 
  fi
  if [ "$starvationTolerance" -lt "0" ] || [ "$starvationTolerance" -gt "100" ]; then
    echo "PARAMETER_VALIDATION_ERROR: STARVATION TOLERANCE MUST BE BETWEEN 0 AND 100." >&2
    echo "false"
  fi
  echo "true"
}

function add_task {
  if [ ${#@} != $NUM_OF_FIELDS ]; then
    echo "PARAMETER_COUNT_ERROR: add_task function expects 3 parameters."
    exit 1
  fi
  dueDate=$1
  task=$2
  starvationTolerance=$3
  if [ "${dueDate^^}" != "$TODAY" ] && [ "${dueDate^^}" != "$LATER" ]; then
    echo "PARAMETER_VALIDATION_ERROR: DUE DATE MUST BE 'TODAY' OR 'LATER' CASE INSENSITIVE." >&2
    exit 1 
  fi
  if [ "$starvationTolerance" -lt "0" ] || [ "$starvationTolerance" -gt "100" ]; then
    echo "PARAMETER_VALIDATION_ERROR: STARVATION TOLERANCE MUST BE BETWEEN 0 AND 100." >&2
    exit 1 
  fi
  echo "$1|$2|$3" >> "$FILE_PATH"
}

# Print the list file as is.
function print_raw_list  {
  echo $HEADER
  echo "..."
  lineCount=0
  while read line; do
    echo "$((++lineCount)). $line"
  done
} <<< "$(cat "$FILE_PATH")"

# Prints the task in a pretty format.
function show_tasks {
  echo "~~~~~"
  echo "TODAY"
  echo "~~~~~"
  echo "$(grep -i today $FILE_PATH|cut -d "|" -f 2)"
  echo "~~~~~"
  echo "LATER"
  echo "~~~~~"
  echo "$(grep -i later $FILE_PATH|cut -d "|" -f 2)"
}

function modify_task {
  taskNumber=$1
  lineToBeModified="$(head -$taskNumber $FILE_PATH|tail -1)"
  echo "Line to be modied: $lineTpBeModified"
  read -p "Enter modified line: " inputLine
  countOfSeparators=0
  while read -n1 inputChar; do
    if [ "$inputChar" == "$SEPARATOR" ]; then
      (( countOfSeparators++ ))
    fi
  done <<< "$inputLine"
  if [ $countOfSeparators != $(( $NUM_OF_FIELDS-1 )) ]; then
    echo "ERROR $countOfSeparators $(($NUM_OF_FIELDS-1))"
  fi
}

initialize "$@"
# Arguments are passed from the terminal without quotes but with correct parsing, which is lost when passed as it to a function. Here, I am preserving the correct parsing through quotes.
command=$1
shift
for (( i=1 ; ((i<${#@}+1)); i++ )) do
  command+=" \"${!i}\""
done
eval $command # Used eval to preserve quotations around arguments.
