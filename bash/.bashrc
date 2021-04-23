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

immuta-minikube-init() {
    # Usage: immuta-minikube-init
    #        immuta-minikube-init <containerRuntime>
    #        immuta-minikube-init <containerRuntime> true

    # Start/Configure minikube if not running. Optionally use minikube's docker
    # daemon (disabled by default)

    local runtime use_minikube_dockerd config status response
    runtime="${1:-docker}"
    use_minikube_dockerd="${2:-false}"

    declare -a response
    response=($(minikube config view --format " {{.ConfigKey}} {{.ConfigValue}} "))
    if [[ $? -ne 0 ]]; then
        printf '%s\n' "${FUNCNAME[0]}: Unable to fetch minikube config"
        return 1
    fi
    set -- "${response[@]}"

    # minikube config view doesn't return the results in the same order
    # everytime. So first we must order it
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            driver)
                config[3]="$2"
                shift 2
                ;;
            kubernetes-version)
                config[4]="$2"
                shift 2
                ;;
            memory)
                config[1]="$2"
                shift 2
                ;;
            cpus)
                config[0]="$2"
                shift 2
                ;;
            disk-size)
                config[2]="$2"
                shift 2
                ;;
            *)
                printf '%s\n' "${FUNCNAME[0]}: Got unknown key '$1' from 'minikube config view'"
                return 1
        esac
    done

    # cpus                    config[0]
    # memory                  config[1]
    # disk-size               config[2]
    # driver                  config[3]
    # kubernetes-version      config[4]

    case "$OSTYPE" in
        darwin*)
            [[ "${config[3]}" == "hyperkit" ]] || minikube config set driver hyperkit
            ;;
    esac

    status="$(minikube status --format "{{.Host}}")"
    if [[ $? -ne 0 ]]; then
        printf '%s\n' "${FUNCNAME[0]}: Unable to determine minikube status"
        return 1
    fi

    case "$status" in
        Running)
            printf '%s\n' "${FUNCNAME[0]}: minikube is already running"
            ;;
        *)
            minikube start
            ;;
    esac


    [[ "$use_minikube_dockerd" == "false" ]] && return
    case "$runtime" in
        docker)
            [[ -n "$MINIKUBE_ACTIVE_DOCKERD" ]] && return

            printf '%s\n' "${FUNCNAME[0]}: Configuring environment to use minikube’s Docker daemon"
            eval $(minikube docker-env)
            ;;
        podman)
            [[ -n "$MINIKUBE_ACTIVE_PODMAN" ]] && return

            printf '%s\n' "${FUNCNAME[0]}: Configuring environment to use minikube’s Podman service"
            eval $(minikube podman-env)
            ;;
        *)
            printf '%s\n' "${FUNCNAME[0]}: Unsupported container runtime '${runtime}'"
            return 1
            ;;
    esac
}

immuta-minikube-docker-registry-init() {
    # Usage: immuta-minikube-docker-registry-init
    #        immuta-minikube-docker-registry-init --container <string> --port <integer>
    #        immuta-minikube-docker-registry-init stop

    # Setup a local docker registry for minikube

    local container container_id port response

    # Defaults
    container="minikube-registry-hack"
    port="5000"

    declare -a func_argv
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --port)
                port="$2"
                shift
                ;;
            --container)
                container="$2"
                shift
                ;;
            *)
                func_argv+=("$1")
                ;;
        esac
        shift
    done
    set -- "${func_argv[@]}"

    case "$1" in
        ''|start)
            printf '%s\n' "${FUNCNAME[0]}: Initalizing"
            ;;
        down|stop)
            docker stop "$container"
            return
            ;;
        *)
            printf '%s\n' "${FUNCNAME[0]}: Unsupported argument '$1'"
            return 1
            ;;
    esac

    response="$(minikube addons list --output json | jq -r .registry.Status)"
    if [[ $? -eq 0 ]] && [[ "$response" != "enabled" ]]; then
        minikube addons enable registry
    fi

    declare -a docker_opts
    docker_opts=(
        --detach
        --name "$container"
        --network=host
        --rm
    )

    container_id="$(docker ps --quiet --filter name=$container)"
    if [[ $? -ne 0 ]]; then
        printf '%s\n' "${FUNCNAME[0]}: Unable to determine if container '$container' already exists"
        return 1
    fi

    # Does the container already exist?
    if [[ -n "$container_id" ]]; then
        printf '%s\n' "${FUNCNAME[0]}: Container '$container' already running"
        return
    fi

    # https://minikube.sigs.k8s.io/docs/handbook/registry/#enabling-insecure-registries
    #   In order to make docker accept pushing images to this registry, we have
    #   to redirect port 5000 on the docker virtual machine over to port 5000
    #   on the minikube machine. We can (ab)use docker’s network configuration
    #   to instantiate a container on the docker’s host, and run socat there:

    docker run "${docker_opts[@]}" alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):$port" &> /dev/null

    export IMMUTA_MINIKUBE_CONTAINER_REGISTRY_URL="localhost:${port}"
    printf '%s\n' "localhost:${port}"
}

immuta-minikube-push-image() {
    # Usage: immuta-minikube-push-image <image_id|image_name> <image_path>
    #        immuta-minikube-push-image 83244507c33d myimage:latest
    #        immuta-minikube-push-image 83244507c33d myname/myimage:latest

    # Copy a local docker image to minikube's container repository

    image="${1:?}"
    target="${2:?}"

    if [[ -z "$IMMUTA_MINIKUBE_CONTAINER_REGISTRY_URL" ]]; then
        printf '%s\n' "${FUNCNAME[0]}: Enviroment variable 'IMMUTA_MINIKUBE_CONTAINER_REGISTRY_URL' is unset or an empty string. Run:"
        printf '  %s\n' "immuta-minikube-docker-registry-init"
        return 1
    fi

    docker tag "$image" "${IMMUTA_MINIKUBE_CONTAINER_REGISTRY_URL}/${target}" && \
    docker push "${IMMUTA_MINIKUBE_CONTAINER_REGISTRY_URL}/${target}"
}

immuta-minikube-push-images-all() {
    mapfile -t images < <(docker image ls --format "{{.ID}} {{ .Repository }} {{.Tag}}")
    for image in "${images[@]}"; do
        
    done
}

