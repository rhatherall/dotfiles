# modify the prompt to contain git branch name if applicable
git_prompt_info() {
  current_branch=$(git current-branch 2> /dev/null)
  if [[ -n $current_branch ]]; then
    echo " %{$fg_bold[green]%}$current_branch%{$reset_color%}"
  fi
}

# show the active Timewarrior tag if tracking is running
timew_prompt_info() {
  command -v timew > /dev/null 2>&1 || return
  local out tag
  out=$(timew 2> /dev/null)
  [[ $out == Tracking* ]] || return
  tag=${${out%%$'\n'*}#Tracking }
  tag=${tag//\"/}
  echo " %{$fg_bold[yellow]%}⏱ ${tag}%{$reset_color%}"
}

setopt promptsubst

# Allow exported PS1 variable to override default prompt.
if ! env | grep -q '^PS1='; then
  PS1='${SSH_CONNECTION+"%{$fg_bold[green]%}%n@%m:"}%{$fg_bold[blue]%}%c%{$reset_color%}$(git_prompt_info)$(timew_prompt_info) %# '
fi
