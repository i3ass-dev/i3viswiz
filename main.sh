#!/bin/bash

main(){

  # __o[verbose]=1

  ((__o[verbose])) && {
    declare -gi _stamp
    _stamp=$(date +%s%N)
    ERM $'\n'"---i3viswiz start---"
  }

  trap 'cleanup' EXIT

  arg_target=${__lastarg:-X}

    if ((__o[title]));       then arg_type=name
  elif ((__o[titleformat])); then arg_type=title_format
  elif ((__o[parent]));      then arg_type=i3fyracontainer
  elif ((__o[instance]));    then arg_type=instance
  elif ((__o[class]));       then arg_type=class
  elif ((__o[winid]));       then arg_type=winid

  elif [[ $arg_target = X ]]; then
    arg_type=instance
  else
    arg_type="direction"

    arg_target="${arg_target,,}"
    arg_target="${arg_target:0:1}"

    [[ $arg_target =~ l|r|u|d ]] \
      || ERH "$__lastarg not valid direction (l|r|u|d)"
  fi

  : "${__o[json]:=$(i3-msg -t get_tree)}"
  : "${__o[debug]:=LIST}"
  : "${__o[debug-format]:=%k=%v }"
  arg_gap=$((__o[gap] > 0 ? __o[gap] : 5))

  # check if focus_wrap workspace is set
  # by looking for a mark on root container (i3var)
  # if no mark exist, check config, set the mark
  re='^\{"id":([0-9]+)[^[]+\[([^]]*"focus_wrap=([^"]*)"[^]]*)?\]'
  [[ ${__o[json]} =~ $re ]] || {
    i3-msg -t get_config | grep -E 'focus_wrapping\s+workspace' > /dev/null \
      && wrapping=workspace

    i3var set focus_wrap "${wrapping:-normal}"
  }

  result=$(
    # <<<    - content of string __o[json] will be input  to command awk
    # -f <() - output of awklib will be interpreted as file containg AWK script
    # FS     - change Field  Separator to ":" (from whitespace)
    # RS     - change Record Separator to "," (from linebreak)
    # arg_   - these variables is available in the AWK script
    <<< "${__o[json]}" awk -f <(awklib) FS=: RS=, \
    arg_type="$arg_type" arg_gap="$arg_gap" arg_target="$arg_target" \
    arg_debug="${__o[debug]}" arg_debug_format="${__o[debug-format]}"
  )
  
  if [[ $result =~ ^floating ]]; then

    case "$arg_target" in
      l|u ) direction=prev   ;;
      r|d ) direction=next   ;;
      *   ) ERX "$arg_target not valid direction (l|r|u|d)" ;;
    esac

    messy i3-msg -q focus $direction

  elif [[ $arg_type != direction && ! ${__o[focus]} ]]; then
    echo "$result"
  elif [[ $result =~ ^[0-9]+ ]]; then

    read -r target_id active_id root_id marked_id <<< "$result"

    [[ $arg_type = direction ]] && {

      # i3var set viswiz-last-direction "$active_id"
      # manually update i3vars for performance reasons
      variable_name=i3viswiz-last-direction
      new_mark="${variable_name}=$active_id"

      # this will remove the old mark
      [[ $marked_id ]] && {
        old_mark="${variable_name}=$marked_id"
        messy "[con_mark=$old_mark] mark --toggle --add $old_mark"
      }

      messy "[con_id=$root_id] mark --add $new_mark"

    }

    messy "[con_id=$target_id]" focus
  else
    ERX "focus failed. '$result' doesn't make any sense"
  fi
}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "$@"                                       #bashbud
