flatpak::install() {
    flatpak install --system --assumeyes --noninteractive "$@"
}

flatpak::update() {
    flatpak update --system --assumeyes --noninteractive "$@"
}
