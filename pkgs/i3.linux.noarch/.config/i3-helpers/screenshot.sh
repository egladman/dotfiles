#!/usr/bin/env sh

set -e

# Use imagemagick to take a screenshot of the current i3 window. Optionally
# store it in your clipboard

# Usage:
# ./screenshot.sh --clip
# ./screenshot.sh --destdir path/to/dir
# ./screenshot.sh --window root
# ./screenshot.sh --window focused

OPT_NOTIFY=1
OPT_SAVE_TO_CLIPBOARD=0
OPT_SCREENSHOT_DIR="${HOME:?}/Pictures"

__i3_get_focused_window() {
    i3-msg -t get_tree | \
        jq -r 'recurse(.nodes[];.nodes!=null)|select(.focused).window'
}

__date_get_iso_8601() {
    date +"%Y-%m-%dT%H:%M:%S%:z"
}

main() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -c|--clip)
                OPT_SAVE_TO_CLIPBOARD=1
                ;;
            -d|--destdir)
                OPT_SCREENSHOT_DIR="${2:?}"
                shift
                ;;
            -w|--window)
                OPT_SELECTED_WINDOW="${2:?}"
                shift
                ;;
            *)
                printf '%s\n' "Invalid option '$1'"
                exit 128
                ;;
        esac
        shift
    done

    case "$OPT_SELECTED_WINDOW" in
        focused)
            window_id="$(__i3_get_focused_window)"
            ;;
        root)
            window_id="root"
            ;;
    esac

    set -- import
    if [ -n "$window_id" ]; then
        set -- "$@" -window "$window_id"
    fi

    # Save to clipboard
    if [ $OPT_SAVE_TO_CLIPBOARD -eq 1 ]; then
        "$@" png:- | xclip -selection clipboard -t image/png

        if [ $OPT_NOTIFY -eq 1 ]; then
            notify-send "Saved window '${window_id:-undefined}' to clipboard"
        fi
        printf '%s\n' "Saved window '${window_id:-undefined}' to clipboard"

        exit 0
    fi

    # Save to file
    screenshot_path="${OPT_SCREENSHOT_DIR}/screenshot-$(__date_get_iso_8601).png"
    if [ ! -d "$OPT_SCREENSHOT_DIR" ]; then
        mkdir -p "$OPT_SCREENSHOT_DIR"
    fi
    "$@" "$screenshot_path"

    if [ $OPT_NOTIFY -eq 1 ]; then
        notify-send "Saved window '${window_id:-undefined}' to path '${screenshot_path}'"
    fi
    printf '%s\n' "Saved window '${window_id:-undefined}' to path '${screenshot_path}'"
}

main "$@"
