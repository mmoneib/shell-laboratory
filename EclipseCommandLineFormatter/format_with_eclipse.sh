#!/usr/bin/env bash
echo "Started formatting using Eclipse."
eclipse -application org.eclipse.jdt.core.JavaCodeFormatter -config org.eclipse.jdt.core.prefs $@
echo "Finished formatting using Eclipse."