#!/usr/bin/env bash

self_version=0.1.0

stow_opts=(
    '-v'
)

read -r -d '' self_usage <<-EOF
Wrapper for GNU Stow to simplify dotfile management
Usage: ${0##*/} [option]

OPTIONS
   -h, --help                     show this help text, and exit
   -V, --version                  show version, and exit
   -R, --restow                   Restow dotfiles (first unstow, then stow again). This is
                                  useful for pruning obsolete symlinks
   -D, --delete                   Unstow dotfiles
EOF

case "$1" in
    '')
	      printf '%s\n' "Stowing..."
	      ;;
    -R|--restow)
	      printf '%s\n' "Restowing..."
	      stow_opts=("${stow_opts[@]}" '-R')
	      ;;
    -D|--delete)
	      printf '%s\n' "Deleting..."
	      stow_opts=("${stow_opts[@]}" '-D')
	      ;;
    -V|--version)
	      printf '%s\n' "$self_version"
	      exit 0
	      ;;
    -h|--help)
	      printf '%s\n' "$self_usage"
	      exit 0
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

stow ${stow_opts[@]} ${dir_names[@]} || {
    printf '%s\n' "Command 'stow' returned non-zero code"
    exit 1
}
