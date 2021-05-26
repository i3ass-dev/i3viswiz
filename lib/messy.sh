#!/bin/bash

messy() {
  # arguments are valid i3-msg arguments
  # execute all commands at once in cleanup()
  (( __o[verbose] )) && ERM "m $*"
  (( __o[dryrun]  )) || _msgstring+="$*;"
}
