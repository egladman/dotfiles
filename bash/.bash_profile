if [[ "$OSTYPE" == "darwin"* ]]; then
    # Added by Nix installer
    if [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
        source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
        export SHELL="${HOME}/.nix-profile/bin/bash"
    fi

    # Suppress "The default interactive shell is now zsh." warning
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi

# asdf
# It's super important this is present in .bash_profile and not .bashrc
source "${HOME}/.asdf/asdf.sh"
source "${HOME}/.asdf/completions/asdf.bash"

if [ -f "${HOME}/.bashrc" ]; then
    source "${HOME}/.bashrc"
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

export EDITOR="emacs -nw"
export VISUAL="$EDITOR"
export MARKPATH="${HOME}/.marks"
export CDPATH=".:${MARKPATH}"

# Kitty automatically sets this to 'xterm-kitty', and it doesn't always play
# nicely with SSH
export TERM=xterm-256color

# AWS
export AWS_DEFAULT_REGION="us-east-1"

if [[ ! -d "$MARKPATH" ]]; then
    mkdir -p "$MARKPATH"
fi

export PATH="$HOME/.poetry/bin:$PATH"
