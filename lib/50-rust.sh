#!/usr/bin/env bash

cargo::install() {
    cargo install --bins "$@"
}

cargo::update() {
    cargo::install "$@"
}
