function listvis(id,achld,curc,c,schld,curs,s,stackh) {
  stackh=0

  if(ac[id]["layout"]=="stacked"){
    split(ac[id]["childs"],schld," ")
    for (s in schld) {
      curs=schld[s]
      gsub("[^0-9]","",curs)
      if(curs==""){continue}
      stackh++
    }
    stackh--
  }

  if(ac[id]["layout"]~/tabbed|stacked/){
    ac[id]["childs"]=ac[id]["focused"]}

  split(ac[id]["childs"],achld," ")
  for (c in achld) {
    curc=achld[c]
    gsub("[^0-9]","",curc)
    if(curc==""){continue}
    if(ac[id]["layout"]=="stacked"){
      ac[curc]["h"]=ac[curc]["h"]+(ac[curc]["b"]*stackh)
      ac[curc]["y"]=ac[curc]["y"]-(ac[curc]["b"]*stackh)
    }
    if (ac[curc]["childs"]!="")
      listvis(curc)
    else if (ac[curc]["f"]!=1)
      avis[curc]=curc
  }
}
