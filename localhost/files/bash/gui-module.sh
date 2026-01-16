# ~/.config/bash/gui-module.sh
# Managed by Ansible (recommended). Source from ~/.bashrc for interactive shells.

# Robust git branch / commit display for PS1
parse_git_branch() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local b
  b="$(git symbolic-ref --quiet --short HEAD 2>/dev/null \
      || git rev-parse --short HEAD 2>/dev/null)" || return 0

  printf '(%s)' "$b"
}

# Customize BASH PS1 prompt
set_PS1() {
  # Text reset
  local Color_Off="\[\033[0m\]"

  # High intensity colors (used in prompt)
  local IRed="\[\033[0;91m\]"
  local IGreen="\[\033[0;92m\]"
  local IYellow="\[\033[0;93m\]"
  local IWhite="\[\033[0;97m\]"

  # Prompt variables
  local PathShort="\w"
  local User="\u"
  local Git_branch="\$(parse_git_branch)"

  # Example: user path (branch): 
  local ps1_terminal_string="${IYellow}${User} ${IRed}${PathShort} ${IGreen}${Git_branch} ${IWhite}: ${Color_Off}"
  export PS1="$ps1_terminal_string"
}

# Run prompt setup
set_PS1

# make less more friendly for non-text input files, see lesspipe(1)
if command -v lesspipe >/dev/null 2>&1; then
  eval "$(SHELL=/bin/sh lesspipe)"
fi

# change ls colors (BSD-style LSCOLORS; may or may not be used depending on ls/dircolors setup)
export LSCOLORS="BxFxCxDxBxEgEdAbAgAcAd"
