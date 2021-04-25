---
description: >
  Professional window focus for i3wm
updated:       2020-08-12
version:       0.468
author:        budRich
repo:          https://github.com/budlabs/i3ass
created:       2018-01-18
dependencies:  [bash, gawk, i3]
see-also:      [bash(1), awk(1), i3(1)]
synopsis: |
    [--gap|-g GAPSIZE] DIRECTION  [--json JSON] [--debug VARLIST] [--debug-format FORMAT] [--verbose]
    --title|-t       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON] [--debug VARLIST] [--debug-format FORMAT] [--verbose] 
    --instance|-i    [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON] [--debug VARLIST] [--debug-format FORMAT] [--verbose]
    --class|-c       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON] [--debug VARLIST] [--debug-format FORMAT] [--verbose]
    --titleformat|-o [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON] [--debug VARLIST] [--debug-format FORMAT] [--verbose]
    --winid|-d       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON] [--debug VARLIST] [--debug-format FORMAT] [--verbose]
    --parent|-p      [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON] [--debug VARLIST] [--debug-format FORMAT] [--verbose]
    --help|-h
    --version|-v
...

# long_description

`i3viswiz` either prints a list of the currently visible tiled windows to `stdout` or shifts the focus depending on the arguments.  

If a *DIRECTION* (left|right|up|down) is passed, `i3wizvis` will shift the focus to the window closest in the given *DIRECTION*, or warp focus if there are no windows in the given direction.  

# examples

replace the normal i3 focus keybindings with viswiz like this:  
``` text
Normal binding:
bindsym Mod4+Shift+Left   focus left

Wizzy binding:
bindsym Mod4+Left   exec --no-startup-id i3viswiz left
```

example output:  
``` text
$ i3viswiz --class --gap 20 down
trgcon=94125805431344 trgx=1329 trgy=828 wall=none trgpar=C sx=0 sy=0 sw=1920 sh=1080 groupsize=3 grouppos=3 firstingroup=94125805065424 lastingroup=94125805553936 grouplayout="tabbed" groupid=94125805519264 gap=5
* 94851560291216 x: 0     y: 0     w: 1165  h: 450   | URxvt
- 94851559487504 x: 0     y: 451   w: 1165  h: 448   | sublime
- 94851560318768 x: 1166  y: 0     w: 433   h: 899   | bin
```

If `--class , --instance, --title, --titleformat, --winid or --parent` is used together with a DIRECTION. i3viswiz will print this output, with the type in the last column of the table (class in the example above). The first line contains a lot of useful pseudo variables that is used by other scripts in **i3ass** 
`eval "$(i3viswiz -p d)" ; echo "$groupsize"`
