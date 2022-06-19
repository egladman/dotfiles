#!/usr/bin/env bash

set -e

# Super basic semi-agnostic package install wrapper to bootstrap a system. Must
# be ran twice to install BOTH user and system packages

# Usage: (install)
#  sudo ./bootstrap.sh --system
#  ./bootstrap.sh

# Usage: (update)
#  sudo ./bootstrap.sh --update --system
#  ./bootstrap.sh --update

DEBUG="${DEBUG:-0}"

OPT_PACKAGELIST_DIR="pkgs"
OPT_SYSTEM_PACKAGES=0
OPT_UPDATE_PACKAGES=0

__run() {
    if [[ ! -f "${OPT_PACKAGELIST_DIR}/${PACKAGELIST:?}" ]]; then
        printf '%s\n' "File '${PACKAGELIST}' does not exist."
        exit 1
    fi

    while read -r line || [[ -n "$line" ]]; do
        # Skip empty lines
        [[ -z "$line" ]] && continue

        [[ $DEBUG -eq 1 ]] && printf '> line: %s\n' "$line"

        declare -a arr=($line) # Split by space
        printf '> package: %s\n' "${arr[-1]}"
        "$@" "${arr[@]}"
        if [[ $? -ne 0 ]]; then
            printf '%s\n' "Command '${@::1}' returned non-zero code. Failed to install '${line}'."
            exit 1
        fi
    done < "${OPT_PACKAGELIST_DIR}/${PACKAGELIST}"
}

__install() {
    case "$1" in
        1) # Global packages
            PACKAGELIST=dnf.packages __run dnf install --assumeyes
            PACKAGELIST=flatpak.packages __run flatpak install --system --assumeyes --noninteractive
            ;;
        0) # Local packages
            PACKAGELIST=cargo.packages __run cargo install --bins
            PACKAGELIST=go.packages __run go install
            ;;
    esac

    printf '%s\n' "Install successful"
}

__update() {
    case "$1" in
        1) # Global packages
            PACKAGELIST=dnf.packages __run dnf update --assumeyes
            PACKAGELIST=flatpak.packages __run flatpak update --system --assumeyes --noninteractive
            ;;
        0) # Local packages
            PACKAGELIST=cargo.packages __run cargo install --bins
            PACKAGELIST=go.packages __run go install
            ;;
    esac

    printf '%s\n' "Update successful"
}

main() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -S|--system)
                OPT_SYSTEM_PACKAGES=1
                ;;
            -U|--update)
                OPT_UPDATE_PACKAGES=1
                ;;
            *)
                printf '%s\n' "Invalid option '$1'"
                exit 128
                ;;
        esac
        shift
    done

    if [[ $OPT_UPDATE_PACKAGES -eq 1 ]]; then
        __update $OPT_SYSTEM_PACKAGES
        return
    fi

    __install $OPT_SYSTEM_PACKAGES
}

main "$@"
