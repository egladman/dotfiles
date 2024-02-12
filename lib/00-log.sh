#T!/usr/bin/env bash

log::println() {
    # Usage: log::_println "prefix" "string"
    local prefix
    if [[ $DEBUG -eq 1 ]]; then
	printf -v now '%(%m-%d-%Y %H:%M:%S)T' -1
	prefix="[${1:: 4}] ${now} ${0##*/}: "
    fi

    printf '%b\n' "${prefix}${2:?}"
}

log::info() {
    # Usage: log::info "string"
    log::println "INFO" "${1:?}"
}

log::debug() {
    # Usage: log::debug "string"
    if [[ -z "$DEBUG" ]] || [[ $DEBUG -eq 0 ]]; then
	return 0
    fi
    log::println "DEBUG" "${1:?}"
}

log::warn() {
    # Usage: log::warn "string"
    log::println "WARN" "${1:?}"
}

log::error() {
    # Usage: log::error "string"
    log::println "ERROR" "${1:?}" >&2
}

log::fatal_with_code() {
    # Usage: log::fatal_with_code number "string"
    log::println "FATAL" "${2:?}"
    exit ${1:?}
}

log::fatal() {
    # Usage: log::fatal "string"
    log::fatal_with_code 125 "${1:?}" >&2
}
