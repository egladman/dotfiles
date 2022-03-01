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
    emacs -nw "$@"
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

h() {
    helm "$@"
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
    # Usage: docker-shell <imagerepository>
    #        docker-shell <imagerepository> <shell>

    docker run --rm --tty --interactive "$1" "${2:-/bin/bash}"
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

#########################
# Immuta (Nonsensitive) #
#########################

immuta-aws-sso-login() {
    # Usage: immuta-aws-sso-login
    #        immuta-aws-sso-login <profile>

    declare -a aws_opts
    if [[ -n "$1" ]]; then
        aws_opts=(--profile "$1")
    fi
    aws sso login "${aws_opts[@]}"
}

immuta-aws-ecr-login() {
    # Usage: immuta-aws-ecr-login
    #        immuta-aws-ecr-login <profile>

    source "${HOME}/.config/immuta/bash/immuta.env" || {
        printf '%s\n' "${FUNCNAME[0]}: Unable to source '${HOME}/.config/bash/immuta.env'"
        return 1
    }

    immuta-aws-sso-login "$1" && {
        aws ecr get-login-password | docker login --username AWS --password-stdin "${IMMUTA_AWS_ECR_URL:?}"
    }
}
