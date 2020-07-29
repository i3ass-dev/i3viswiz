#!/usr/bin/env bash

awklib() {
cat << 'EOB'
BEGIN{
  split("x y width height",geo," ")
  focs=0; end=0; csid="first"; actfloat=""
}
END{

  wall="none"

  for (s in geo) {
    c["ws" geo[s]]=int(ac[awsid][geo[s]])
    c["aw" geo[s]]=int(ac[act][geo[s]])
  }

  # listvis() creates the visiblecontainers array
  listvis(awsid)

  if (dir ~ /^l|r|u|d|X$/) {

    trgx=int((dir == "r" ? c[awx]+c[aww]+gapsz :
              dir == "l" ? c[awx]-gapsz     :
              c[awx]+(c[aww]/2)+gapsz ))

    trgy=int((dir == "d" ? c[awy]+c[awh]+gapsz :
              dir == "u" ? c[awy]-gapsz     :
              c[awy]+(c[awh]/2)+gapsz ))

    switch (dir) {

      case "r":
        if(trgx>(c[wsw]+c[wsx])){
          trgx=gapsz
          wall="right"
        }
      break

      case "l":
        if(trgx<c[wsx]){
          trgx=waw-gapsz
          wall="left"
        }
      break

      case "u":
        if(trgy<c[wsy]){
          trgy=ac[awsid]["h"]-gapsz
          wall="up"
        }
      break

      case "d":
        if(trgy>(c[wsh]+c[wsy])){
          trgy=gapsz
          wall="down"
        }
      break
    }

    if (actfloat=="") {
      for (w in visiblecontainers) {
        cwx=ac[w]["x"] ; cwy=ac[w]["y"]
        cww=ac[w]["w"] ; cwh=ac[w]["h"]
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
  firstline=firstline "sx=%d sy=%d sw=%d sh=%d"
  printf(firstline"\n",tcon,trgx,trgy,wall,tpar,c[awx],c[awy],c[aww],c[awh])

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

  layout=ac[id]["layout"]

  if ("children" in ac[id]) {

    if (layout ~ /tabbed|stacked/) {
      trg=ac[id]["focused"]
      if (layout == "stacked") {
        stackh=length(ac[id]["children"])
        ac[trg]["h"]+=(ac[trg]["b"]*stackh)
        ac[trg]["y"]-=(ac[trg]["b"]*stackh)
      } else {
        ac[trg]["h"]+=ac[trg]["b"]
        ac[trg]["y"]-=ac[trg]["b"]
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
EOB
}
