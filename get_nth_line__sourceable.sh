#!/bin/bash
################################################################################
# Get the Nth Line.                                                            #
#                                                                              #
# Description: Does as the title says.                                         #
#                                                                              #
# Type: To be used as a standalone or sourced by other scripts.                #
# Dependencies: Bash                                                           #
# Developed by: Muhammad Moneib                                                #
################################################################################

f=$2;
n=$1;
str=$( head -$n $f | tail -1 ); # $() for evaluating command with spaces.
echo $str;
