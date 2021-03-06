#!/usr/bin/env sh

stow_opts=''

case "$1" in
    '')
	printf '%s\n' "Stowing..."
	;;
    -D|--delete)
	printf '%s\n' "Deleting..."
	stow_opts='-D'
	;;
    *)
	printf '%s\n' "Unsupported option"
	exit 1
	;;
esac

declare -a dir_names
dir_names=($(find * -type d -maxdepth 0 -print))
if [ $? -ne 0 ]; then
    printf '%s\n' "Command 'find' returned non-zero code"
fi

stow "$stow_opts" "${dir_names[@]}" || {
    printf '%s\n' "Command 'stow' returned non-zero code"
    exit 1
}
