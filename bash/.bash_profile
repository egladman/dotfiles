if [[ "$OSTYPE" == "darwin"* ]]; then
    # Added by Nix installer
    if [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
        source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
    fi
    export SHELL="${HOME}/.nix-profile/bin/bash"

    # Suppress "The default interactive shell is now zsh." warning
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi

case "OSTYPE" in
    solaris*)
        OSTYPE_NAME=solaris
        ;;
    darwin*)
        OSTYPE_NAME=darwin
        ;;
    linux*)
        OSTYPE_NAME=linux
        ;;
    bsd*)
        OSTYPE_NAME=bsd
        ;;
esac
export OSTYPE_NAME

if [ -f "${HOME}/.bashrc" ]; then
    source "${HOME}/.bashrc"
fi

export EDITOR="emacs -nw"
export VISUAL="$EDITOR"
