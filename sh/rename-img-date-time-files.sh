#!/bin/bash
for file in *.jpg; do
  if [ -e "$file" ]; then
    newname=`echo "$file" | sed -E 's/(IMG_)?(....)(..)(..)_(..)(..)(..)[^\.]*\.jpg/\2-\3-\4--\5-\6-\7.jpg/'`
    mv "$file" "$newname"
  fi
done
