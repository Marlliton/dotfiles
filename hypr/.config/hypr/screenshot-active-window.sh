#!/usr/bin/env sh

output="$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .name' | head -n1)"

[ -n "$output" ] || exit 1
[ "$output" != "null" ] || exit 1

grim -o "$output" - | swappy -f -
