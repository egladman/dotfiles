if [[ -d "${HOME:?}/.profile.d" ]]; then
    for f in "${HOME}"/.profile.d/*.sh; do
        source "$f"
    done
fi

if [[ -f "${HOME:?}/.bashrc" ]]; then
    source "${HOME}/.bashrc"
fi
