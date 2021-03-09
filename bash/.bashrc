# kitty
#source <(kitty + complete setup bash)
source /dev/stdin <<<"$(kitty + complete setup bash)"

# git
source "${HOME}/.config/bash/git-completion.bash"

# starship
eval "$(starship init bash)"

em() {
    emacs -nw $@
}

la() {
 ls -a $@
}

nix-install() {
    # Usage: nix-install <package_name>
    #        nix-install vim

    declare -a nix_argument
    for nix_package in "$@"; do
        local nix_package_fullname

        # Prefix 'nixpkgs.' to package name
        if [[ "${nix_package}" != "nixpkgs."* ]]; then
           nix_package_fullname="nixpkgs.${nix_package}"
        else
            nix_package_fullname="$nix_package"
        fi

        nix_argument=("${nix_argument[@]}" "$nix_package_fullname")
    done
    nix-env -iA ${nix_argument[@]}
}
