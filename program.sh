#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
i3viswiz - version: 0.425
updated: 2020-07-30 by budRich
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

      ERM "$result"
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
i3viswiz [--gap|-g GAPSIZE] DIRECTION  [--json JSON]
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

--gap|-g DIRECTION  
Set GAPSIZE (defaults to 5). GAPSIZE is the
distance in pixels from the current window where
new focus will be searched.  


--json JSON  

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
BEGIN{
  split("x y width height",geo," ")
  focs=0; end=0; csid="first"; actfloat=""
}
END{

  wall="none"

  # listvis() creates the visiblecontainers array
  listvis(awsid)

  for (s in geo) {
    c["ws" geo[s]]=int(ac[awsid][geo[s]])
    c["aw" geo[s]]=int(ac[act][geo[s]])
  }

  if (dir ~ /^l|r|u|d|X$/) {

    trgx=int((dir == "r" ? c["awx"]+c["awwidth"]+gapsz :
              dir == "l" ? c["awx"]-gapsz     :
              c["awx"]+(c["awwidth"]/2)+gapsz ))

    trgy=int((dir == "d" ? c["awy"]+c["awheight"]+gapsz :
              dir == "u" ? c["awy"]-gapsz     :
              c["awy"]+(c["awheight"]/2)+gapsz ))

    switch (dir) {

      case "r":
        if(trgx>(c["wswidth"]+c["wsx"])){
          trgx=gapsz
          wall="right"
        }
      break

      case "l":
        if(trgx<c["wsx"]){
          trgx=waw-gapsz
          wall="left"
        }
      break

      case "u":
        if(trgy<c["wsy"]){
          trgy=ac[awsid]["height"]-gapsz
          wall="up"
        }
      break

      case "d":
        if(trgy>(c["wsheight"]+c["wsy"])){
          trgy=gapsz
          wall="down"
        }
      break
    }

    if (actfloat=="") {

      for (w in visiblecontainers) {

        cwx=ac[w]["x"] ; cww=ac[w]["width"]
        cwy=ac[w]["y"] ; cwh=ac[w]["height"]
        cex=cwx+cww    ; cey=cwy+cwh

        if (cwx <= trgx && trgx <= cex && cwy <= trgy && trgy <= cey) {
          tpar=ac[w]["parent"]
          tcon=w
          break
        }  
      }
    } 
    else
      tpar="floating"
  }

  else if (opret ~ /title|class|parent|instance|titleformat|winid/) {
    for (w in visiblecontainers) {
      if (ac[w][opret] ~ dir) {print w ;exit}
    }
  }

  else
    exit

  firstline="trgcon=%d trgx=%d trgy=%d wall=%s trgpar=%s "
  firstline=firstline "sx=%d sy=%d sw=%d sh=%d groupsize=%s "
  firstline=firstline "grouppos=%d firstingroup=%d lastingroup=%d "
  firstline=firstline "grouplayout=%s groupid=%d gap=%d"
  printf(firstline"\n",tcon,trgx,trgy,wall,tpar,
                      c[awx],c[awy],c[aww],c[awh],
                      groupsize, grouppos, firstingroup,
                      lastingroup, grouplayout, groupid, gapsz)

  for (w in visiblecontainers) {

    printf("%s %d ", (w==act ? "*" : "-" ), w)
    for (s in geo) { printf("%2s %-6s", substr(geo[s],1,1)":", ac[w][geo[s]]) }

    print (opret ~ /title|class|parent|instance|titleformat|winid/ ?
          "| " gensub(/"/,"","g",ac[w][opret]) : "") 
  }

  # example output:
  # * 94548870755248 x: 0     y: 0     w: 1432  h: 220   | A
  # - 94548870641312 x: 0     y: 220   w: 1432  h: 860   | C
}

function listvis(id,stackh,trg,layout) {

  # searches container with con_id=id recursevely 
  # for visible containers, add them to the global
  # array: visiblecontainers

  layout=gensub(/"/,"","g",ac[id]["layout"])

  if ("children" in ac[id]) {
    if (layout ~ /tabbed|stacked/) {
      trg=ac[id]["focused"]
      if (layout == "stacked") {
        stackh=length(ac[id]["children"])
        ac[trg]["height"]+=(ac[trg]["b"]*stackh)
        ac[trg]["y"]-=(ac[trg]["b"]*stackh)
      }
      listvis(trg)
    } else if (layout ~ /^split/) {
      for (trg in ac[id]["children"]) {
        listvis(trg)
      }
    }
  } else if (ac[id]["f"]!=1) {
    ac[id]["height"]+=ac[id]["b"]
    ac[id]["y"]-=ac[id]["b"]
    visiblecontainers[id]=id
  }
}

$1 == "\"type\"" {type=$2}
$1 == "\"nodes\"" && ac[cid]["counter"] == "go"  && $2 != "[]" {
  ac[cid]["counter"]=csid
  csid=cid
}

type ~ /con|workspace["]$/ && $(NF-1) ~ /"(id|window|title|num|x|floating|marks|layout|focused|instance|class|focus)"$/ {
  
  key=gensub(/.*"([^"]+)"$/,"\\1","g",$(NF-1))
  switch (key) {

    case "id":
      cid=$NF
      allcontainers[++concount]=cid
    break

    case "layout":
      clo=$2
    break

    case "x":

      if ($1 ~ /"rect"/) {
        for (gotarray=0; !gotarray; getline) {
          match($0,/"([^"]+)":([0-9]+)([}])?$/,ma)
          ac[cid][ma[1]]=ma[2]
          gotarray=(ma[3] == "}" ? 1 : 0)
        }
      }

      if ($1 ~ /"deco_rect"/) {
        getline # "x":0
        getline # "y":0
        getline # "width":0
                # "height":0}
        titlebarheight=gensub(/[^0-9]/,"","g",$2)
        ac[cid]["b"]=titlebarheight
      } 
      
    break

    case "num":
      cws=$2    # current workspace number
      cwsid=cid # current workspace id
    break

    case "focused":
      if ($NF == "true") {
        act=cid      # active containre id
        aws=cws      # active workspace number
        awsid=cwsid  # active workspace id
        getorder=1   # check order when making children
      }
    break

    case "window":
      if ($NF == "null") {
        ac[cid]["layout"]=clo
        ac[cid]["counter"]="go"
        ac[cid]["focused"]="X"
      } 
      else
        ac[cid]["winid"]=$NF

    break

    case "title_format":
      ac[cid]["titleformat"]=$NF
    break

    case "title":
      ac[cid]["title"]=$NF
    break

    case "class":
      ac[cid]["class"]=$NF
    break

    case "instance":
      ac[cid]["instance"]=$NF
      ac[cid]["parent"]=curpar
    break

    case "marks":
      if (match($2,/"i34(.)"/,ma)) {
        curpar=ma[1]
        parents[curpar]=cid
      }
    break

    case "floating":
      if ($NF ~ /_on$/) {
        if(cid==act){actfloat="floating"}
        ac[cid]["f"]=1
      }
    break

    case "focus":
      if ($2 != "[]") {
        
        for (gotarray=0; !gotarray; getline) {

          child=gensub(/[][]/,"","g",$NF)
 
          if(ac[csid]["focused"]=="X") {
            ac[csid]["focused"]=child
          }

          ac[csid]["children"][child]=1
          # ac[csid]["childs"] = child " " ac[csid]["childs"]
          gotarray=($NF ~ /[]]$/ ? 1 : 0)

        }

        if (getorder) {

          nchilds=length(ac[csid]["children"])
          for (i=1;i<nchilds+1;i++) {
            indx=(concount-nchilds)+i
            curry=allcontainers[indx]

            if (i==1)
              firstingroup=curry
            if (curry == act)
              grouppos=i
          }
          
          lastingroup=curry
          grouplayout=ac[csid]["layout"]
          groupid=csid
          groupsize=nchilds
          getorder=0
        }
        csid=ac[csid]["counter"]
      }
    break
  }
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
    --longoptions "gap:,json:,focus,title,instance,class,titleformat,winid,parent,help,version," \
    -- "$@" || exit 98
)"

eval set -- "$options"
unset options

while true; do
  case "$1" in
    --gap        | -g ) __o[gap]="${2:-}" ; shift ;;
    --json       ) __o[json]="${2:-}" ; shift ;;
    --focus      | -f ) __o[focus]=1 ;; 
    --title      | -t ) __o[title]=1 ;; 
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


