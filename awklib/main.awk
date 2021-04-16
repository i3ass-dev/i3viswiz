$(NF-1) ~ /"(id|window|title|num|x|floating|marks|layout|focused|instance|class|focus|title_format)"$/ {
  
  key=gensub(/.*"([^"]+)"$/,"\\1","g",$(NF-1))
  switch (key) {

    case "layout":
    case "title_format":
    case "title":
    case "class":
    case "instance":
      ac[cid][key]=$NF
    break

    case "id":
      if ($1 ~ /nodes/ && ac[cid]["counter"] == "go") {
        ac[cid]["counter"]=csid
        csid=cid
      }
      cid=$NF
      allcontainers[++concount]=cid
    break

    case "x":

      if ($1 ~ /"rect"/) {
        for (gotarray=0; !gotarray; getline) {
          match($0,/"([^"])[^"]*":([0-9]+)([}])?$/,ma)
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
        ac[cid]["counter"]="go"
      } 
      else {
        ac[cid]["winid"]=$NF
        ac[cid]["i3fyracontainer"]=current_i3fyra
      }

    break

    case "marks":
      if (match($2,/"i34(A|B|C|D)"/,ma)) {
        current_i3fyra=ma[1]
      }
    break

    case "floating":
      if ($NF ~ /_on"$/) {
        ac[cid]["floating"]=1
      }
    break

    case "focus":
      if ($2 != "[]") {
        
        for (gotarray=0; !gotarray; getline) {

          child=gensub(/[][]/,"","g",$NF)
 
          if ("focused" in ac[csid] == 0) {
            ac[csid]["focused"]=child
          }

          ac[csid]["children"][child]=1
          gotarray=($NF ~ /[]]$/ ? 1 : 0)

        }

        if (getorder) {

          groupsize=length(ac[csid]["children"])
          for (i=1;i<groupsize+1;i++) {
            indx=(concount-groupsize)+i
            curry=allcontainers[indx]

            if (i==1)
              firstingroup=curry
            if (curry == act)
              grouppos=i
          }
          
          lastingroup=curry
          grouplayout=ac[csid]["layout"]
          groupid=csid
          getorder=0
        }
        csid=ac[csid]["counter"]
      }
    break
  }
}
