#!/bin/bash
f=$2;
n=$1;
str=$( head -$n $f | tail -1 ); # $() for evaluating command with spaces.
echo $str;
