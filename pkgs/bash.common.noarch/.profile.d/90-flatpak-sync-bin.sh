# Symlinks flatpak apps to a dir defined in the user's PATH

BASHPROFILED_USER_FLATPAK_EXPORT_DIR="${BASHPROFILED_USER_FLATPAK_EXPORT_DIR:-/var/lib/flatpak/exports/bin}"
BASHPROFILED_USER_FLATPAK_BIN_DIR="${BASHPROFILED_USER_FLATPAK_BIN_DIR:-${HOME:?}/.local/bin}"
BASHPROFILED_USER_FLATPAK_BIN_PREFIX="${BASHPROFILED_USER_FLATPAK_BIN_PREFIX:-fp}"

if [[ ! -d "$BASHPROFILED_USER_FLATPAK_EXPORT_DIR" ]]; then
    exit 0
fi

for app in "$BASHPROFILED_USER_FLATPAK_EXPORT_DIR"/*; do
    app_name="${app##*.}"
    app_name="${app_name,,}" # Downcase

    link="${BASHPROFILED_USER_FLATPAK_BIN_DIR}/${app_name}"
    if [[ -e "$link" ]] && [[ "$(readlink "$link")" != "$app" ]]; then
        # If the path already exists and isn't owned by flatpak
        # then fallback to using a prefix
        link="${BASHPROFILED_USER_FLATPAK_BIN_DIR}/${BASHPROFILED_USER_FLATPAK_BIN_PREFIX}-${app_name}"
    fi

    # Only link when necessary
    if [[ -L "$link" ]]; then
        continue
    fi

    ln --symbolic "$app" "$link"
done
