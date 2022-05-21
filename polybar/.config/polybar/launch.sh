#!/usr/bin/env sh

if pgrep -x "polybar" > /dev/null 2>&1; then
	  killall -q polybar
fi

printf '%s\n' "---" | tee -a /tmp/polybar-top.log
polybar top 2>&1 | tee -a /tmp/polybar-top.log & disown

printf '%s\n' "Bar(s) launched..."
