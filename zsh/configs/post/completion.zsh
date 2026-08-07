# load our own completion functions
fpath=(~/.zsh/completion /usr/local/share/zsh/site-functions $fpath)

# asdf >=0.16 ships no asdf.sh, so its completions are wired up via fpath;
# generate the script once, then expose the directory before compinit.
if command -v asdf >/dev/null; then
  _asdf_completions="${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
  if [[ ! -f "$_asdf_completions/_asdf" ]]; then
    mkdir -p "$_asdf_completions"
    asdf completion zsh > "$_asdf_completions/_asdf"
  fi
  fpath=("$_asdf_completions" $fpath)
  unset _asdf_completions
fi

# completion; use cache if updated within 24h
autoload -Uz compinit
if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
  compinit -d $HOME/.zcompdump;
else
  compinit -C;
fi;

# disable zsh bundled function mtools command mcd
# which causes a conflict.
compdef -d mcd
