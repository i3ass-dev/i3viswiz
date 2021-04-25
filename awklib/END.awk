END{

  for (wsid in visible_workspaces)
    listvis(wsid)

  # commandline example:
  #   i3viswiz down  (arg_target=d arg_type=direction)
  #   i3viswiz -i d  (arg_target=d arg_type=instance)
  if (arg_target ~ /^(l|r|u|d)$/) {

    if (ac[active_container_id]["floating"] == 1) {
      target_container="floating"
      print_us["trgcon"]=active_container_id
      print_us["trgpar"]="floating"
    } else {


      target_container=find_window(arg_target)

      # if we cannot find a window in the given direction
      # try again with increased gapsize.
      if (target_container == "") {
        arg_gap=arg_gap+30
        target_container=find_window(arg_target)
      }

      print_us["trgcon"]=target_container
      print_us["trgpar"]=ac[target_container]["i3fyracontainer"]
    }

    if (arg_type == "direction") {
      print target_container, active_container_id, root_id, last_direction_id
      exit
    }
  }

  # commandline example:
  #   i3viswiz -i firefox (arg_target=firefox arg_type=instance)
  else if (arg_target !~ /^(l|r|u|d|X)$/) {
    for (conid in visible_containers) {
      if (ac[conid][arg_type] ~ arg_target) {
        print conid
        exit
      }
    }
    exit
  }

  # commandline example:
  #   i3viswiz -i firefox   (arg_target=X arg_type=instance)
  #   i3viswiz -i firefox d (arg_target=d arg_type=instance)

  print_us["gap"]=arg_gap

  if (arg_debug == "ALL") {
    for (k in print_us) {
      v=gensub(/%k/,k,1,arg_debug_format)
      debug_out=debug_out gensub(/%v/,print_us[k],1,v)
    }

    print debug_out
    arg_debug="LIST"
  }

  else if (arg_debug != "LIST") {
    split(arg_debug,debug_vars,",")
    for (k in debug_vars) {
      if (debug_vars[k] in print_us) {
        v=gensub(/%k/,debug_vars[k],1,arg_debug_format)
        var=gensub(/^"|"$/,"","g",print_us[debug_vars[k]])
        debug_out=debug_out gensub(/%v/,var,1,v)
      }
    }

    print debug_out
  }

  if (arg_debug !~ /LIST/)
    exit
  

  split("x y w h",geo," ")
  for (conid in visible_containers) {
    
    printf("%s %d ", (conid==active_container_id ? "*" : "-" ), conid)
    cop=outputs[ac[conid]["output"]] # output of current container          
    printf("ws: %d ", ws=ac[cop]["num"]) # workspace on current output
    for (s in geo) { printf("%2s %-6s", geo[s] ":", ac[conid][geo[s]]) }

    print (arg_type ~ /(title_format|class|i3fyracontainer|instance|name|winid)$/ ?
          "| " gensub(/"/,"","g",ac[conid][arg_type]) : "") 
  }

  # example output:
  # * 94548870755248 x: 0     y: 0     w: 1432  h: 220   | A
  # - 94548870641312 x: 0     y: 220   w: 1432  h: 860   | C
}

