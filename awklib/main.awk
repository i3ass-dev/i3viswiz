$(NF-1) ~ /"(type|output|id|window|name|num|x|floating|marks|layout|focused|instance|class|focus|title_format)"$/ {
  
  key=gensub(/.*"([^"]+)"$/,"\\1","g",$(NF-1))
    
  switch (key) {

    case "layout":
    case "title_format":
    case "class":
    case "instance":
    case "output":
    case "type":
      ac[cid][key]=$NF
    break

    case "name":
      ac[cid][key]=$NF

      # store output container id in separate array
      if ( ac[cid]["type"] ~ /"output"/ &&
           $NF !~ /__i3/)
        outputs[$NF]=cid

    break

    case "id":
      # when "nodes": (or "floating_nodes":) and "id":
      # is on the same record.
      #   example -> "nodes":[{"id":94446734049888 
      # it is the start of a branch in the tree.
      # save the last container_id as current_parent_id
      if ($1 ~ /nodes"$/) {
        current_parent_id=cid
      } else if (NR == 1) {
        root_id=$NF
      }

      # cid, "current id" is the last seen container_id
      cid=$NF
      container_order[++container_count]=cid
    break

    case "x":

      if ($1 ~ /"rect"/) {
        # this will add values to ac[cid]["x"], ac[cid]["y"] ...
        while (1) {
          match($0,/"([^"])[^"]*":([0-9]+)([}])?$/,ma)
          ac[cid][ma[1]]=ma[2]
          if (ma[3] == "}")
            break
          # break before getline, otherwise we will
          # miss the "deco_rect" line..
          getline
        }
      }

      else if ($1 ~ /"deco_rect"/) {
        getline # "x":0
        getline # "y":0
        getline # "width":0
                # "height":0}
        ac[cid]["titlebarheight"]=gensub(/[}]/,"","g",$2)
      } 
      
    break

    case "num":
      ac[cid][key]=$NF
      cwsid=cid # current workspace id
      copid=outputs[ac[cid]["output"]] # current output id
    break

    case "focused":
      if ($NF == "true") {
        active_container_id=cid
        active_workspace_id=cwsid
        active_output_id=copid
        getorder=1
      }
      ac[cid]["parent"]=current_parent_id
    break

    case "window":
      if ($NF != "null") {
        ac[cid]["winid"]=$NF
        ac[cid]["i3fyracontainer"]=current_i3fyra_container
      }
    break

    case "marks":
      if (match($2,/"i34(A|B|C|D)"/,ma)) {
        current_i3fyra_container=ma[1]
      }

      # marks set by i3var all are at the root_id.
      # all that are related to i3viswiz has i3viswiz prefix
      
      # "marks":["i34MAC=157"
      # "i34FBD=X"
      # "hidden93845635698816="]
      else if (cid == root_id) {
        while (1) {
          match($0,/"(i3viswiz)?([^"=]+)=([^"]*)"([]])?$/,ma)

          if (ma[1] == "i3viswiz")
            last_direction_id=ma[3]
          if (ma[4] ~ "]")
            break

          getline
        }
      }
    break

    case "floating":
      if ($NF ~ /_on"$/) {
        ac[cid]["floating"]=1
      }
    break

    case "focus":
      if ($2 != "[]") {
        # a not empty focus list is the first thing
        # we encounter after a branch. The first
        # item of the list is the focused container
        # which is of interest if the container is
        # tabbed or stacked, where only the focused container
        # is visible.
        first_id=gensub(/[^0-9]/,"","g",$2)
        parent_id=ac[first_id]["parent"]
        ac[parent_id]["focused"]=first_id

        # this restores current_parent_id to what
        # it was before branching.
        current_parent_id=ac[parent_id]["parent"]
        
        # workspaces are childs in a special containers
        # named "content", so the focused (first_id) container
        # is a visible workspace (excluding the scratchpad)
        if (ac[parent_id]["name"] ~ /"content"/ &&
            ac[first_id]["name"] !~ /"__i3_scratch"/) {
          visible_workspaces[first_id]=1

          # store the workspace number for current output
          ac[copid]["num"]=ac[first_id]["num"]
        }

        # this just store a list of child container IDs
        # (same as the focus list).
        for (gotarray=0; !gotarray; getline) {
          child=gensub(/[][]/,"","g",$NF)
          ac[parent_id]["children"][child]=1
          gotarray=($NF ~ /[]]$/ ? 1 : 0)
        }

        # if the active container is one of the children
        # get the order and size of the containers.
        if (getorder) {

          groupsize=length(ac[parent_id]["children"])
          for (i=1;i<groupsize+1;i++) {
            indx=(container_count-groupsize)+i
            curry=container_order[indx]

            if (i==1)
              print_us["firstingroup"]=curry
            if (curry == active_container_id)
              print_us["grouppos"]=i
          }
          
          print_us["lastingroup"]=curry
          print_us["grouplayout"]=ac[parent_id]["layout"]
          print_us["groupid"]=parent_id
          print_us["groupsize"]=groupsize
          getorder=0
        }
      }
    break
  }
}
