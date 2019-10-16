#!/bin/bash

# Bundle support scripts to main script

cd "${0%/*}"

script='../create-dmg'
script_brew='../create-dmg-brew'
applescript='template.applescript'
licensescript='dmg-license.py'

asl=$(awk "/BREW_INLINE_APPLESCRIPT_PLACEHOLDER/{ print NR; exit }" "$script")
sed -n 1,$(( asl - 1 ))p "$script" | sed -e 's/BREW_INSTALL=0/BREW_INSTALL=1/g' > "$script_brew"
cat "$applescript" >> "$script_brew"
lsl=$(awk "/BREW_INLINE_LICENSE_PLACEHOLDER/{ print NR; exit }" "$script")
sed -n $(( asl + 1 )),$(( lsl - 1 ))p "$script" >> "$script_brew"
cat "$licensescript" | sed '1d' >> "$script_brew"
sed -n $(( lsl + 1 )),\$p "$script" >> "$script_brew"

mv "$script_brew" "$script"
chmod +x "$script"
