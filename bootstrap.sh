#!/usr/bin/env bash

set -e

# Installs/Updates user defined packages system wide

# Usage:
#  sudo ./bootstrap.sh install
#  sudo ./bootstrap.sh update

__run() {
    if [[ ! -f "${PACKAGELIST:?}" ]]; then
        printf '%s\n' "File '${PACKAGELIST}' does not exist."
        exit 1
    fi

    while read -r line; do
        [[ -z "$line" ]] && continue
        declare -a arr=($line) # Split by space
        printf '%s\n' "> ${arr[-1]}"
        "$@" "${arr[@]}"
        if [[ $? -ne 0 ]]; then
            printf '%s\n' "Command '${@::1}' returned non-zero code. Failed to install '${line}'."
            exit 1
        fi
    done < "$PACKAGELIST"
}

__install_all() {
    PACKAGELIST=dnf-packages.list __run dnf install --assumeyes
    PACKAGELIST=flatpak-packages.list __run flatpak install --system --assumeyes --noninteractive
}

__update_all() {
    PACKAGELIST=dnf-packages.list __run dnf update --assumeyes
    PACKAGELIST=flatpak-packages.list __run flatpak update --system --assumeyes --noninteractive
}

main() {
    case "$1" in
        ""|install)
            __install_all
            ;;
        update)
            __update_all
            ;;
        *)
            printf '%s\n' "Command '$1' is not recognized."
            exit 128
            ;;
    esac
}

main "$@"
