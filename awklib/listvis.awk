function listvis(id,stackh,trg,layout) {

  layout=ac[id]["layout"]
  # print id " --  " ac[id]["layout"]

  if (layout ~ /tabbed|stacked/) {
    trg=ac[id]["focused"]
    if (layout == "stacked") {
      # print trg
      stackh=length(ac[id]["children"])
      ac[trg]["h"]+=(ac[trg]["b"]*stackh)
      ac[trg]["y"]-=(ac[trg]["b"]*stackh)
    }
    listvis(trg)
  } else if (layout ~ /splitv|plith/) {
    for (trg in ac[id]["children"]) {
    # l=length(ac[trg]["children"])
      if ("children" in ac[trg]) {
        print layout " " length(ac[trg]["children"])
        listvis(trg)
      }
      else if (ac[trg]["f"]!=1) {
        avis[trg]=trg
      }
    }
  }

  # split(ac[id]["childs"],achld," ")

  # for (curc in ac[id]["children"]) {
  #   # curc=achld[c]
  #   # gsub("[^0-9]","",curc)

  #   # if(curc==""){continue}

  #   if(ac[id]["layout"]=="stacked"){
  #     ac[curc]["h"]+=(ac[curc]["b"]*stackh)
  #     ac[curc]["y"]-=(ac[curc]["b"]*stackh)
  #   }

  #   if (ac[curc]["childs"]!="")
  #     listvis(curc)
  #   else if (ac[curc]["f"]!=1)
  #     avis[curc]=curc
  # }
}
