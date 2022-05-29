#!/usr/bin/env bash

# Turn on logging with the following environment variable
#   POLYBAR_ENABLE_LOGGING

__find_monitors() {
    # Prints active monitors by parsing xrandr with only bash.

    # Monitors: 2
    # 0: +*DP-0 3840/600x2160/340+3840+0  DP-0
    # 1: +DP-2 3840/600x2160/340+0+0  DP-2

    IFS=$'\n' read -d "" -ra xrandr_output < <(xrandr --listactivemonitors)

    set -- "${xrandr_output[@]}"
    shift # Strip header

    declare -a wrkarr monitors
    for l in "$@"; do
        wrkarr=($l)            # Split line into another array
        monitors+=(${wrkarr[-1]}) # Grab the last column from the line
    done

    printf '%s\n' "${monitors[@]}"
}

MONITORS_ACTIVE=($(__find_monitors))
BAR_POSITIONS=(top)

# Stop polybar if its already running
pgrep -x "polybar" > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
	  killall -q polybar
fi

if [[ -n "$POLYBAR_ENABLE_LOGGING" ]]; then
    if [[ ! -d "${TMPDIR:-/tmp}/polybar" ]]; then
        mkdir -p "${TMPDIR:-/tmp}/polybar"
    fi

    # Print line breaks
    for m in "${MONITORS_ACTIVE[@]}"; do
        for l in "${BAR_POSITIONS[@]}"; do
            printf '%s\n' "---" | tee -a "${TMPDIR:-/tmp}/polybar/${m}-${l}.log"
        done
    done
fi

# Start polybar on each monitor and each position
for m in "${MONITORS_ACTIVE[@]}"; do
    for l in "${BAR_POSITIONS[@]}"; do
        if [[ -n "$POLYBAR_ENABLE_LOGGING" ]]; then
            printf '%s\n' "Starting $l polybar on monitor '$m'" | tee -a "${TMPDIR:-/tmp}/polybar/${m}-${l}.log"
        fi
        MONITOR="$m" polybar "$l" & disown
    done
done

printf '%s\n' "Bar(s) launched..."
