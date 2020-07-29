#!/usr/bin/env bash

main(){

  local target type dir

  declare -g _json

  target=${__lastarg:-X}

  if [[ -n ${__o[title]} ]]; then
    type=title
  elif [[ -n ${__o[titleformat]} ]]; then
    type=titleformat
  elif [[ -n ${__o[instance]} ]]; then
    type=instance
  elif [[ -n ${__o[class]} ]]; then
    type=class
  elif [[ -n ${__o[winid]} ]]; then
    type=winid
  elif [[ -n ${__o[parent]} ]]; then
    type=parent
  else
    type="direction"
    target="${target,,}"
    target="${target:0:1}"

    [[ ! $target =~ l|r|u|d ]] && {
      ___printhelp
      exit
    }

  fi

  [[ -n ${_json:=${__o[json]}} ]] \
    || _json=$(i3-msg -t get_tree)

  : "${__o[gap]:=5}"

  result="$(listvisible "$type"        \
                        "${__o[gap]}"  \
                        "$target" \
                        "$_json"
           )"

  if ((__o[focus])); then

    [[ $result =~ ^[0-9]+$ ]] \
      && exec i3-msg -q "[con_id=$result]" focus
    exit 1

  elif [[ $type = direction ]]; then
    eval "$(head -1 <<< "$result")"

    if [[ ${trgcon:=} = floating ]]; then

      case $target in
        l ) dir=left   ;;
        r ) dir=right  ;;
        u ) dir=left   ;;
        d ) dir=right  ;;
      esac

      i3-msg -q focus $dir

    else
      [[ -z $trgcon ]] && ((__o[gap]+=15)) && {
        eval "$(listvisible "$type"        \
                            "${__o[gap]}"  \
                            "$target" \
                            "$_json" | head -1
               )"
      }

      [[ -n $trgcon ]] \
        && i3-msg -q "[con_id=$trgcon]" focus
    fi
  else
    echo "$result"
  fi
}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "$@"                                       #bashbud
