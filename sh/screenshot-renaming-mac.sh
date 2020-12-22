#!/bin/bash
for file in ~/in/Screenshot*.png; do
  if [ -e "$file" ]; then
    newname=`echo "$file" | sed -E 's/Screenshot (....-..-..) at (..)\.(..)\.(..)\.png/\1--\2-\3-\4§screenshot.png/'`
    mv "$file" "$newname"
  fi
done
