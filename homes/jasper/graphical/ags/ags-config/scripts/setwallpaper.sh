#!/usr/bin/env bash

# use yad to let the user pick a wallpaper
cd "$XDG_PICTURES_DIR"
image=$(yad --width 1000 --height 600 --file --add-preview --large-preview --title='Choose a new wallpaper')

swww img "$image" \
    --transition-step 6 --transition-fps 165 --transition-type grow \
    --transition-duration 1 --transition-bezier .45,.10,.96,.67 \
    --transition-pos "$(hyprctl cursorpos -j | jq '.x'), $(hyprctl cursorpos -j | jq '.y')" --invert-y

if [[ ! -d "$FLAKE/.theme" ]]; then
    mkdir "$FLAKE/.theme"
fi
if [[ -n "$image" ]]; then
    # -f -> remove existing destination file(s)
    ln -fs "$image" "$FLAKE/.theme/current_wallpaper"
fi

sleep .2

# wal -nste -i <image>
# -nste -> don't change any colors
# -l -> light theme

wal -q -nste -l -i "$image"
cp -f "$XDG_CACHE_HOME/wal/colors.json" "$FLAKE/.theme/colors_light.json"

wal -q -nste -i "$image"
cp -f "$XDG_CACHE_HOME/wal/colors.json" "$FLAKE/.theme/colors_dark.json"

