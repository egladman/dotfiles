#!/usr/bin/env sh

set -e

DESTDIR="${DESTDIR:-${HOME:?}/dotfiles}"
INCLUDE_PRIVATE="${INCLUDE_PRIVATE:-0}"

if [ ! -d "$DESTDIR" ]; then
    printf '>  %s\n' "Cloning git repository"
    git clone https://github.com/egladman/dotfiles.git "$DESTDIR"

    # Do not attempt to clone top-level git submodules by default
    if [ $INCLUDE_PRIVATE -eq 0 ]; then
        printf '>  %s\n' "Tidying git submodules"
        (cd "$DESTDIR"; git rm src/module.*) || true
    fi

    printf '>  %s\n' "Cloning git submodules"
    (cd "$DESTDIR"; git submodule update --init --recursive)
else
    printf '>  %s\n' "Directory '$DESTDIR' already exists. Skipping clone"
fi

printf '>  %s\n' "Stowing"
(cd "$DESTDIR"; ./bin/sstow src)

printf '>  %s\n' "Successfully installed dotfiles"
