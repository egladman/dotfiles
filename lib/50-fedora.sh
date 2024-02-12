#!/usr/bin/env bash

dnf::install() {
    dnf install --assumeyes "$@"
}

dnf::update() {
    dnf update --assumeyes "$@"
}
