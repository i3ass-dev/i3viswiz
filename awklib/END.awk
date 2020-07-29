END{

  wall="none"

  split("x y w h",geo," ")
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
    for (s in geo) { printf("%2s %-6s", geo[s]":", ac[w][geo[s]]) }

    print (opret ~ /title|class|parent|instance|titleformat|winid/ ?
          "| " gensub(/"/,"","g",ac[w][opret]) : "") 
  }

  # example output:
  # * 94548870755248 x: 0     y: 0     w: 1432  h: 220   | A
  # - 94548870641312 x: 0     y: 220   w: 1432  h: 860   | C
}

