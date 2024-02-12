#!/usr/bin/env bash

go::install() {
    go install "$@"
}

go::update() {
    go::install "$@"
}
