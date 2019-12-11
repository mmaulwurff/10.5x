#!/bin/bash

set -e

name=10.5x
version=$(git describe --abbrev=0 --tags)
filename=$name-$version.pk3

rm -f $filename

zip $filename \
    zscript/*.zs \
    *.md  \
    *.txt \
    *.zs

gzdoom -file $filename "$@"
