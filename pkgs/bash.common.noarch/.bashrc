# kitty
#source <(kitty + complete setup bash)
source /dev/stdin <<<"$(kitty + complete setup bash)"

# git
source "${HOME}/.config/bash/git-completion.bash"

# starship
eval "$(starship init bash)"

cd() {
    case "$*" in
        '...') # git repository root
            local path
            path="$(git rev-parse --show-toplevel)"
            if [[ $? -ne 0 ]]; then
                printf '%s\n' "${FUNCNAME[0]}: Not inside a git repository"
                return 1
            fi
            set -- "$path"
            ;;
    esac

    command cd "$@"
}

em() {
    local editor_command=(emacs)
    if [[ -S "${TMPDIR:-/tmp}/emacs.socket" ]]; then
        editor_command=(emacsclient --socket-name "${TMPDIR:-/tmp}/emacs.socket" )
    fi
    "${editor_command[@]}" -nw "$@"
}

la() {
    ls -a "$@"
}

mkcd() {
    # Create multiple directories and cd into the first one
    mkdir -p "$@" && cd "!$"
}

k() {
    kubectl "$@"
}

sss() {
    if [[ ! -d "${HOME:?}"/.dotfiles ]]; then
        return 1
    fi

    pushd "${HOME:?}"/.dotfiles
    ./stow.sh "$@"
    popd
}

unpack() {
    # Usage: unpack <file1> <file2>
    #        unpack foobar.tar.gz

    for target in "$@"; do
        if [[ ! -f "$target" ]]; then
            printf '%s\n' "${FUNCNAME[0]}: File '$target' does not exist"
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
                printf '%s\n' "${FUNCNAME[0]}: File '$target' has unsupported extension"
                return 1
        esac
    done
}

############
# Bookmark #
############

__mark_ensure_prefix() {
    local target prefix
    prefix="@"

    # Prefix can be any single character, but works best with easily typable
    # special characters

    if [[ -n "$1" ]] && [[ -z "$2" ]]; then
        target="$1"
    elif [[ ${#1} -eq 1 ]] && [[ -n "$2" ]]; then # Override prefix
        prefix="$1"
        target="$2"
    else
        return 1
    fi

    printf '%s\n' "${prefix}${target}"
}

mark() {
    # Usage: mark name
    #        mark @ name

    # Bookmark the current working directory for easy reference in the future.

    # cd @name        # jump to bookmark
    # cd @<tab>       # list bookmarks
    # cd @n<tab>      # auto-complete
    # cd @name/<tab>  # can access sub-directories within bookmarks

    # Not an original idea. Just improved upon
    # - http://karolis.koncevicius.lt/posts/fast_navigation_in_the_command_line/
    # - https://news.ycombinator.com/item?id=26899531

    local target
    target="$(__mark_ensure_prefix "$@")"
    if [[ $? -ne 0 ]]; then
        printf '%s\n' "${FUNCNAME[0]}: Unsupported argument. No argument was passed or prefix exceeded character count."
        return 1
    fi

    ln -sr "${PWD}" "${MARKPATH:?}/${target}"
}

unmark() {
    local target
    target="$(__mark_ensure_prefix "$@")"
    if [[ $? -ne 0 ]]; then
        printf '%s\n' "${FUNCNAME[0]}: Unsupported argument. No argument was passed or prefix exceeded character count."
        return 1
    fi

    rm -i "${MARKPATH:?}/${target}"
}

##########
# Docker #
##########

docker-shell() {
    # Usage: docker-shell <imageRepository>
    #        docker-shell image <imageRepository>
    #        docker-shell image <imageRepository> <shell>
    #        docker-shell container <containerName>
    #        docker-shell container <containerName> <shell>

    # Start an interactive shell session in a new or running container. Defaults to bash

    declare -a docker_opts

    local context
    case "$1" in
        i|image)
            context="run"
            docker_opts+=("--rm")
            ;;
        c|container)
            context="exec"
            ;;
    esac

    # Default to 'run' if no context is given
    if [[ -z "$context" ]]; then
        context=run
    else
        shift
    fi

    docker "$context" "${docker_opts[@]}" --tty --interactive "$1" "${2:-bash}"
}

#######
# Nix #
#######

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
    nix-env -iA "${nix_argument[@]}"
}

nix-uninstall() {
    # Usage: nix-uninstall <package_name>
    #        nix-uninstall vim

    nix-env --uninstall "S@"
}

nix-update() {
    # Usage: nix-update

    # Update the list of packages

    nix-channel --update
}

nix-upgrade() {
    # Usage: nix-upgrade

    # Upgrade packages

    nix-env -u
}

nix-search() {
    # Usage: nix-search

    # Find package by substring

    nix-env -qaP '.*'"${1}"'.*'
}

###########
# Toy box #
###########

flip-coin() {
    [[ $((RANDOM%2)) -eq 1 ]] && printf '%s\n' "heads" || printf '%s\n' "tails"
}
