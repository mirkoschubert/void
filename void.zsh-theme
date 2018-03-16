
is_git() {
  command git rev-parse --is-inside-work-tree &>/dev/null
}

git_status() {

  local INDEX git_status=""
  INDEX=$(command git status --porcelain -b 2> /dev/null)

  # Check for untracked files
  if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    git_status="?"
  fi

  # Check for staged files
  if $(echo "$INDEX" | command grep '^A[ MDAU] ' &> /dev/null); then
    git_status="+"
  elif $(echo "$INDEX" | command grep '^M[ MD] ' &> /dev/null); then
    git_status="+"
  elif $(echo "$INDEX" | command grep '^UA' &> /dev/null); then
    git_status="+"
  fi

  # Check for modified files
  if $(echo "$INDEX" | command grep '^[ MARC]M ' &> /dev/null); then
    git_status="!"
  fi

  # Check for renamed files
  if $(echo "$INDEX" | command grep '^R[ MD] ' &> /dev/null); then
    git_status="»"
  fi

  # Check for deleted files
  if $(echo "$INDEX" | command grep '^[MARCDU ]D ' &> /dev/null); then
    git_status="✘"
  elif $(echo "$INDEX" | command grep '^D[ UM] ' &> /dev/null); then
    git_status="✘"
  fi

  # Check for stashes
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    git_status="$"
  fi

  # Check for unmerged files
  if $(echo "$INDEX" | command grep '^U[UDA] ' &> /dev/null); then
    git_status="="
  elif $(echo "$INDEX" | command grep '^AA ' &> /dev/null); then
    git_status="="
  elif $(echo "$INDEX" | command grep '^DD ' &> /dev/null); then
    git_status="="
  elif $(echo "$INDEX" | command grep '^[DA]U ' &> /dev/null); then
    git_status="="
  fi

  # Check whether branch is ahead
  local is_ahead=false
  if $(echo "$INDEX" | command grep '^## [^ ]\+ .*ahead' &> /dev/null); then
    is_ahead=true
  fi

  # Check whether branch is behind
  local is_behind=false
  if $(echo "$INDEX" | command grep '^## [^ ]\+ .*behind' &> /dev/null); then
    is_behind=true
  fi

  # Check wheather branch has diverged
  if [[ "$is_ahead" == true && "$is_behind" == true ]]; then
    git_status="⇕"
  else
    [[ "$is_ahead" == true ]] && git_status="⇡"
    [[ "$is_behind" == true ]] && git_status="⇣"
  fi

  if [[ -n $git_status ]]; then
    # Status prefixes are colorized
    echo " $git_status"
  fi
}

prompt_setup() {
  autoload -Uz colors && colors
  autoload -Uz vcs_info
  setopt prompt_su

  # set up exit_code
  typeset -g void_exit_code
  precmd_void_exit_code() { if (( $? == 0 )); then void_exit_code="blue"; else void_exit_code="red"; fi

  # handle vcs_info
  precmd_vcs_info() { vcs_info  }
  precmd_functions+=( precmd_vcs_info precmd_void_exit_code  )

  # show git branch name
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git*' formats '%b'
  #zstyle ':vcs_info:*:*' formats ' · %b'

  export PS1='%{$fg[$void_exit_code]%}›%{$reset_color%} '
  export RPROMPT='%{$fg[blue]%}$(basename $PWD)$vcs_info_msg_0_%{$reset_color%}'


}

prompt_setup "$@"