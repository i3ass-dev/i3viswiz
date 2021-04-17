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
      if ($1 ~ /"nodes"/) {
        current_parent_id=cid
      }
      cid=$NF
      container_order[++container_count]=cid
    break

    case "x":

      if ($1 ~ /"rect"/) {
        for (gotarray=0; !gotarray; getline) {
          match($0,/"([^"])[^"]*":([0-9]+)([}])?$/,ma)
          ac[cid][ma[1]]=ma[2]
          gotarray=(ma[3] == "}" ? 1 : 0)
        }
      }

      else if ($1 ~ /"deco_rect"/) {
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
        if (arg_type != "direction")
          getorder=1   # check order when making children
      }

      ac[cid]["parent"]=current_parent_id
    break

    case "window":
      if ($NF != "null") {
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

        first_id=gensub(/[^0-9]/,"","g",$2)
        parent_id=ac[first_id]["parent"]
        ac[parent_id]["focused"]=first_id
        
        for (gotarray=0; !gotarray; getline) {

          child=gensub(/[][]/,"","g",$NF)
          ac[parent_id]["children"][child]=1
          gotarray=($NF ~ /[]]$/ ? 1 : 0)

        }

        if (getorder) {

          groupsize=length(ac[parent_id]["children"])
          for (i=1;i<groupsize+1;i++) {
            indx=(container_count-groupsize)+i
            curry=container_order[indx]

            if (i==1)
              print_us["firstingroup"]=curry
            if (curry == act)
              print_us["grouppos"]=i
          }
          
          print_us["lastingroup"]=curry
          print_us["grouplayout"]=ac[parent_id]["layout"]
          print_us["groupid"]=parent_id
          getorder=0
        }

        current_parent_id=ac[parent_id]["parent"]
      }
    break
  }
}
