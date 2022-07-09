#!/usr/bin/env bash

# User overrides. Set any of the following variables in your environment to
# override the default behavior
POLYBAR_LAUNCHER_MONITORS="$POLYBAR_LAUNCHER_MONITORS"
POLYBAR_LAUNCHER_POSITIONS="${POLYBAR_LAUNCHER_POSITIONS:-top bottom}"
POLYBAR_LAUNCHER_ENABLE_LOGGING="${POLYBAR_LAUNCHER_ENABLE_LOGGING:-0}"
POLYBAR_LAUNCHER_QUIT_METHOD="${POLYBAR_LAUNCHER_QUIT_METHOD:-ipc}" # killall, ipc
POLYBAR_LAUNCHER_WAIT_MAX="${POLYBAR_LAUNCHER_WAIT_MAX:-4}" # Number of matches required
POLYBAR_LAUNCHER_WAIT_INTERVAL="${POLYBAR_LAUNCHER_WAIT_INTERVAL:-0.05}" # Seconds

__find_monitors() {
    # Prints all available monitors without additional dependencies

    IFS=$'\n' polybar_output=($(polybar --list-monitors))
    if [[ $? -ne 0 ]]; then
        return 12
    fi
    unset IFS
    set -- "${polybar_output[@]}"

    local item
    declare -a wrkarr monitors
    for l in "$@"; do
        wrkarr=($l) # Split string by whitespace

        item="${wrkarr[0]}" # First column includes monitor name
        item="${item%%:}"   # Strip colon from end of string if present
        if [[ "${wrkarr[-1]}" == '(primary)' ]]; then
            item="*${item}" # Prefix with wildcard to denote primary screen
        fi

        monitors+=("$item")
    done

    printf '%s\n' "${monitors[@]}"
}

__wait_for_x() {
    # Block launching polybar until all monitors are active. This is a hack,
    # and is most likely related to autorandr.

    # Unblock once the same randr output is printed n times

    declare -a res
    local match_count match_max nomatch_count nomatch_max

    match_count=0
    match_max=$POLYBAR_LAUNCHER_WAIT_MAX
    nomatch_count=0

    while :; do
        res+=("$(polybar --list-monitors)")

        if [[ ${#res[@]} -lt 2 ]]; then
            sleep ${POLYBAR_LAUNCHER_WAIT_INTERVAL}s
            continue
        fi

        if [[ "${res[-1]}" != "${res[-2]}" ]]; then
            match_count=0 # Reset
            nomatch_count=$((nomatch_count + 1))
        else
            nomatch_count=0 # Reset
            match_count=$((match_count + 1))
        fi

        if [[ $match_count -eq $match_max ]]; then
            break
        fi

        sleep ${POLYBAR_LAUNCHER_WAIT_INTERVAL}s
    done
}

__stop_polybar() {
    # Stop any running polybar processes

    pgrep -x "polybar" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then # Presume it's the first boot
        __wait_for_x
	      return 0
    fi

    case "$POLYBAR_LAUNCHER_QUIT_METHOD" in
        killall)
            killall -q polybar
            ;;
        ipc)
            polybar-msg cmd quit
            ;;
    esac
}

# Stop polybar if it's already running
__stop_polybar

selected_positions=($POLYBAR_LAUNCHER_POSITIONS) # Split by space
selected_monitors=($POLYBAR_LAUNCHER_MONITORS)   # Split by space
if [[ ${#selected_monitors[@]} -eq 0 ]]; then
    selected_monitors=($(__find_monitors))
    return_code=$?
    if [[ $return_code -ne 0 ]]; then
        printf '%s\n' "Failed to find active monitors."
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
