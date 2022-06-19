if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
        source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
    fi

    export SHELL="${HOME}/.nix-profile/bin/bash"

    # Suppress "The default interactive shell is now zsh." warning
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi
