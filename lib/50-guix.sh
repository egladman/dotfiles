#!/usr/bin/env bash

guix::install() {
    guix package --install "$@"
}

guix::upgrade() {
    guix package --upgrade "$@"
}
