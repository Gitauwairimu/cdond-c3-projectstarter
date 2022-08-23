#!/bin/bash
file="prometheusinventory.txt"
if [ -f "$file" ] ; then
    rm "$file"
fi