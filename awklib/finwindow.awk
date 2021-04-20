function find_window(direction,
                     trgx,trgy,
                     aww,awh,awx,awy,
                     wsw,wsh,wsx,wsy,
                     opx,opy,opw,oph,
                     rootx,rooty,rootw,rooth,
                     opid,workspace_id,
                     found,wall)
{
  wsx=ac[active_workspace_id]["x"]; wsy=ac[active_workspace_id]["y"]
  wsw=ac[active_workspace_id]["w"]; wsh=ac[active_workspace_id]["h"]

  awx=ac[active_container_id]["x"]; awy=ac[active_container_id]["y"]
  aww=ac[active_container_id]["w"]; awh=ac[active_container_id]["h"]

  opx=ac[active_output_id]["x"]; opw=ac[active_output_id]["w"]
  opy=ac[active_output_id]["y"]; oph=ac[active_output_id]["h"]

  rootx=ac[container_order[1]]["x"]; rootw=ac[container_order[1]]["w"]
  rooty=ac[container_order[1]]["y"]; rooth=ac[container_order[1]]["h"]

  trgx=(direction == "r" ? awx+aww+arg_gap :
        direction == "l" ? awx-arg_gap     :
        awx+(aww/2)+arg_gap )

  trgy=(direction == "d" ? awy+awh+arg_gap :
        direction == "u" ? awy-arg_gap     :
        awy+(awh/2)-arg_gap )

  found=0
  wall="none"


  if ( (direction == "r" && trgx > wsx+wsw) ||
       (direction == "l" && trgx < wsx) ) {

    wall=(direction == "l" ? "left" : "right")

    if ( (direction == "r" && trgx > rootx+rootw) ||
         (direction == "l" && trgx < rootx) ) {

      trgx=(direction == "l" ? rootx+rootw-arg_gap :
                               rootx+arg_gap)

      wall=wall "-area"
    } else
      wall=wall "-workspace"

    for (workspace_id in visible_workspaces) {
      # on each workspace try a temporary target y
      # at the middle of the workspace
      tmpy=ac[workspace_id]["y"]+(ac[workspace_id]["h"]/2)-arg_gap
      # test if this temp y position exist both on
      # the current and active workspace (they are aligned)
      # and that trgx exist on current workspace (its aligned to the left)
      if (  is_container_at_pos(workspace_id, trgx, tmpy) && 
            is_container_at_pos(active_output_id, opx, tmpy)) {
        # if trgy is not on the next output
        # set it at the middle (tmpy)
        if (!is_container_at_pos(workspace_id, trgx, trgy))
          trgy=tmpy

        found=1
        break
      }
    }
  }

  else if ( (direction == "u" && trgy < wsy) ||
            (direction == "d" && trgy > wsy+wsh) ) {

    wall=(direction == "u" ? "up" : "down")

    if ( (direction == "u" && trgy < rooty) ||
         (direction == "d" && trgy > rooty+rooth) ) {

      trgy=(direction == "u" ? rooty+rooth-arg_gap :
                               rooty+arg_gap )

      wall=wall "-area"
    } else {
      wall=wall "-workspace"
      # make sure trgy is outside active output
      # and not just the workspace (top|bottombars)
      trgy=(direction == "u" ? opy-arg_gap : opy+oph+arg_gap)
    }

    for (workspace_id in visible_workspaces) {
      output_id=outputs[ac[workspace_id]["output"]]
      # on each workspace try a temporary target x
      # at the middle of the output
      tmpx=ac[output_id]["x"]+(ac[output_id]["w"]/2)+arg_gap

      # test if this temp x position also exist on active output
      # test if both the x and y position exist on current output
      if (  is_container_at_pos(output_id, tmpx, trgy) && 
            is_container_at_pos(active_output_id,tmpx, opy)) {
        # set the target y according to the workspace
        # incase the output has a bottombar
        trgy=(direction == "u" ? 
                ac[workspace_id]["y"]+ac[workspace_id]["h"]-arg_gap :
                ac[workspace_id]["y"]+arg_gap )
        
        # if trgx is not on the next workspace
        # set it at the middle (tmpy)
        if (!is_container_at_pos(workspace_id, trgx, trgy))
          trgx=tmpx

        found=1
        break
      }
    }
    
  }

  print_us["wall"]=wall
  print_us["trgx"]=trgx ; print_us["trgy"]=trgy
  print_us["sx"]=wsx ; print_us["sy"]=wsy
  print_us["sw"]=wsw ; print_us["sh"]=wsh

  for (conid in visible_containers) {
    if (is_container_at_pos(conid, trgx, trgy))
      return conid
  }

  return ""
}
