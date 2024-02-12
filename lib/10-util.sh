#!/usr/bin/env bash

util::yes() {
    # Usage: __yes
    #        __yes foo bar
    # Pure Bash implementation of GNU Coreutils yes in one-line
    while :; do
	printf '%s\n' "${*:-y}"
    done
}

util::split() {
    # Usage: split "string" "delimiter"
    IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
    printf '%s\n' "${arr[@]}"
}

util::is_dryrun() {
    if [[ -n "$DRYRUN" ]] && [[ $DRYRUN -eq 1 ]]; then
	return 0
    fi
    
    return 1
}

util::is_privileged() {
    case "$EUID" in
	"")
	    log::warn "Failed lookup if the current user is privileged. Proceeding, but the operation might fail."
	    ;;
	"0")
	    log::debug "The current user is privileged."
	    ;;
	*)
	    return 1
	    ;;
	esac

    return 0
}
