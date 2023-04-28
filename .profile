
## 
## pathadd - add dir to path if not present
## 
## https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
## 
pathadd() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+$PATH:}$1"
  fi
}

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
#export PATH="$PATH:$HOME/.rvm/bin"
pathadd "${HOME}"/.rvm/bin
export PATH

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

[[ -z "${HOSTNAME}" ]] && export HOSTNAME="$(uname -n)"
[[ -z "${USER}" ]] && export USER="$(whoami)"

PS1="${USER}@${HOSTNAME%.*}$ "
export PS1

