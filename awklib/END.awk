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
