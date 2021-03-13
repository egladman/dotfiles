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

unpack() {
    # Usage: unpack <file1> <file2>
    #        unpack foobar.tar.gz

    for target in "$@"; do
        if [[ ! -f "$target" ]]; then
           printf '%s\n' "${FUNCNAME[0]}: file '$target' does not exist"
           return 1
        fi
    done

    for target in "$@"; do
        case "$target" in
            *.tar.gz|*.tgz)
                tar xzf "$target"
                ;;
            *.tar.bz2|*.tbz2)
                tar xjf "$target"
                ;;
            *.rar)
                unrar x "$target"
                ;;
            *.zip)
                unzip "$target"
                ;;
            *.Z)
                uncompress "$target"
                ;;
            *.7z)
                7z x "$target"
                ;;
            *)
                printf '%s\n' "${FUNCNAME[0]}: file '$target' has unsupported extension"
                return 1
        esac
    done
}
