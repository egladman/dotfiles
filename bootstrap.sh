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

OPT_PACKAGELIST_BASE_DIR="pkgs"
OPT_PACKAGELIST_SYSTEM_DIR="${OPT_PACKAGELIST_BASE_DIR}/system"
OPT_PACKAGELIST_USER_DIR="${OPT_PACKAGELIST_BASE_DIR}/user"

OPT_GUIX_URL_PREFIX="https://git.savannah.gnu.org/cgit/guix.git/plain/etc/"

OPT_SYSTEM_PACKAGES=0
OPT_UPDATE_PACKAGES=0
OPT_INIT_GUIX=0

# The variable naming convention is super important
# PKGCMD_<action>_<packagemanager>

# Golang
PKGCMD_INSTALL_GO=(go install)
PKGCMD_UPDATE_GO=(go install)

# Rust
PKGCMD_INSTALL_CARGO=(cargo install --bins)
PKGCMD_UPDATE_CARGO=(cargo install --bins)

# Dnf
PKGCMD_INSTALL_DNF=(dnf install --assumeyes)
PKGCMD_UPDATE_DNF=(dnf update --assumeyes)

# Flatpak
PKGCMD_INSTALL_FLATPAK=(flatpak install --system --assumeyes --noninteractive)
PKGCMD_UPDATE_FLATPAK=(flatpak update --system --assumeyes --noninteractive)

# Guix
PKGCMD_INSTALL_GUIX=(guix package --install)
PKGCMD_UPDATE_GUIX=(guix package --upgrade)

__install_guix() {
    # TODO add selinux support
    # For the time being disable SELinux. See /etc/selinux/config
    # https://guix.gnu.org/manual/en/html_node/SELinux-Support.html
    selinuxenabled && printf '%s\n' "SELinux is not supported." && exit 3

    if [[ -d /gnu/store ]]; then
        printf '%s\n' "Guix is already installed. Directory '/gnu/store' exists. Skipping..."
        return
    fi

    # TODO verify gpg sig

    tmp_file="$(mktemp)"
    curl --proto '=https' --output "$tmp_file" --tlsv1.2 -sSf "${OPT_GUIX_URL_PREFIX}guix-install.sh"
    chmod +x "$tmp_file"
    yes | "$tmp_file"
}

__lookup_basecmd() {
    # Usage: __lookup_basecmd <install|update> <packagemanager>
    #        __lookup_basecmd install dnf

    var_name=$(printf '%s' PKGCMD_${1^^}_${2^^})
    eval "printf '%s\n' \${$var_name[@]}"
}

__split() {
    # Usage: split "string" "delimiter"
    IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
    printf '%s\n' "${arr[@]}"
}

__run() {
    if [[ ! -f "$PACKAGELIST" ]]; then
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
    done < "${PACKAGELIST:?}"
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
            -G|--guix)
                OPT_INIT_GUIX=1
                ;;
            *)
                printf '%s\n' "Invalid option '$1'"
                exit 128
                ;;
        esac
        shift
    done

    # Install Guix
    if [[ $OPT_INIT_GUIX -eq 1 ]]; then
        __install_guix && guix pull
        exit 0
    fi

    local pkg_action=install
    [[ $OPT_UPDATE_PACKAGES -eq 1 ]] && pkg_action=update

    local pkg_type=user
    [[ $OPT_SYSTEM_PACKAGES -eq 1 ]] && pkg_type=system

    printf '> action: %s\n' "${pkg_action}"

    for f in "${OPT_PACKAGELIST_BASE_DIR}/${pkg_type}"/*; do
        declare -a arr
        arr=($(__split "${f##*/}" "."))
        # [-1] packages
        # [-2] <packagemanager>

        printf '> manager: %s\n' "${arr[-2]}"

        cmd=($(__lookup_basecmd "$pkg_action" "${arr[-2]}"))
        PACKAGELIST="$f" __run "${cmd[@]}"
    done

    printf '%s\n' "${pkg_action} successful"
}

main "$@"
