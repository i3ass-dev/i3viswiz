#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
i3viswiz - version: 0.467
updated: 2020-08-10 by budRich
EOB
}




___printhelp(){
  
cat << 'EOB' >&2
i3viswiz - Professional window focus for i3wm


SYNOPSIS
--------
i3viswiz [--gap|-g GAPSIZE] DIRECTION  [--json JSON]
i3viswiz --title|-t       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --instance|-i    [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --class|-c       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --titleformat|-o [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --winid|-d       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --parent|-p      [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --help|-h
i3viswiz --version|-v

OPTIONS
-------

--gap|-g TARGET  
Set GAPSIZE (defaults to 5). GAPSIZE is the
distance in pixels from the current window where
new focus will be searched.  


--json JSON  
use JSON instead of output from  i3-msg -t
get_tree


--title|-t  
If TARGET matches the TITLE of a visible window,
that windows  CON_ID will get printed to stdout.
If no TARGET is specified, a list of all tiled
windows will get printed with  TITLE as the last
field of each row.


--focus|-f  
When used in conjunction with: --titleformat,
--title, --class, --instance, --winid or --parent.
The CON_ID of TARGET window will get focused if it
is visible.


--instance|-i  
If TARGET matches the INSTANCE of a visible
window, that windows  CON_ID will get printed to
stdout. If no TARGET is specified, a list of all
tiled windows will get printed with  INSTANCE as
the last field of each row.


--class|-c  
If TARGET matches the CLASS of a visible window,
that windows  CON_ID will get printed to stdout.
If no TARGET is specified, a list of all tiled
windows will get printed with  CLASS as the last
field of each row.


--titleformat|-o  
If TARGET matches the TITLE_FORMAT of a visible
window, that windows  CON_ID will get printed to
stdout. If no TARGET is specified, a list of all
tiled windows will get printed with  TITLE_FORMAT
as the last field of each row.


--winid|-d  
If TARGET matches the WIN_ID of a visible window,
that windows  CON_ID will get printed to stdout.
If no TARGET is specified, a list of all tiled
windows will get printed with  WIN_ID as the last
field of each row.



--parent|-p  
If TARGET matches the PARENT of a visible window,
that windows  CON_ID will get printed to stdout.
If no TARGET is specified, a list of all tiled
windows will get printed with  PARENT as the last
field of each row.


--help|-h  
Show help and exit.


--version|-v  
Show version and exit.
EOB
}


for ___f in "${___dir}/lib"/*; do
  source "$___f"
done

declare -A __o
options="$(
  getopt --name "[ERROR]:i3viswiz" \
    --options "g:tficodphv" \
    --longoptions "gap:,json:,title,focus,instance,class,titleformat,winid,parent,help,version," \
    -- "$@" || exit 98
)"

eval set -- "$options"
unset options

while true; do
  case "$1" in
    --gap        | -g ) __o[gap]="${2:-}" ; shift ;;
    --json       ) __o[json]="${2:-}" ; shift ;;
    --title      | -t ) __o[title]=1 ;; 
    --focus      | -f ) __o[focus]=1 ;; 
    --instance   | -i ) __o[instance]=1 ;; 
    --class      | -c ) __o[class]=1 ;; 
    --titleformat | -o ) __o[titleformat]=1 ;; 
    --winid      | -d ) __o[winid]=1 ;; 
    --parent     | -p ) __o[parent]=1 ;; 
    --help       | -h ) ___printhelp && exit ;;
    --version    | -v ) ___printversion && exit ;;
    -- ) shift ; break ;;
    *  ) break ;;
  esac
  shift
done

[[ ${__lastarg:="${!#:-}"} =~ ^--$|${0}$ ]] \
  && __lastarg="" 




