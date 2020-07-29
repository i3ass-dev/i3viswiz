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
