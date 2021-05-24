# options-debug-description

VARLIST is used to determine what to output. By
default the value of VARLIST is: `LIST` .
Available units are:  

```text
wall         | none|(up|left|down|right-)(workspace|area)
trgcon       | container id of the window to be focused
trgpar       | name of i3fyra container target container is located in
gap          | internal gap value used
sw           | active workspace width
sh           | active workspace height
sx           | active workspace x position
sy           | active workspace y position
trgx         | target windows x position
trgy         | target windows y position
grouplayout  | active windows parent container layout (tabbed|splitv|splith|stacked)
groupid      | active windows parent container ID
grouppos     | active windows position relative to its sibling containers
groupsize    | number of child containers in active windows parent container
firstingroup | container ID of the first child in active windows parent container
lastingroup  | container ID of the last child in active windows parent container
LIST         | prints a table with all visible windows
ALL          | all the above combined
```

Multiple units can be used if comma separated.

Example:  
```text
$ i3viswiz --instance u --debug gap,wall,grouppos
gap=5 wall=up-area grouppos=1 
```

# options-debug-format-description

The default value of FORMAT is "%k=%v ".  `%k` is
translated to the key/unit name, and `%v` to the
value.  

Example:  
```text
$ i3viswiz --instance u --debug gap,wall,grouppos --debug-format "%v\n"
5
up-area
1 
```

# options-verbose-description

If set, more stuff gets printed to **STDERR**
during the execution of the script.

Example:  
```text
$ i3viswiz --instance u --debug gap --verbose 

---i3viswiz start---
gap=5 
f cleanup()
---i3viswiz done: 14ms---
```

# options-focus-description

When used in conjunction with: `--titleformat`, `--title`, `--class`, `--instance`, `--winid` or `--parent`. The **CON_ID** of **TARGET** window will get focused if it is visible.

# options-json-description
use JSON instead of output from  `i3-msg -t get_tree` 

# options-titleformat-description

If **TARGET** matches the **TITLE_FORMAT** of a visible window, that windows 
**CON_ID** will get printed to `stdout`.
If no **TARGET** is specified, a list of all tiled windows will get printed with 
**TITLE_FORMAT** as the last field of each row. 

# options-class-description

If **TARGET** matches the **CLASS** of a visible window, that windows 
**CON_ID** will get printed to `stdout`.
If no **TARGET** is specified, a list of all tiled windows will get printed with 
**CLASS** as the last field of each row.

# options-title-description

If **TARGET** matches the **TITLE** of a visible window, that windows 
**CON_ID** will get printed to `stdout`.
If no **TARGET** is specified, a list of all tiled windows will get printed with 
**TITLE** as the last field of each row.

# options-instance-description

If **TARGET** matches the **INSTANCE** of a visible window, that windows 
**CON_ID** will get printed to `stdout`.
If no **TARGET** is specified, a list of all tiled windows will get printed with 
**INSTANCE** as the last field of each row.

# options-parent-description

If **TARGET** matches the **PARENT** of a visible window, that windows 
**CON_ID** will get printed to `stdout`.
If no **TARGET** is specified, a list of all tiled windows will get printed with 
**PARENT** as the last field of each row.

# options-winid-description

If **TARGET** matches the **WIN_ID** of a visible window, that windows 
**CON_ID** will get printed to `stdout`.
If no **TARGET** is specified, a list of all tiled windows will get printed with 
**WIN_ID** as the last field of each row.


# options-gap-description

Set GAPSIZE (defaults to 5). GAPSIZE is the distance in pixels from the current window where new focus will be searched.  

# options-help-description
Show help and exit.

# options-version-description
Show version and exit.
