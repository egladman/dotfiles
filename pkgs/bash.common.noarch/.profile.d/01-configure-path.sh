GOPATH="${HOME:?}/.go"

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"
fi

if [[ -d "$GOPATH" ]]; then
    PATH="${PATH}:${GOPATH}/bin"
fi

if [[ -d "${HOME:?}/.cargo/bin" ]]; then
    PATH="${PATH}:${HOME}/.cargo/bin"
fi

export PATH GOPATH
