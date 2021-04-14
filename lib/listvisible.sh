#!/usr/bin/env bash

listvisible(){

  [[ -n ${_json:=${__o[json]}} ]] \
    || _json=$(i3-msg -t get_tree)

  awk -f <(awklib) \
  FS=: RS=, arg_type="$1" arg_gap="$2" arg_target="$3" \
  <<< "$_json"
}
