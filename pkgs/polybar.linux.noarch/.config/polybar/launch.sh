#!/usr/bin/env bash

# User overrides. Set any of the following variables in your environment to
# override the default behavior
POLYBAR_LAUNCHER_MONITORS="$POLYBAR_LAUNCHER_MONITORS"
POLYBAR_LAUNCHER_POSITIONS="${POLYBAR_LAUNCHER_POSITIONS:-top bottom}"
POLYBAR_LAUNCHER_ENABLE_LOGGING="${POLYBAR_LAUNCHER_ENABLE_LOGGING:-0}"

__find_monitors() {
    # Prints active monitors by parsing xrandr with only bash.

    # Monitors: 2
    # 0: +*DP-0 3840/600x2160/340+3840+0  DP-0
    # 1: +DP-2 3840/600x2160/340+0+0  DP-2
    IFS=$'\n' xrandr_output=($(xrandr --listactivemonitors))
    if [[ $? -ne 0 ]]; then
        return 12
    fi
    unset IFS

    set -- "${xrandr_output[@]}"
    shift # Strip header

    declare -a wrkarr monitors
    for l in "$@"; do
        wrkarr=($l)                            # Split line into another array
        if [[ "${wrkarr[1]}" == '+*'* ]]; then # We found the primary monitor
            wrkarr[-1]="*${wrkarr[-1]}"
        fi
        monitors+=(${wrkarr[-1]})              # Grab the last column from the line
    done

    printf '%s\n' "${monitors[@]}"
}

selected_positions=($POLYBAR_LAUNCHER_POSITIONS) # Split by space
selected_monitors=($POLYBAR_LAUNCHER_MONITORS)   # Split by space
if [[ ${#selected_monitors[@]} -eq 0 ]]; then
    selected_monitors=($(__find_monitors))
    return_code=$?
    if [[ $return_code -ne 0 ]]; then
        printf '%s\n' "Failed to find active monitors with xrandr."
        exit $return_code # Bubble up return code
    fi
fi

if [[ "$POLYBAR_LAUNCHER_ENABLE_LOGGING" -eq 1 ]]; then
    if [[ ! -d "${TMPDIR:-/tmp}/polybar" ]]; then
        mkdir -p "${TMPDIR:-/tmp}/polybar"
    fi

    printf '%s\n' "Initializing with monitors: ${selected_monitors[*]}" | tee -a "${TMPDIR:-/tmp}/polybar/launcher.log"
    printf '%s\n' "Initializing with bars: ${selected_positions[*]}" | tee -a "${TMPDIR:-/tmp}/polybar/launcher.log"
fi

# Stop polybar if its already running
pgrep -x "polybar" > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
	  killall -q polybar
fi

# Start polybar on each monitor and each position
for m in "${selected_monitors[@]}"; do
    is_primary=0
    if [[ "$m" == '*'* ]]; then
        is_primary=1
        m="${m##'*'}" # Remove wildcard
        printf '%s\n' "Monitor '$m' is primary" | tee -a "${TMPDIR:-/tmp}/polybar/launcher.log"
    fi

    for l in "${selected_positions[@]}"; do
        if [[ $is_primary -eq 1 ]]; then
            l="${l}-primary"
        fi

        if [[ "$POLYBAR_LAUNCHER_ENABLE_LOGGING" -eq 1 ]]; then
            printf '%s\n' "Starting $l polybar on monitor '$m'" | tee -a "${TMPDIR:-/tmp}/polybar/${m}-${l}.log"
        fi
        MONITOR="$m" polybar "$l" & disown
    done
done

printf '%s\n' "Bar(s) launched."
