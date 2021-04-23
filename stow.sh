#!/usr/bin/env bash

_version=0.1.1
_usage=''
_log_level=${STOWSH_LOG_LEVEL:-40}

# Level          Numeric
# verbose        5
# debug          10
# info           20
# error          40

stow_opts=(
    # '--adopt'
)

if [[ $_log_level -le 10 ]]; then
    stow_opts+=('-v')
fi

read -r -d '' _usage <<-EOF
Wrapper for GNU Stow to simplify dotfile management
Usage: ${0##*/} [option]

OPTIONS
   -h, --help                     Show this help text, and exit
   -V, --version                  Show version, and exit
   -S, --stow                     Stow dotfiles (this is the default action and can be omitted)
   -R, --restow                   Restow dotfiles (first unstow, then stow again). This is
                                  useful for pruning obsolete symlinks
   -D, --delete                   Unstow dotfiles
   -u, --dry-run                  Do not perform any operations that modify the filesystem; merely
                                  show what would happen.
EOF

action_count=0
while [[ $# -gt 0 ]]; do
    case "$1" in
	''|-S|--stow)
	    [[ $_log_level -le 20 ]] && printf '%s\n' "Stowing..."
	    action_count=$((action_count+1))
	    ;;
	-R|--restow)
	    [[ $_log_level -le 20 ]] && printf '%s\n' "Restowing..."
	    stow_opts+=('-R')
	    action_count=$((action_count+1))
	    ;;
	-D|--delete)
	    [[ $_log_level -le 20 ]] && printf '%s\n' "Deleting..."
	    stow_opts+=('-D')
	    action_count=$((action_count+1))
	    ;;
	-V|--version)
	    printf '%s\n' "$_version"
	    exit 0
	    ;;
	-h|--help)
	    printf '%s\n' "$_usage"
	    exit 0
	    ;;
	-u|--dry-run)
	    [[ $_log_level -le 20 ]] && printf '%s\n' "Performing dry run..."
	    stow_opts+=('--no')
	    ;;
	*)
	    [[ $_log_level -le 40 ]] && printf '%s\n' "Unsupported option"
	    exit 1
	    ;;
    esac
    shift
done

if [[ $action_count -gt 1 ]]; then
    [[ $_log_level -le 40 ]] && printf '%s\n' "Conflicting options present"
    exit 1
fi

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

if [[ $_log_level -le 20 ]]; then
    printf '%s\n' "Found packages:"
    printf '  %s\n' ${packages[@]}
fi

for path in "${packages[@]}"; do
    [[ $_log_level -le 20 ]] && printf '%s\n' "Traversing path '${path%/*}'"

    if [[ "$path" == *\/* ]]; then
        [[ $_log_level -le 5 ]] && printf '%s\n' "Entering directory '${path%/*}'"
        pushd "${path%/*}" &> /dev/null
        stow "${stow_opts[@]}" -t "${HOME:?}" "${path#*/}"
        return_code=$?
        popd &> /dev/null
        [[ $_log_level -le 5 ]] && printf '%s\n' "Exiting directory '${path%/*}'"
    else
        stow ${stow_opts[@]} "$path"
        return_code=$?
    fi

    if [[ $return_code -ne 0 ]]; then
        [[ $_log_level -le 40 ]] && printf '%s\n' "Command 'stow' returned non-zero code"
        exit 1
    fi
    unset return_code
done
