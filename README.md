# Dotfiles

My personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

1. Install GNU Stow


2. Clone repo

```
git clone git@github.com:egladman/dotfiles.git ~/.dotfiles
```

*Note:* For this to work without modification you must clone the repo into your home directory


3. Change into directory `~/.dotfiles`

```
cd ~/.dotfiles
```

4. Initalize dotfiles

```sh
./stow.sh
```

*Note:* The following script runs `stow` on all top-level directories in `~/.dotfiles`

## Post Install


If at any point you would like to remove the symlinks created by `stow` run the command:

```sh
./stow.sh --delete
```
