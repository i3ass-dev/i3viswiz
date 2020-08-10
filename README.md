# i3viswiz - Professional window focus for i3wm 

### usage

```text
i3viswiz [--gap|-g GAPSIZE] DIRECTION  [--json JSON]
i3viswiz --title|-t       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --instance|-i    [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --class|-c       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --titleformat|-o [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --winid|-d       [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --parent|-p      [--gap|-g GAPSIZE] [DIRECTION|TARGET] [--focus|-f] [--json JSON]
i3viswiz --help|-h
i3viswiz --version|-v
```

`i3viswiz` either prints a list of the currently visible
tiled windows to `stdout` or shifts the focus depending on
the arguments.  

If a *DIRECTION* (left|right|up|down) is passed, `i3wizvis`
will shift the focus to the window closest in the given
*DIRECTION*, or warp focus if there are no windows in the
given direction.  


OPTIONS
-------

`--gap`|`-g` TARGET  
Set GAPSIZE (defaults to 5). GAPSIZE is the distance in
pixels from the current window where new focus will be
searched.  

`--json` JSON  
use JSON instead of output from  `i3-msg -t get_tree`

`--title`|`-t`  
If **TARGET** matches the **TITLE** of a visible window,
that windows  **CON_ID** will get printed to `stdout`. If no
**TARGET** is specified, a list of all tiled windows will
get printed with  **TITLE** as the last field of each row.

`--focus`|`-f`  
When used in conjunction with: `--titleformat`, `--title`,
`--class`, `--instance`, `--winid` or `--parent`. The
**CON_ID** of **TARGET** window will get focused if it is
visible.

`--instance`|`-i`  
If **TARGET** matches the **INSTANCE** of a visible window,
that windows  **CON_ID** will get printed to `stdout`. If no
**TARGET** is specified, a list of all tiled windows will
get printed with  **INSTANCE** as the last field of each
row.

`--class`|`-c`  
If **TARGET** matches the **CLASS** of a visible window,
that windows  **CON_ID** will get printed to `stdout`. If no
**TARGET** is specified, a list of all tiled windows will
get printed with  **CLASS** as the last field of each row.

`--titleformat`|`-o`  
If **TARGET** matches the **TITLE_FORMAT** of a visible
window, that windows  **CON_ID** will get printed to
`stdout`. If no **TARGET** is specified, a list of all tiled
windows will get printed with  **TITLE_FORMAT** as the last
field of each row.

`--winid`|`-d`  
If **TARGET** matches the **WIN_ID** of a visible window,
that windows  **CON_ID** will get printed to `stdout`. If no
**TARGET** is specified, a list of all tiled windows will
get printed with  **WIN_ID** as the last field of each row.


`--parent`|`-p`  
If **TARGET** matches the **PARENT** of a visible window,
that windows  **CON_ID** will get printed to `stdout`. If no
**TARGET** is specified, a list of all tiled windows will
get printed with  **PARENT** as the last field of each row.

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.

EXAMPLES
--------
replace the normal i3 focus keybindings with viswiz like
this:  
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


If `--class , --instance, --title, --titleformat, --winid or --parent` is used together with a DIRECTION. i3viswiz will print this output, with the type in the last column of the table (class in the example above). The first line contains a lot of useful pseudo variables that is used by other scripts in **i3ass**  `eval "$(i3viswiz -p d)" ; echo "$groupsize"`



