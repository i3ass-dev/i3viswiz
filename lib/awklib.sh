#!/usr/bin/env bash

awklib() {
cat << 'EOB'
# BEGIN{focs=0 end=0 csid="first" actfloat=""}
END{

  listvis(awsid)
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

  if(actfloat==""){
    for (w in avis) {
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
    for (w in avis) {
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
  for (w in avis) {
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
    avis[id]=id
  }
}
#!/bin/awk

# opret="$type" gapsz="${__o[gap]}" dir="$target"

BEGIN{focs=0;end=0;csid="first";actfloat=""}

$1 ~ /"nodes"/ && ac[cid]["counter"] == "go"  && $2 != "[]" {
  ac[cid]["counter"]=csid
  csid=cid
}
 # types: con,floating_con,dockarea,root,output
$1 ~ /"type"/ {

  if ($2 ~ /con|workspace/) 
    {getrect=1}
  else 
    {getrect=0}

}

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
