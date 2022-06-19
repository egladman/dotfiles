# Extend functionality of starship

BASHPROFILED_USER_SHELL_WHEREAMI_DIR="${XDG_STATE_HOME:-${HOME:?}/.local/state}/shell-session"

# Function starship_precmd invokes starship_precmd_user_func
__starship_precmd_user() {
    pwd > "${BASHPROFILED_USER_SHELL_WHEREAMI_DIR}/whereami"
}

starship_precmd_user_func="__starship_precmd_user"

# Bash examines the value of the array variable PROMPT_COMMAND just before
# printing each primary prompt. If any elements in PROMPT_COMMAND are set and
# non-null, Bash executes each value, in numeric order, just as if it had been
# typed on the command line.

# Source: https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html

# Starship overrides the PROMPT_COMMAND instead of just amending to it for some
# dumb reason. This feels like one giant hack

# $ echo $PROMPT_COMMAND
# starship_precmd
