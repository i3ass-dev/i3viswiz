
ac[cid]["counter"]=="go" && $1=="\"nodes\"" && $2!="[]"{
  ac[cid]["counter"]=csid
  csid=cid
}

$1~"{\"id\"" || $2~"\"id\"" {cid=$NF}

$1=="\"layout\""{clo=$2}

$1=="\"type\"" && $2=="\"workspace\"" {wsdchk="1"}
wsdchk=="1" && $1=="\"width\""  {dim["w"]=$2}
wsdchk=="1" && $1=="\"height\"" {gsub("}","",$2);dim["h"]=$2;wsdchk="2"}

wsdchk=="1" && $(NF-1) ~ /"x"/ {dim["x"]=$NF}
wsdchk=="1" && $(NF-1) ~ /"y"/ {dim["y"]=$NF}

wsdchk=="2" && $1=="\"num\"" {
  dim[$2]["w"]=dim["w"]
  dim[$2]["h"]=dim["h"]
  dim[$2]["x"]=dim["x"]
  dim[$2]["y"]=dim["y"]
  wsdchk="0"
}

$1=="\"num\"" {cws=$2;cwsid=cid}

$1=="\"focused\"" && $2=="true" {
  act=cid
  aws=cws
  awsid=cwsid
}

$1=="\"window\"" && $2=="null" {
  gsub("[\"]","",clo)
  ac[cid]["layout"]=clo
  ac[cid]["counter"]="go"
  ac[cid]["focused"]="X"
}


$1~"title_format" {ac[cid]["tf"]=$2}
$1~"title" {ac[cid]["ttl"]=$2}
$1=="\"window\"" {ac[cid]["wid"]=$2}
# $1~"id" {ac[cid][]=$2}
$1~"instance" {ac[cid]["ins"]=$2;ac[cid]["par"]=curpar}
$1~"class" || $2~"class" {ac[cid]["cls"]=$NF}

$1=="\"marks\"" {
  gsub("[[]|[]]|\"","",$2);
  if ($2 ~ /^i34.$/){
    sub("i34","",$2)
    curpar=$2
  }
}


$1=="\"window\"" && $2!="null" {
  ac[cid]["x"]=curx
  ac[cid]["y"]=cury
  ac[cid]["w"]=curw
  ac[cid]["h"]=curh
  ac[cid]["b"]=curb
}

$1=="\"rect\"" {curx=$3;rectw=1}
rectw==1 && $1=="\"y\""{cury=$2}
rectw==1 && $1=="\"width\""{curw=$2-1}
rectw==1 && $1=="\"height\""{sub("}","",$2);curh=$2-1;rectw=2}

$1=="\"deco_rect\"" {rectb=1}
rectb==1 && $1=="\"height\""{
  sub("}","",$2)
  curh+=$2;cury-=$2
  curb=$2
  rectb=2
}

$1=="\"floating\"" && $2~"_on" {
  if(cid==act){actfloat="floating"}
  ac[cid]["f"]=1
}

$1=="\"focus\"" && $2!="[]" {focs=1}
focs=="1" && $NF~"[]]$"{end=1}
focs=="1" {
  gsub("[]]|[[]","",$NF)
  if(ac[csid]["focused"]=="X"){ac[csid]["focused"]=$NF}

  ac[csid]["childs"]=$NF" "ac[csid]["childs"]
}

end=="1" {
  csid=ac[csid]["counter"]
  focs=0;end=0
}
