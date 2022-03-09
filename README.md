# mizCleaner

**mizCleaner is a DCS World mission cleaner and optimizer.**

Every time that you delete a unit, static, etc. in the editor, the internal
dictionary (a key/value in lua) don't remove this entry, also sometimes will
create a new one with new data and this duplicate entry can cause odd problems.
This also can happen when you modify triggers, create lua scripts.

The result is a huge mess that can slow the loading times and also raise the
lua cpu usage if the script need to look some structures.

To remedy this, for now, mizCleaner will remove duplicates and old entries in
the mission dictionary using the current mission file to gather the
definitions. Later it run optipng to optimize the .png files reducing their
disk usage and load times.

*It requires lazarus to compile it and optipng in the execution path to run it*


## .miz format internals

The DCS miz files are ZIP archives.
This is a example of a minimal .miz file:

    [/]
     + [l10n]         -> you can create i18n creating a new lang folder
     |  + [DEFAULT]
     |  | dictionary  -> lua key/value with all scripts and units names
     |  | mapResource -> file names of the attached external resources
     |
     | mission        -> the main mission file, it references the others
     | warehouses     -> this file handles the DCS logistics
     | options        -> the mission options like F10 map, etc.
     | theatre        -> this file stores the mission map name

The mission file usually will have references to the other files:

* ResKey_Action_XXXX      -> a resource file reference (mapResource)
* DictKey_WptName_XXXX    -> a waypoint name (dictionary)
* DictKey_GroupName_XXXX  -> the group name (dictionary)
* DictKey_UnitName_XXXX   -> a unit name (dictionary)
* DictKey_ActionText_XXXX -> embed text, for example a script (dictionary)
* DictKey_sortie_X        -> the sortie value entry (dictionary)
* DictKey_descriptionNeutralsTask_4 ->   Neutral task description (dictionary)
* DictKey_descriptionBlueTask_3     -> Blue team task description (dictionary)
* DictKey_descriptionRedTask_2      -> Red  team task description (dictionary)