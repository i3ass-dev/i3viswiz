#!/bin/awk

# opret="$type" gapsz="${__o[gap]}" dir="$target"

# BEGIN{focs=0;end=0;csid="first";actfloat=""}

$(NF-1) ~ /"(nodes|deco_rect|rect|id|window|title|num|width|height|x|y|floating|marks|layout|focused|instance|class)"$/ {
  
  key=gensub(/.*"([^"]+)"$/,"\\1","g",$(NF-1))
  var=gensub(/[["]*([^]}"]+)[]}"]*$/,"\\1","g",$NF)

  switch (key) {
    case "nodes":
    break
    case "type":
    break
    case "id":
    break
    case "layout":
    break
    case "rect":
    break
    case "deco_rect":
    break
    case "num":
    break
    case "focused":
    break
    case "window":
    break
    case "title_format":
    break
    case "title":
    break
    case "class":
    break
    case "instance":
    break
    case "marks":
    break
    case "floating":
    break
    case "focus":
    break
  }
}

$1 ~ /"nodes"/ && ac[cid]["counter"] == "go"  && $2 != "[]" {
  ac[cid]["counter"]=csid
  csid=cid
}
 # types: con,floating_con,dockarea,root,output
$1 ~ /"type"/ {type=$2}

$(NF-1) ~ /"id"/        {cid=$NF}
$1      ~ /"layout"/    {clo=gensub(/"/,"","g",$2)}

$1      ~ /"rect"/ && type ~ /con|workspace/ {
  for (gotarray=0; !gotarray; getline) {
    match($0,/"([^"]+)":([0-9]+)([}])?$/,ma)
    ac[cid][ma[1]]=ma[2]
    gotarray=(ma[3] == "}" ? 1 : 0)
  }
}

$1 ~ /"deco_rect"/ && type == "con" {
  getline # "x":0
  getline # "y":0
  getline # "width":0
          # "height":0}
  titlebarheight=gensub(/([0-9]+)/,"\\1",1,$2)
  ac[cid]["b"]=titlebarheight
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

$1      ~ /"title_format"/ {ac[cid]["titleformat"]=$2}
$1      ~ /"title"/        {ac[cid]["title"]=$2}
$1      ~ /"window"/       {ac[cid]["winid"]=$2}
$(NF-1) ~ /"class"/        {ac[cid]["class"]=$NF}

# curpar current parent container (i34A|B|C|D)
$1 ~ /"marks"/ && match($2,/"i34(.)"/,ma) {curpar=ma[1]}
$1 ~ /"instance"/ {
  ac[cid]["instance"]=$2
  ac[cid]["parent"]=curpar
}

/^"floating":.+_on"$/ {
  if(cid==act){actfloat="floating"}
  ac[cid]["f"]=1
}

/"focus"/ && $2 != "[]" {
  
  for (gotarray=0; !gotarray; getline) {

    child=gensub(/[][]/,"","g",$NF)

    if(ac[csid]["focused"]=="X") {
      ac[csid]["focused"]=child
    }

    ac[csid]["children"][child]=1
    ac[csid]["childs"] = child " " ac[csid]["childs"]
    gotarray=($NF ~ /[]]$/ ? 1 : 0)

  }

  csid=ac[csid]["counter"]
}
