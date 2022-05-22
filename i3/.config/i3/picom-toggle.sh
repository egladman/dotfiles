#!/bin/sh

# Modified fromy https://github.com/arcolinux/arcolinux-i3wm/blob/master/etc/skel/.config/i3/scripts/picom-toggle.sh

if pgrep -x "picom"  > /dev/null 2>&1; then
    # Kill
    killall -q picom
else
    # Daemonize
    picom -b --experimental-backends
fi
