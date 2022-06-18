#!/usr/bin/env bash

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

__find_primary() {
    selected_monitors=($(__find_monitors))
    return_code=$?
    if [[ $return_code -ne 0 ]]; then
        printf '%s\n' "Failed to find active monitors with xrandr."
        return $return_code # Bubble up return code
    fi

    for m in "${selected_monitors[@]}"; do
        if [[ "$m" == '*'* ]]; then
            primary="${m##'*'}" # Remove wildcard
        fi
    done

    if [[ -z "$primary" ]]; then
        printf '%s\n' "Failed to find primary monitor."
        return 2
    fi
}

MONITOR="$(__find_primary)"
if [[ $? -ne 0 ]]; then
    exit 1
fi
export MONITOR

xidlehook \
    `# Don't lock when there's a fullscreen application` \
    --not-when-fullscreen \
    `# Don't lock when there's audio playing` \
    --not-when-audio \
    `# Dim the screen after 60 seconds, undim if user becomes active` \
    --timer 60 \
    'xrandr --output "$MONITOR" --brightness .1' \
    'xrandr --output "$MONITOR" --brightness 1' \
    `# Undim & lock after 10 more seconds` \
    --timer 10 \
    'xrandr --output "$MONITOR" --brightness 1; i3lock' \
    '' \
    `# Finally, suspend an hour after it locks` \
    --timer 3600 \
    'systemctl suspend' \
    ''
