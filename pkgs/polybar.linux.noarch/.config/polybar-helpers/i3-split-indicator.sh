#!/usr/bin/env sh

label_name="layout"
printf "$label_name %s\n" "unknown"

# Wait until the i3 socket is ready
while true; do
    i3-msg -t get_version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        break
    fi
    sleep 0.2
done

__i3_get_focused_layout() {
    i3-msg -t get_tree | \
        jq -r 'recurse(.nodes[];.nodes!=null)|select(.nodes[].focused).layout'
}

__i3_subscribe_to_event() {
    i3-msg -t subscribe -m "[ \"$1\" ]"
}

__i3_print_focused_layout() {
    printf "$label_name %s\n" "$(__i3_get_focused_layout)"
}

# Subscribing to event 'bindings' is kinda hacky, and will likely break
__i3_print_focused_layout
__i3_subscribe_to_event "binding" | while read -r; do
    __i3_print_focused_layout
done
