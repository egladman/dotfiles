# Dotfiles

My personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Features

- Supports Linux and MacOS
- Supports multiple architectures
- Written in pure bash with no dependencies on external processes/programs (besides stow)
- Git submodule support

## Quick Start

### Simplified

**Note:** Piping curl to a shell is inherently dangerous. Only do so if you understand the risk.

```
curl https://raw.githubusercontent.com/egladman/dotfiles/master/install.sh | sh
```

### Advanced

```
git clone --recursive git@github.com:egladman/dotfiles.git ~/dotfiles; (cd ~/dotfiles; ./bin/sstow pkgs)
```

## Usage

```
Wrapper for GNU Stow to simplify cross-platform dotfile management
Usage: sstow [option] path/to/pkgs

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

Note: For the most up-to-date usage run `./bin/sstow --help`

### Advanced

Override auto-detected system facts with the following environment variables:

- `TARGETARCH`
  - Values: `x86_64, aarch64`
  - Details: Run `uname -m` if your architecture isn't listed
- `TARGETOS`
  - Values: `linux, darwin`


## Install os/flatpak packages system-wide

```
sudo ./bootstrap.sh install
```
