#!/usr/bin/env bash
#Wrapping script with the intention to be used as an external tool from IntelliJ.
#TODO Embed configuration file inside the script.
echo "Started formatting using Eclipse."
eclipse -application org.eclipse.jdt.core.JavaCodeFormatter -config org.eclipse.jdt.core.prefs $@
echo "Finished formatting using Eclipse."