#!/usr/bin/env bash

# Symlinks flatpak apps to a dir inside the user's PATH
if [[ ! -d "/var/lib/flatpak/exports/bin" ]]; then
    exit 0
fi

DESTDIR="${DESTDIR:-${HOME:?}/.local/bin}"
LINKPREFIX="${LINKPREFIX:-fp}" # Only used in case of a name collision

for app in "/var/lib/flatpak/exports/bin"/*; do
    app_name="${app##*.}"
    app_name="${app_name,,}" # Downcase

    link="${DESTDIR}/${app_name}"
    if [[ -e "$link" ]] && [[ "$(readlink "$link")" != "$app" ]]; then
        # If the path already exists and isn't owned by flatpak
        # then fallback to using a prefix
        link="${DESTDIR}/${LINKPREFIX}-${app_name}"
    fi

    # Only link when necessary
    if [[ -L "$link" ]]; then
        continue
    fi

    ln --symbolic "$app" "$link"
done
