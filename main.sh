#!/usr/bin/env bash

main(){

  local arg_target arg_type dir

  declare -g _json

  arg_target=${__lastarg:-X}
  types=(title titleformat class instance winid parent)

  for arg_type in "${types[@]}"; do
    ((__o[$arg_type])) && break
    unset arg_type
  done

  if [[ -z $arg_type && $arg_target = X ]]; then
    ERH "no command or option specified"
  elif [[ -z $arg_type ]]; then
    arg_target="${arg_target,,}"
    arg_target="${arg_target:0:1}"

    [[ $arg_target =~ l|r|u|d ]] \
      || ERH "$__lastarg not valid direction (l|r|u|d)"

    arg_type="direction"
  fi

  : "${__o[gap]:=5}"

  result="$(listvisible "$arg_type"        \
                        "${__o[gap]}"  \
                        "$arg_target"      \
           )"

  if ((__o[focus])); then
    [[ $result =~ ^[0-9]+$ ]] \
      && exec i3-msg -q "[con_id=$result]" focus
    exit 1

  elif [[ $arg_type = direction ]]; then
    eval "$(head -1 <<< "$result")"

    if [[ ${trgcon:=} = floating ]]; then

      case $arg_target in
        l ) dir=left   ;;
        r ) dir=right  ;;
        u ) dir=left   ;;
        d ) dir=right  ;;
      esac

      i3-msg -q focus $dir

    else
      [[ -z $trgcon ]] && ((__o[gap]+=15)) && {
        eval "$(listvisible "$arg_type"        \
                            "${__o[gap]}"  \
                            "$arg_target" | head -1
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
