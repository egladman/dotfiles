GOPATH="${HOME:?}/.go"

# User specific environment
if [[ ! "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"
fi

if [[ -d /gnu/store ]]; then
    # The result of running guix pull is a profile available under
    # ~/.config/guix/current containing the latest Guix. Thus, make
    # sure to add it to the beginning of your search path so that
    # you use the latest version
    # https://guix.gnu.org/manual/en/html_node/Invoking-guix-pull.html
    PATH="${HOME}/.config/guix/current/bin:${PATH}"

    PATH="${HOME}/.guix-profile/bin:${PATH}"
fi

if [[ -d "$GOPATH" ]]; then
    PATH="${PATH}:${GOPATH}/bin"
fi

if [[ -d "${HOME:?}/.cargo/bin" ]]; then
    PATH="${PATH}:${HOME}/.cargo/bin"
fi

export PATH GOPATH
