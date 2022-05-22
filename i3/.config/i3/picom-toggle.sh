#!/bin/sh

# Modified fromy https://github.com/arcolinux/arcolinux-i3wm/blob/master/etc/skel/.config/i3/scripts/picom-toggle.sh

echo yeet

if pgrep -x "picom"  > /dev/null 2>&1; then
    # Kill
    printf '%s\n' "Stopping"
    killall -q picom
else
    # Daemonize
        printf '%s\n' "Starting"
    picom -b --experimental-backends
fi
