#!/bin/bash

#IWAD=~/Programs/Games/wads/doom/freedoom1.wad
#IWAD=~/Programs/Games/wads/doom/HERETIC.WAD
#IWAD=~/Programs/Games/wads/modules/game/harm1.wad

name=10.5x
version=$(git describe --abbrev=0 --tags)
filename=$name-$version.pk3

rm -f $filename \
&& \
zip $filename \
    zscript/*.zs   \
    *.md  \
    *.txt \
    *.zs  \
&& \
gzdoom -iwad $IWAD \
       -file $filename \
       ~/Programs/Games/wads/maps/test/DOOMTEST.wad \
       "$1" "$2" \
       +map test \
