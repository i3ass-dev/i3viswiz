function listvis(id,stackh,trg,layout) {

  # searches container with con_id=id recursevely 
  # for visible containers, add them to the global
  # array: visiblecontainers

  if ("children" in ac[id]) {
    if (ac[id]["layout"] ~ /tabbed|stacked/) {
      trg=ac[id]["focused"]
      if (ac[id]["layout"] ~ /stacked/) {
        stackh=length(ac[id]["children"])
        ac[trg]["h"]+=(ac[trg]["b"]*stackh)
        ac[trg]["y"]-=(ac[trg]["b"]*stackh)
      }
      listvis(trg)
    } else if (ac[id]["layout"] ~ /split/) {
      for (trg in ac[id]["children"]) {
        listvis(trg)
      }
    }
  } else if (!ac[id]["floating"]) {
    ac[id]["h"]+=ac[id]["b"]
    ac[id]["y"]-=ac[id]["b"]
    visiblecontainers[id]=id
  }
}
