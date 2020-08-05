function listvis(id,stackh,trg,layout) {

  # searches container with con_id=id recursevely 
  # for visible containers, add them to the global
  # array: visiblecontainers

  layout=gensub(/"/,"","g",ac[id]["layout"])

  if ("children" in ac[id]) {
    if (layout ~ /tabbed|stacked/) {
      trg=ac[id]["focused"]
      if (layout == "stacked") {
        stackh=length(ac[id]["children"])
        ac[trg]["h"]+=(ac[trg]["b"]*stackh)
        ac[trg]["y"]-=(ac[trg]["b"]*stackh)
      }
      listvis(trg)
    } else if (layout ~ /^split/) {
      for (trg in ac[id]["children"]) {
        listvis(trg)
      }
    }
  } else if (ac[id]["f"]!=1) {
    ac[id]["h"]+=ac[id]["b"]
    ac[id]["y"]-=ac[id]["b"]
    visiblecontainers[id]=id
  }
}
