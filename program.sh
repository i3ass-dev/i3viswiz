#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
i3viswiz - version: 0.242
updated: 2020-07-29 by budRich
EOB
}



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

___printhelp(){
  
cat << 'EOB' >&2
i3viswiz - Professional window focus for i3wm


SYNOPSIS
--------
i3viswiz [--gap|-g GAPSIZE] DIRECTION       [--json JSON]
i3viswiz [--focus|-f] --title|-t       [TARGET] [--json JSON]
i3viswiz [--focus|-f] --instance|-i    [TARGET] [--json JSON]
i3viswiz [--focus|-f] --class|-c       [TARGET] [--json JSON]
i3viswiz [--focus|-f] --titleformat|-o [TARGET] [--json JSON]
i3viswiz [--focus|-f] --winid|-d       [TARGET] [--json JSON]
i3viswiz [--focus|-f] --parent|-p      [TARGET] [--json JSON]
i3viswiz --help|-h
i3viswiz --version|-v

OPTIONS
-------

--gap|-g GAPSIZE  
Set GAPSIZE (defaults to 5). GAPSIZE is the
distance in pixels from the current window where
new focus will be searched.  


--focus|-f  
When used in conjunction with: --titleformat,
--title, --class, --instance, --winid or --parent.
The CON_ID of TARGET window will get focused if it
is visible.


--title|-t [TARGET]  
If TARGET matches the TITLE of a visible window,
that windows  CON_ID will get printed to stdout.
If no TARGET is specified, a list of all tiled
windows will get printed with  TITLE as the last
field of each row.


--json JSON  

--instance|-i [TARGET]  
If TARGET matches the INSTANCE of a visible
window, that windows  CON_ID will get printed to
stdout. If no TARGET is specified, a list of all
tiled windows will get printed with  INSTANCE as
the last field of each row.


--class|-c [TARGET]  
If TARGET matches the CLASS of a visible window,
that windows  CON_ID will get printed to stdout.
If no TARGET is specified, a list of all tiled
windows will get printed with  CLASS as the last
field of each row.


--titleformat|-o [TARGET]  
If TARGET matches the TITLE_FORMAT of a visible
window, that windows  CON_ID will get printed to
stdout. If no TARGET is specified, a list of all
tiled windows will get printed with  TITLE_FORMAT
as the last field of each row.


--winid|-d [TARGET]  
If TARGET matches the WIN_ID of a visible window,
that windows  CON_ID will get printed to stdout.
If no TARGET is specified, a list of all tiled
windows will get printed with  WIN_ID as the last
field of each row.



--parent|-p [TARGET]  
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


awklib() {
cat << 'EOB'
# BEGIN{focs=0 end=0 csid="first" actfloat=""}
END{

  wall="none"

  switch (dir) {

    case "r":
      trgx=ac[act]["x"]+ac[act]["w"]+gapsz
      trgy=(gapsz+ac[act]["y"])+ac[act]["h"]/2

      if(trgx>(wsw+wsx)){
        trgx=gapsz
        wall="right"
      }
    break

    case "l":
      trgx=ac[act]["x"]-gapsz
      trgy=(gapsz+ac[act]["y"])+ac[act]["h"]/2
      if(trgx<wsx){
        trgx=waw-gapsz
        wall="left"
      }
    break

    case "u":
      trgx=(gapsz+ac[act]["x"])+ac[act]["w"]/2
      trgy=ac[act]["y"]-gapsz
      if(trgy<wsy){
        trgy=ac[awsid]["h"]-gapsz
        wall="up"
      }
    break

    case "d":
      trgx=(gapsz+ac[act]["x"])+ac[act]["w"]/2
      trgy=ac[act]["y"]+ac[act]["h"]+gapsz
      
      if(trgy>(wsh+wsy)){
        trgy=gapsz
        wall="down"
      }
    break
    
  }

  trgx=int(trgx)
  trgy=int(trgy)

  # listvis() creates the visiblecontainers array
  listvis(awsid)

  if (actfloat=="") {
    for (w in visiblecontainers) {
      hit=0
      hity=0
      hitx=0
      xar=ac[w]["x"]+ac[w]["w"]
      if(trgx>=ac[w]["x"])
        if(xar>=trgx){++hitx;++hit}
      if(trgy>=ac[w]["y"] && trgy<=(ac[w]["y"]+ac[w]["h"]))
        {hity++;hit++}

      if (hit==2){
        tpar=ac[w]["par"]
        tcon=w
        break
      }

      
    }
  } 
  else
    tpar="floating"

  if (dir !~ /^[lrudX]$/) {
    for (w in visiblecontainers) {
      if ((opret=="title" && ac[w]["ttl"] ~ dir) || 
        (opret=="class" && ac[w]["cls"] ~ dir) || 
        (opret=="parent" && ac[w]["par"] ~ dir) || 
        (opret=="instance" && ac[w]["ins"] ~ dir) || 
        (opret=="titleformat" && ac[w]["tf"] ~ dir) || 
        (opret=="winid" && ac[w]["wid"] ~ dir))
        {print w; exit}
    }
    exit
  }

  print \
    "trgcon=" tcon, "trgx=" trgx, "trgy=" trgy, \
    "wall=" wall, "trgpar=" tpar, \
    "sx=" ac[awsid]["x"], \
    "sy=" ac[awsid]["y"], \
    "sw=" ac[awsid]["w"], \
    "sh=" ac[awsid]["h"] 
  for (w in visiblecontainers) {
    if(w==act)
      printf "* "
    else
      printf "- "

    printf w " "
    if (opret=="title"){tmpop="| " ac[w]["ttl"]}
    else if (opret=="class"){tmpop="| " ac[w]["cls"]}
    else if (opret=="parent"){tmpop="| " ac[w]["par"]}
    else if (opret=="instance"){tmpop="| " ac[w]["ins"]}
    else if (opret=="titleformat"){tmpop="| " ac[w]["tf"]}
    else if (opret=="winid"){tmpop="| " ac[w]["wid"]}
    else {tmpop=""}

    split("xywh",s,"")
    for (c in s)
      printf sprintf("%2s %-6s", s[c]":", ac[w][s[c]])
    gsub("[\"]","",tmpop)
    print tmpop 
  }
}
function listvis(id,stackh,trg,layout) {

  # searches container with con_id=id recursevely 
  # for visible containers, add them to the global
  # array: visiblecontainers

  layout=ac[id]["layout"]

  if ("children" in ac[id]) {

    if (layout ~ /tabbed|stacked/) {
      trg=ac[id]["focused"]
      if (layout == "stacked") {
        stackh=length(ac[id]["children"])
        ac[trg]["h"]+=(ac[trg]["b"]*stackh)
        ac[trg]["y"]-=(ac[trg]["b"]*stackh)
      }
      listvis(trg)
    } else if (layout ~ /^split/) {
      for (trg in ac[id]["children"]) {
        listvis(trg)
      }
    }
  } else if (ac[id]["f"]!=1) {
    visiblecontainers[id]=id
  }
}

# opret="$type" gapsz="${__o[gap]}" dir="$target"

BEGIN{focs=0;end=0;csid="first";actfloat=""}

$1 ~ /"nodes"/ && ac[cid]["counter"] == "go"  && $2 != "[]" {
  ac[cid]["counter"]=csid
  csid=cid
}
 # types: con,floating_con,dockarea,root,output
$1 ~ /"type"/ {getrect=($2 ~ /con|workspace/?1:0)}

$(NF-1) ~ /"id"/        {cid=$NF}
$1      ~ /"layout"/    {clo=gensub(/"/,"","g",$2)}

$1      ~ /"rect"/ && getrect {
  gotarray=0
  while (!gotarray) {
    match($0,/"([^"]+)":([0-9]+)([}])?$/,ma)
    key=substr(ma[1],1,1)
    ac[cid][key]=ma[2]
    gotarray=(ma[3] == "}" ? 1 : 0)
    getline
  }
}

$1 ~ /"deco_rect"/ && getrect {
  getline # "x":0
  getline # "y":0
  getline # "width":0
          # "height":0}
  titlebarheight=gensub(/([0-9]+)/,"\\1",1,$2)
  ac[cid]["b"]=titlebarheight
  ac[cid]["h"]+=ac[cid]["b"]
  ac[cid]["y"]-=ac[cid]["b"]
}

$1 ~ /"num"/ {
  cws=$2    # current workspace number
  cwsid=cid # current workspace id
}

/^"focused":true$/ {
  act=cid      # active containre id
  aws=cws      # active workspace number
  awsid=cwsid  # active workspace id
}

$1=="\"window\"" && $2=="null" {
  ac[cid]["layout"]=clo
  ac[cid]["counter"]="go"
  ac[cid]["focused"]="X"
}

$1      ~ /"title_format"/ {ac[cid]["tf"]=$2}
$1      ~ /"title"/ {ac[cid]["ttl"]=$2}
$1      ~ /"window"/ {ac[cid]["wid"]=$2}
$(NF-1) ~ /"class"/ {ac[cid]["cls"]=$NF}

# curpar current parent container (i34A|B|C|D)
$1 ~ /"marks"/ && match($2,/"i34(.)"/,ma) {curpar=ma[1]}
$1 ~ /"instance"/ {
  ac[cid]["ins"]=$2
  ac[cid]["par"]=curpar
}

/^"floating":.+_on"$/ {
  if(cid==act){actfloat="floating"}
  ac[cid]["f"]=1
}

/"focus"/ && $2 != "[]" {
  gotarray=0
  while (!gotarray) {

    child=gensub(/[][]/,"","g",$NF)

    if(ac[csid]["focused"]=="X") {
      ac[csid]["focused"]=child
    }

    ac[csid]["children"][child]=1
    gotarray=($NF ~ /[]]$/ ? 1 : 0)
    ac[csid]["childs"] = child " " ac[csid]["childs"]

    getline
  }

  csid=ac[csid]["counter"]
}
EOB
}

ERM(){ >&2 echo "$*"; }
ERR(){ >&2 echo "[WARNING]" "$*"; }
ERX(){ >&2 echo "[ERROR]" "$*" && exit 1 ; }

listvisible(){
  awk -f <(awklib) \
  FS=: RS=, opret="$1" gapsz="$2" dir="$3" \
  <(echo "$4")
}


declare -A __o
options="$(
  getopt --name "[ERROR]:i3viswiz" \
    --options "g:fticodphv" \
    --longoptions "gap:,focus,title,json:,instance,class,titleformat,winid,parent,help,version," \
    -- "$@" || exit 98
)"

eval set -- "$options"
unset options

while true; do
  case "$1" in
    --gap        | -g ) __o[gap]="${2:-}" ; shift ;;
    --focus      | -f ) __o[focus]=1 ;; 
    --title      | -t ) __o[title]=1 ;; 
    --json       ) __o[json]="${2:-}" ; shift ;;
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


main "${@}"


