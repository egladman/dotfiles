#!/usr/bin/env sh

set -e

DESTDIR="${DESTDIR:-${HOME:?}/.dotfiles}"

if [ ! -d "$DESTDIR" ]; then
    printf '>  %s\n' "Cloning git repository"
    git clone https://github.com/egladman/dotfiles.git "$DESTDIR"

    printf '>  %s\n' "Cloning git submodules"
    (cd "$DESTDIR"; git rm dotfiles-*; git submodule update --init --recursive)
else
    printf '>  %s\n' "Directory '$DESTDIR' already exists. Skipping clone"
fi

printf '>  %s\n' "Stowing"
(cd "$DESTDIR"; ./stow.sh)

printf '>  %s\n' "Successfully installed dotfiles"

