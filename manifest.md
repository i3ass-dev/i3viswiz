---
description: >
  Professional window focus for i3wm
updated:       2021-06-07
version:       0.51
author:        budRich
repo:          https://github.com/budlabs/i3ass
created:       2018-01-18
dependencies:  [bash, gawk, i3]
see-also:      [bash(1), awk(1), i3(1)]
synopsis: |
    [--gap|-g GAPSIZE] DIRECTION 
    --title|-t       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] 
    --instance|-i    [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f]
    --class|-c       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f]
    --titleformat|-o [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f]
    --winid|-d       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f]
    --parent|-p      [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f]
    [--json JSON] [--debug VARLIST] [--debug-format FORMAT] [--verbose]
    --help|-h
    --version|-v
...

# long_description

`i3viswiz` either prints a list of the currently
visible tiled windows to `stdout` or shifts the
focus depending on the arguments.  

If a *DIRECTION* (left|right|up|down) is passed,
`i3wizvis` will shift the focus to the window
closest in the given *DIRECTION*, or warp focus
if there are no windows in the given direction. 

# examples

replace the normal i3 focus keybindings with viswiz like this:

``` text
Normal binding:
bindsym Mod4+Shift+Left   focus left

Wizzy binding:
bindsym Mod4+Left   exec --no-startup-id i3viswiz left
```

example output:  
```text
$ i3viswiz --instance

* 94475856575600 ws: 1 x: 0     y: 0     w: 1558  h: 410   | termsmall
- 94475856763248 ws: 1 x: 1558  y: 0     w: 362   h: 272   | gl
- 94475856286352 ws: 1 x: 0     y: 410   w: 1558  h: 643   | sublime_main
- 94475856449344 ws: 1 x: 1558  y: 272   w: 362   h: 781   | thunar-lna
```

If `--class` , `--instance`, `--title`,
`--titleformat`, `--winid` or `--parent` is used
together with a DIRECTION or no argument.
i3viswiz will print this output, with the type in
the last column of the table (class in the
example above).  

If argument is present and not a
DIRECTION option will be a criteria and the
argument the search string.  

Assuming the same scenario as the example above,
the following command:  
`$ i3viswiz --instance termsmall`  
will output the container_id (`94475856575600`).  
If now window is matching output will be blank.  

**focus wrapping**  

if the setting "focus_wrapping" is set
to "workspace" in the i3config. i3viswiz will
wrap the focus only inside the currenttly
focused workspace instead of the whole work
area (other monitors).

The setting has to be present in the active config
before the first i3viswiz invokation.

To force this behavior otherwise, issue the following
command:  
`i3var set focus_wrap workspace`

Or to disable it:  
`i3var set focus_wrap normal`
