#!/usr/bin/env bash

listvisible(){

  [[ -n ${_json:=${__o[json]}} ]] \
    || _json=$(i3-msg -t get_tree)

  awk -f <(awklib) \
  FS=: RS=, opret="$1" gapsz="$2" dir="$3" \
  <<< "$_json"
}
