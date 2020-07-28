END{

  listvis(awsid)
  wall="none"

  wsh=int(dim[aws]["h"])
  wsw=int(dim[aws]["w"])
  wsx=int(dim[aws]["x"])
  wsy=int(dim[aws]["y"])

  if (dir=="r"){
    trgx=ac[act]["x"]+ac[act]["w"]+gapsz
    trgy=(gapsz+ac[act]["y"])+ac[act]["h"]/2

    if(trgx>(wsw+wsx)){
      trgx=gapsz
      wall="right"
    }
  }

  if (dir=="l"){
    trgx=ac[act]["x"]-gapsz
    trgy=(gapsz+ac[act]["y"])+ac[act]["h"]/2
    if(trgx<wsx){
      trgx=dim[aws]["w"]-gapsz
      wall="left"
    }
  }

  if (dir=="u"){
    trgx=(gapsz+ac[act]["x"])+ac[act]["w"]/2
    trgy=ac[act]["y"]-gapsz
    if(trgy<wsy){
      trgy=dim[aws]["h"]-gapsz
      wall="up"
    }
  }

  if (dir=="d"){
    trgx=(gapsz+ac[act]["x"])+ac[act]["w"]/2
    trgy=ac[act]["y"]+ac[act]["h"]+gapsz
    
    if(trgy>(wsh+wsy)){
      trgy=gapsz
      wall="down"
    }
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
    "sx=" dim[aws]["x"], \
    "sy=" dim[aws]["y"], \
    "sw=" dim[aws]["w"], \
    "sh=" dim[aws]["h"] 
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
