#!/usr/bin/env bash

set -o errexit -o pipefail

# Super basic semi-agnostic package install wrapper to bootstrap a system. Must
# be ran twice to install BOTH user and system packages

# Usage: (install)
#  sudo ./setup.sh --system
#  ./setup.sh

# Usage: (update)
#  sudo ./setup.sh --update --system
#  ./setup.sh --update

DEBUG="${DEBUG:-0}"
DRYRUN="${DRYRUN:-0}"

package::foreach() {
    filename="${1:?}"
    hook="${2:?}"

    if [[ ! -f "$filename" ]]; then
        log::fatal "File '$filename' does not exist."
    fi

    log::debug "Reading file '$filename'"
    while read -r line || [[ -n "$line" ]]; do
        # Skip empty lines
        [[ -z "$line" ]] && continue

	log::debug "Iterating over line '$line'"
        declare -a wrkarr=($line) # Split by space

	log::info "Processing package '${wrkarr[*]}'"

	util::is_dryrun && continue || true 

	"$hook" "${wrkarr[@]}" || {
	    log::debug "Function hook $hook returned non-zero code. Failed on package '${line}'."
	    log::fatal "Failed to process value '$line' in file '$filename'"
	}
    done < "$filename"
}

init() {
    for f in ./lib/*.sh; do
	source "$f"
    done
}

main() {
    declare -a skip_targets
    local package_operation=install
    local package_type=user

    while [ $# -gt 0 ]; do
        case "$1" in
            -S|--system)
                package_type=system
                ;;
            -U|--update)
                package_operation=update
                ;;
	    -D|--debug)
		DEBUG=1
		;;
	    -U|--dryrun)
		DRYRUN=1
		;;
            --skip-*)
                skip_targets+=("${1##--skip-}")
                ;;
            *)
                printf '%s\n' "Invalid option '$1'"
                exit 128
                ;;
        esac
        shift
    done

    log::info "Performing $package_operation"

    prefix_dir="./pkgs/${package_type}"
    log::debug "Traversing directory '$prefix_dir'"
    
    for f in "${prefix_dir}"/*; do
	declare -a wrkarr
	filename="${f##*/}"
        wrkarr=($(util::split "$filename" "."))
        # [-1] packages
        # [-2] <packagemanager>

	target="${wrkarr[-2]}"
	log::info "Found package list for target '$target'"

        if [[ " ${skip_targets[*]} " =~ " $target " ]]; then
	    log::debug "Skipping target '$target'"
	    continue
        fi

	printf -v hook '%s::%s' "$target" "$package_operation"
	package::foreach "$f" "$hook"
    done
}

init
main "$@"
