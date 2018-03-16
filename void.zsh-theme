ZSH_THEME_GIT_PROMPT_SHOW="${ZSH_THEME_GIT_PROMPT_SHOW=true}"
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_COLOR="red"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" ?"
ZSH_THEME_GIT_PROMPT_ADDED=" +"
ZSH_THEME_GIT_PROMPT_MODIFIED=" !"
ZSH_THEME_GIT_PROMPT_RENAMED=" »"
ZSH_THEME_GIT_PROMPT_DELETED=" ✘"
ZSH_THEME_GIT_PROMPT_STASHED=" $"
ZSH_THEME_GIT_PROMPT_UNMERGED=" ="
ZSH_THEME_GIT_PROMPT_AHEAD=" ⇡"
ZSH_THEME_GIT_PROMPT_BEHIND=" ⇣"
ZSH_THEME_GIT_PROMPT_DIVERGED=" ⇕"

function _git_time_since_commit() {
# Only proceed if there is actually a commit.
  if git log -1 > /dev/null 2>&1; then
    # Get the last commit.
    last_commit=$(git log --pretty=format:'%at' -1 2> /dev/null)
    now=$(date +%s)
    seconds_since_last_commit=$((now-last_commit))

    # Totals
    minutes=$((seconds_since_last_commit / 60))
    hours=$((seconds_since_last_commit/3600))

    # Sub-hours and sub-minutes
    days=$((seconds_since_last_commit / 86400))
    sub_hours=$((hours % 24))
    sub_minutes=$((minutes % 60))

    if [ $hours -gt 24 ]; then
      commit_age="${days}d"
    elif [ $minutes -gt 60 ]; then
      commit_age="${sub_hours}h${sub_minutes}m"
    else
      commit_age="${minutes}m"
    fi

    echo " $commit_age"
  fi
}

autoload -Uz colors && colors
autoload -Uz vcs_info
setopt prompt_subst

# set up exit_code
typeset -g void_exit_code
precmd_void_exit_code() { if (( $? == 0 )); then void_exit_code="blue"; else void_exit_code="red"; fi }

# handle vcs_info
precmd_vcs_info() { vcs_info  }
precmd_functions+=( precmd_vcs_info precmd_void_exit_code  )

export PS1='%{$fg[$void_exit_code]%}›%{$reset_color%} '
export RPROMPT='%{$fg[blue]%}$(basename $PWD)$vcs_info_msg_0_$(git_prompt_status)$(_git_time_since_commit)%{$reset_color%}'

# show git branch name
zstyle ':vcs_info:*:*' formats ' · %b'