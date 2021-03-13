#!/usr/bin/env bash

self_version=0.1.0
log_level=0
stow_opts=(
    '-v'
)

read -r -d '' self_usage <<-EOF
Wrapper for GNU Stow to simplify dotfile management
Usage: ${0##*/} [option]

OPTIONS
   -h, --help                     show this help text, and exit
   -V, --version                  show version, and exit
   -R, --restow                   Restow dotfiles (first unstow, then stow again). This is
                                  useful for pruning obsolete symlinks
   -D, --delete                   Unstow dotfiles
EOF

case "$1" in
    '')
	      printf '%s\n' "Stowing..."
	      ;;
    -R|--restow)
	      printf '%s\n' "Restowing..."
	      stow_opts=("${stow_opts[@]}" '-R')
	      ;;
    -D|--delete)
	      printf '%s\n' "Deleting..."
	      stow_opts=("${stow_opts[@]}" '-D')
	      ;;
    -V|--version)
	      printf '%s\n' "$self_version"
	      exit 0
	      ;;
    -h|--help)
	      printf '%s\n' "$self_usage"
	      exit 0
	      ;;
    *)
	      printf '%s\n' "Unsupported option"
	      exit 1
	      ;;
esac

declare -a submodules
declare -a packages

shopt -s globstar # Enable
for path in **; do
    [[ ! -d "$path" ]] && continue

    # Check for git submodules
    if [[ -f "${path}"/.git ]]; then
        submodules=("${submodules[@]}" "$path")
        packages=("${packages[@]}" "${path}"/**/*)
    # Exclude submodule child paths
    elif [[ ! " ${submodules[@]} " =~ " ${path%/*} " ]]; then
        packages=("${packages[@]}" "$path")
    fi
done
shopt -u globstar # Disable

if [[ $log_level -gt 0 ]]; then
    printf '%s\n' "Found packages:"
    printf '  %s\n' ${packages[@]}
fi

for path in "${packages[@]}"; do
    [[ $log_level -gt 0 ]] && printf '%s\n' "Traversing path '${path%/*}'"

    if [[ "$path" == *\/* ]]; then
        [[ $log_level -gt 0 ]] && printf '%s\n' "Entering directory '${path%/*}'"
        pushd "${path%/*}" &> /dev/null
        stow ${stow_opts[@]} -t "${HOME:?}" "${path#*/}"
        return_code=$?
        popd &> /dev/null
        [[ $log_level -gt 0 ]] && printf '%s\n' "Exiting directory '${path%/*}'"
    else
        stow ${stow_opts[@]} "$path"
        return_code=$?
    fi

    if [[ $return_code -ne 0 ]]; then
        printf '%s\n' "Command 'stow' returned non-zero code"
        exit 1
    fi
    unset return_code
done
