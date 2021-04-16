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

  awb=int(ac[act]["b"])

  if (arg_target ~ /^(l|r|u|d|X)$/) {
    
    trgx=int((arg_target == "r" ? awx+aww+arg_gap :
              arg_target == "l" ? awx-arg_gap     :
              awx+(aww/2)+arg_gap ))

    # add awb (active window titlebar height) to gapsize
    trgy=int((arg_target == "d" ? awy+awh+(arg_gap+awb) :
              arg_target == "u" ? awy-(arg_gap+awb)     :
              awy+(awh/2)+(arg_gap+awb) ))

    switch (arg_target) {

      case "r":
        if(trgx>(wsw+wsx)){
          trgx=arg_gap
          wall="right"
        }
      break

      case "l":
        if(trgx<wsx){
          trgx=wsw-arg_gap
          wall="left"
        }
      break

      case "u":
        if(trgy<wsy){
          trgy=ac[awsid]["h"]-arg_gap
          wall="up"
        }
      break

      case "d":
        if(trgy>(wsh+wsy)){
          trgy=arg_gap
          wall="down"
        }
      break
    }

    if (!ac[act]["floating"]) {

      for (conid in visiblecontainers) {

        cwx=ac[conid]["x"] ; cww=ac[conid]["w"]
        cwy=ac[conid]["y"] ; cwh=ac[conid]["h"]

        cex=cwx+cww    ; cey=cwy+cwh

        if (cwx <= trgx && trgx <= cex && cwy <= trgy && trgy <= cey) {
          tpar=ac[conid]["i3fyracontainer"]
          tcon=conid
          break
        }  
      }
    } 
    else
      tpar="floating"
  }

  else if (arg_type ~ /title|class|i3fyracontainer|instance|title_format|winid/) {

    for (conid in visiblecontainers) {
      if (ac[conid][arg_type] ~ arg_target) {print conid ;exit}
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
                   lastingroup, grouplayout, groupid, arg_gap)



  split("x y w h",geo," ")
  for (conid in visiblecontainers) {

    printf("%s %d ", (conid==act ? "*" : "-" ), conid)
    for (s in geo) { printf("%2s %-6s", geo[s] ":", ac[conid][geo[s]]) }

    print (arg_type ~ /(title_format|class|i3fyracontainer|instance|title|winid)$/ ?
          "| " gensub(/"/,"","g",ac[conid][arg_type]) : "") 
  }

  # example output:
  # * 94548870755248 x: 0     y: 0     w: 1432  h: 220   | A
  # - 94548870641312 x: 0     y: 220   w: 1432  h: 860   | C
}

