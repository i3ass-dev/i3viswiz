END{

  wall="none"

  # listvis() creates the visiblecontainers array
  listvis(awsid)

  # shorthand variables 
  # active workspace (ws) 
  wsx=int(ac[awsid]["x"]); wsy=int(ac[awsid]["y"])
  wsw=int(ac[awsid]["w"]); wsh=int(ac[awsid]["h"])
  # active window (aw)
  awx=int(ac[act]["x"]);   awy=int(ac[act]["y"])
  aww=int(ac[act]["w"]);   awh=int(ac[act]["h"])

  if (dir ~ /^(l|r|u|d|X)$/) {
    
    trgx=int((dir == "r" ? awx+aww+gapsz :
              dir == "l" ? awx-gapsz     :
              awx+(aww/2)+gapsz ))

    trgy=int((dir == "d" ? awy+awh+gapsz :
              dir == "u" ? awy-gapsz     :
              awy+(awh/2)+gapsz ))

    switch (dir) {

      case "r":
        if(trgx>(wsw+wsx)){
          trgx=gapsz
          wall="right"
        }
      break

      case "l":
        if(trgx<wsx){
          trgx=wsw-gapsz
          wall="left"
        }
      break

      case "u":
        if(trgy<wsy){
          trgy=ac[awsid]["h"]-gapsz
          wall="up"
        }
      break

      case "d":
        if(trgy>(wsh+wsy)){
          trgy=gapsz
          wall="down"
        }
      break
    }

    if (actfloat=="") {

      for (conid in visiblecontainers) {

        cwx=ac[conid]["x"] ; cww=ac[conid]["w"]
        cwy=ac[conid]["y"] ; cwh=ac[conid]["h"]
        cex=cwx+cww    ; cey=cwy+cwh

        if (cwx <= trgx && trgx <= cex && cwy <= trgy && trgy <= cey) {
          tpar=ac[conid]["parent"]
          tcon=conid
          break
        }  
      }
    } 
    else
      tpar="floating"
  }

  else if (opret ~ /title|class|parent|instance|titleformat|winid/) {

    for (conid in visiblecontainers) {
      if (ac[conid][opret] ~ dir) {print conid ;exit}
    }
    exit
  }

  else
    exit

  head1="trgcon=%d trgx=%d trgy=%d wall=%s trgpar=%s "
  head1=head1 "sx=%d sy=%d sw=%d sh=%d groupsize=%s "
  head1=head1 "grouppos=%d firstingroup=%d lastingroup=%d "
  head1=head1 "grouplayout=%s groupid=%d gap=%d"

  printf(head1"\n",tcon,trgx,trgy,wall,tpar,
                   wsx,wsy,wsw,wsh,
                   groupsize, grouppos, firstingroup,
                   lastingroup, grouplayout, groupid, gapsz)

  split("x y w h",geo," ")
  for (conid in visiblecontainers) {

    printf("%s %d ", (conid==act ? "*" : "-" ), conid)
    for (s in geo) { printf("%2s %-6s", geo[s] ":", ac[conid][geo[s]]) }

    print (opret ~ /title|class|parent|instance|titleformat|winid/ ?
          "| " gensub(/"/,"","g",ac[conid][opret]) : "") 
  }

  # example output:
  # * 94548870755248 x: 0     y: 0     w: 1432  h: 220   | A
  # - 94548870641312 x: 0     y: 220   w: 1432  h: 860   | C
}

