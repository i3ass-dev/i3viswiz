#!/usr/bin/env bash

main(){

  local arg_target arg_type
  
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

  declare -i arg_gap=$((__o[gap] ? __o[gap] : 5))

  [[ $arg_type = titleformat ]] && arg_type=title_format

  result="$(listvisible "$arg_type"   \
                        "$arg_gap"    \
                        "$arg_target" \
           )"

  if ((__o[focus])); then
    [[ $result =~ ^[0-9]+$ ]] \
      || ERX "focus failed. $result is not a valid containerID"

      exec i3-msg -q "[con_id=$result]" focus

  elif [[ $arg_type = direction ]]; then
    eval "$(head -1 <<< "$result")"

    if [[ ${trgcon:=} = floating ]]; then

      case $arg_target in
        l ) direction=left   ;;
        r ) direction=right  ;;
        u ) direction=left   ;;
        d ) direction=right  ;;
      esac

      exec i3-msg -q focus $direction

    else
      [[ -z $trgcon ]] && ((arg_gap+=15)) && {
        eval "$(listvisible "$arg_type"   \
                            "$arg_gap"    \
                            "$arg_target" | head -1
               )"
      }

      [[ $trgcon ]] && exec i3-msg -q "[con_id=$trgcon]" focus
      
    fi
  else
    echo "$result"
  fi
}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "$@"                                       #bashbud
