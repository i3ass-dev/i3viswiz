#!/usr/bin/env bash

listvisible(){
  awk -f <(awklib) \
  FS=: RS=, opret="$1" gapsz="$2" dir="$3" \
  <(echo "$4")
}
