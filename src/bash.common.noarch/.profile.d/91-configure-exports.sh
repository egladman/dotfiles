export EDITOR="emacs -nw"
export VISUAL=$EDITOR
export MARKPATH="${HOME:?}/.marks"
export CDPATH=".:${MARKPATH}"

# Kitty automatically sets this to 'xterm-kitty', and it doesn't always play
# nicely with SSH
export TERM=xterm-256color

export AWS_DEFAULT_REGION="us-east-1"
