#!/bin/awk

$1 == "\"type\"" {type=$2}
$1 == "\"nodes\"" && ac[cid]["counter"] == "go"  && $2 != "[]" {
  ac[cid]["counter"]=csid
  csid=cid
}

type ~ /con|workspace["]$/ && $(NF-1) ~ /"(id|window|title|num|x|floating|marks|layout|focused|instance|class|focus)"$/ {
  
  key=gensub(/.*"([^"]+)"$/,"\\1","g",$(NF-1))
  switch (key) {

    case "id":
      cid=$NF
      allcontainers[++concount]=cid
    break

    case "layout":
      clo=$2
    break

    case "x":

      if ($1 ~ /"rect"/) {
        for (gotarray=0; !gotarray; getline) {
          match($0,/"([^"]+)":([0-9]+)([}])?$/,ma)
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
        ac[cid]["layout"]=clo
        ac[cid]["counter"]="go"
        ac[cid]["focused"]="X"
      } 
      else
        ac[cid]["winid"]=$NF

    break

    case "title_format":
      ac[cid]["titleformat"]=$NF
    break

    case "title":
      ac[cid]["title"]=$NF
    break

    case "class":
      ac[cid]["class"]=$NF
    break

    case "instance":
      ac[cid]["instance"]=$NF
      ac[cid]["parent"]=curpar
    break

    case "marks":
      if (match($2,/"i34(.)"/,ma)) {
        curpar=ma[1]
        parents[curpar]=cid
      }
    break

    case "floating":
      if ($NF ~ /_on$/) {
        if(cid==act){actfloat="floating"}
        ac[cid]["f"]=1
      }
    break

    case "focus":
      if ($2 != "[]") {
        
        for (gotarray=0; !gotarray; getline) {

          child=gensub(/[][]/,"","g",$NF)
 
          if(ac[csid]["focused"]=="X") {
            ac[csid]["focused"]=child
          }

          ac[csid]["children"][child]=1
          # ac[csid]["childs"] = child " " ac[csid]["childs"]
          gotarray=($NF ~ /[]]$/ ? 1 : 0)

        }

        if (getorder) {

          nchilds=length(ac[csid]["children"])
          for (i=1;i<nchilds+1;i++) {
            indx=(concount-nchilds)+i
            curry=allcontainers[indx]

            if (i==1)
              firstingroup=curry
            if (curry == act)
              grouppos=i
          }
          
          lastingroup=curry
          grouplayout=ac[csid]["layout"]
          groupid=csid
          groupsize=nchilds
          getorder=0
        }
        csid=ac[csid]["counter"]
      }
    break
  }
}
