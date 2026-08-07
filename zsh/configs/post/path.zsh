# ensure dotfiles bin directory is loaded first
PATH="$HOME/.bin:/usr/local/sbin:$PATH"

# asdf >=0.16 is a single Go binary with no asdf.sh to source — activation is
# just putting the shims directory on PATH.
if [ -d "${ASDF_DATA_DIR:-$HOME/.asdf}/shims" ]; then
  PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
fi

# mkdir .git/safe in the root of repositories you trust
PATH=".git/safe/../../bin:$PATH"

export -U PATH
