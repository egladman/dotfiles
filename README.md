# Dotfiles

My personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```
git clone --recursive git@github.com:egladman/dotfiles.git ~/.dotfiles; (cd ~/.dotfiles; ./stow.sh)
```

## Usage

```
Wrapper for GNU Stow to simplify dotfile management
Usage: stow.sh [option]

OPTIONS
   -h, --help                     Show this help text, and exit
   -V, --version                  Show version, and exit
   -S, --stow                     Stow dotfiles (this is the default action and can be omitted)
   -R, --restow                   Restow dotfiles (first unstow, then stow again). This is
                                  useful for pruning obsolete symlinks
   -D, --delete                   Unstow dotfiles
   -u, --dry-run                  Do not perform any operations that modify the filesystem; merely
                                  show what would happen.
```

Note: For the most up-to-date usage run `./stow.sh --help`
