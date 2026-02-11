# .zshrc, startup file for zsh; .bashrc, startup file for bash
# Author: Brian Snook
# Date:   2008-03-28
# Update: 2008-04-23 (fixed bug with multi-line commands in some awks)
# Update: 2008-04-23 (modified so all lines fit in 80-char terminal)
# Update: 2008-05-14 (updated name terminal (nt) default behaviour)
# Update: 2008-05-23 (added findbin)
# Update: 2022-10-07 (removed old accts/email; standardized zsh/bash)
# Update: 2022-10-10 (added Windows PATHs; findbin support for spaces)
# Update: 2022-10-11 (added pathadd and de-duplicating extant PATH)
# Update: 2022-12-08 (update: eciv, findbin, MANPATH)
# Update: 2022-12-08 (add: compdate, manpathadd, showfunc, is_interactive_shell)
# Update: 2022-12-13 (add: E_HOME to extend HOME per-user on shared accounts)
# Update: 2022-12-13 (update: rewrote findawk; use it to set AWK variable)
# Update: 2023-01-04 (add: m2l)
# Update: 2023-02-21 (add: convdate, fgg, recol)
# Update: 2023-03-15 (add: cdf, Google Chrome app functions for MacOS)
# Update: 2023-03-16 (add: show function for MacOS)
# Update: 2023-04-27 (add: jenv configurations)
# Update: 2023-04-28 (add: homebrew configs; improved jenv configs)
# Update: 2023-07-05 (add: hawk)
# Update: 2023-12-04 (add: b2i)
# Update: 2023-12-08 (update: removed redundancy: cppfd invokes pfd)
# Update: 2024-02-16 (update: hawk logic; show function for MacOS arguments)
# Update: 2024-05-30 (add: dka/kka to delete/kill ssh-key agents)
# Update: 2024-12-04 (update: most of file now inside is_interactive_shell test)
# 

# Example shell startup provided to get started
# Please modify to suit your needs.
#

## 
## Shared accounts present difficulties
## 
## It may be practical or desirable to maintain a separate environment using 
##   a temporary directory for per-user scratch work, file management, 
##   and shell initialization
## 
## Provide a mechanism to override the $HOME variable on a system as needed
##   for user-specific needs by setting an EFFECTIVE HOME ($E_HOME)
## 
## Only modify if needed; for instance: 
##   this file is not installed in the HOME directory of the login account
## 
## Items which could use HOME or E_HOME depending on usage in a shared account
##   (if modifying E_HOME, check that these match your desired usage)
##      Functions:
##        mka
##      Variables:
##        HISTFILE
## 
## 
E_HOME="${HOME}"
case "$(uname -n)" in
    ## Set a User-Specific Home (sub-)Directory per-host if needed
    ip-10-119*)
        USHD="tmp.bsnook"
        if [[ -d "${HOME}/${USHD}" ]]; then
            E_HOME="${HOME}/${USHD}"
            cde() { cd "${E_HOME}"; }
        fi
        ;;
    *)
        E_HOME="${HOME}" ;;
esac
export E_HOME

## 
## Configure how to reconcile shared-account and user-specific settings
## 
IMPORT_SHARED_SHELL_INIT="YES"
OVERRIDE_SHARED_VIMRC="YES"


## 
## NOTE on use of user-specific settings on shared accounts
##   If creating/using a "real-user"-specific directory on a shared account
##   users may automatically connect to their preferred directory by 
##   specifying it in the SSH config file (i.e., .ssh/config) on the 
##   host they connect FROM like this:
##     (replace LOCAL... and REMOTE... placeholders as appropriate)
##
##   ${LOCAL-HOME}/.ssh/config:
##    
##     Host REMOTE-SHARED-ACCOUNT-HOST
##       User REMOTE-SHARED-ACCOUNT-USERNAME
##       HostName 11.22.33.44
##       IdentityFile ~/.ssh/your-shared-account.pem
##       ServerAliveInterval 120
##       ServerAliveCountMax 30
##       ForwardAgent yes
##       MACs hmac-sha2-512
##       RemoteCommand cd tmp.YOUR_NAME && bash --rcfile .bashrc
##       RequestTTY yes
## 
## NOTE: you will still need to specify your user-specific directory as part 
##   of the target in scp to avoid clobbering shared files ; for instance:
## 
##       scp   local-file.ext   REMOTE-SHARED-ACCOUNT-HOST:tmp.YOUR_NAME/
## 


##
## STARTUP FILE
##
## Define the startup file (this file) for use later
##
if [[ "$0" =~ "zsh" ]]; then
    SHELL_STARTUP=".zshrc"
    SHELL_STARTUP_FPATH="${E_HOME}/.zshrc"
elif [[ "$0" =~ "bash" ]]; then
    SHELL_STARTUP=".bashrc"
    SHELL_STARTUP_FPATH="${E_HOME}/.bashrc"
fi
export SHELL_STARTUP SHELL_STARTUP_FPATH


## 
## Detect whether we have overridden the default shell initialization
## and either import or ignore the account default one based on settings above
## 
if [[ "x${IMPORT_SHARED_SHELL_INIT}" == "xYES" ]]; then
    #if [[ "x${HOME}/${SHELL_STARTUP}" != "x${E_HOME}/${SHELL_STARTUP}" ]]; then
    if  [[ "x${HOME}" != "x${E_HOME}" ]] && 
        [[ -f "${HOME}/${SHELL_STARTUP}" ]]; then
        if [[ is_interactive_shell ]]; then
            sed -e 's/^/INFO: /' << EOF
The current "${SHELL_STARTUP}" is outside the login account home dir
    Sourcing
        "${HOME}/${SHELL_STARTUP}"

    before processing the rest of 
        "${E_HOME}/${SHELL_STARTUP}"

    to define shared-account variables and functions

EOF
        fi
        source "${HOME}/${SHELL_STARTUP}"
    fi
fi


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
pathadd_right() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+$PATH:}$1"
  fi
}
pathadd_left() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+:$PATH}"
  fi
}

## 
## PATH - Windows PATH prefixes (e.g., for git bash)
## 
CWINDOWS="/c/Windows"
WPF="/c/Program Files"
WPF64="/c/Program Files (x86)"
UALP="$HOME/AppData/Local/Programs"

##
## PATH
##
## Instead of just clobbering our PATH with directories that may 
## not be appropriate for this server, try to be intelligent about what we add
## First, tidy up the extant PATH to remove any duplicates
## 
## NOTE: zsh "typeset -U path" will remove redundant PATH entries 
##   but does not verify directories actually exist
##
OLDPATH="${PATH}"
NEWPATH=
while [[ ${#OLDPATH} -gt 0 ]]; do
    adir="${OLDPATH%%:*}"
    OLDPATH="${OLDPATH:${#adir}+1}"
    if [[ -d "${adir}" ]] && [[ ":$NEWPATH:" != *":$adir:"* ]]; then
        NEWPATH="${NEWPATH:+$NEWPATH:}$adir"
    fi
done
## 
## Only replace PATH if the replacement is at least as long as "/bin"
## 
[[ ${#NEWPATH} -ge 4 ]] && PATH="${NEWPATH}"
## 
## Check what other directories may be appropriate and add any found
## 
TPD=/usr/local/sbin                             && pathadd "${TPD}"
TPD=/usr/local/bin                              && pathadd "${TPD}"
TPD=/usr/sbin                                   && pathadd "${TPD}"
TPD=/usr/bin                                    && pathadd "${TPD}"
TPD=/sbin                                       && pathadd "${TPD}"
TPD=/bin                                        && pathadd "${TPD}"
TPD="${HOME}"/anaconda3/bin                     && pathadd "${TPD}"
TPD=/usr/ucb                                    && pathadd "${TPD}"
TPD=/usr/ccs/bin                                && pathadd "${TPD}"
TPD=/usr/local/ssl/bin                          && pathadd "${TPD}"
TPD=/usr/krb5/bin                               && pathadd "${TPD}"
TPD=/usr/krb5/sbin                              && pathadd "${TPD}"
TPD=/usr/kerberos/sbin                          && pathadd "${TPD}"
TPD=/usr/kerberos/bin                           && pathadd "${TPD}"
#TPD=/usr/java/jre1.5.0_02/bin                   && pathadd "${TPD}"
#TPD=/usr/java1.2/bin                            && pathadd "${TPD}"
TPD=/usr/perl5/bin                              && pathadd "${TPD}"
TPD=/usr/X11R6/bin                              && pathadd "${TPD}"
TPD=/etc/X11                                    && pathadd "${TPD}"
TPD=/opt/sfw/bin                                && pathadd "${TPD}"
TPD=/usr/local/apache/bin                       && pathadd "${TPD}"
TPD=/usr/apache/bin                             && pathadd "${TPD}"
TPD=/usr/openwin/bin                            && pathadd "${TPD}"
TPD=/usr/xpg4/bin                               && pathadd "${TPD}"
TPD=/usr/dt/bin                                 && pathadd "${TPD}"
TPD=/opt/google/chrome                          && pathadd "${TPD}"
TPD=/Applications/Bluefish.app/Contents/MacOS   && pathadd "${TPD}"
TPD="/Applications/Visual Studio Code.app/Contents/Resources/app/bin" \
    && pathadd "${TPD}"
TPD="${HOME}"/Library/Python/3.8/bin            && pathadd "${TPD}"
TPD=/usr/local/opt/qt@5/bin                     && pathadd "${TPD}"
TPD=/usr/local/Cellar/qt@5/5.15.3/bin           && pathadd "${TPD}"
TPD=/usr/local/go/bin                           && pathadd "${TPD}"
TPD="/c/OpenSSH-Win64"                          && pathadd "${TPD}"
TPD="${CWINDOWS}"                               && pathadd "${TPD}"
TPD="${WPF}"/Git/bin                            && pathadd "${TPD}"
TPD="${WPF64}"/Git/bin                          && pathadd "${TPD}"
TPD="${UALP}"/"Microsoft VS Code"/bin           && pathadd "${TPD}"
TPD="${UALP}"/"Microsoft VS Code"               && pathadd "${TPD}"
TPD="${HOME}/AppData/Local/GnuWin32/bin/gawk"   && pathadd "${TPD}"
TPD="${WPF}"/Google/Chrome/Application          && pathadd "${TPD}"
TPD="${HOME}/local/aws-cli"                     && pathadd "${TPD}"
TPD="${HOME}/local/bin"                         && pathadd "${TPD}"
TPD="${HOME}/local"                             && pathadd "${TPD}"
TPD="${HOME}/.local/bin"                        && pathadd "${TPD}"
TPD="${HOME}/bin"                               && pathadd "${TPD}"
TPD="${HOME}/google-cloud-sdk/bin"              && pathadd "${TPD}"
TPD="${E_HOME}/.local/bin"                      && pathadd "${TPD}"
TPD="${E_HOME}/bin"                             && pathadd "${TPD}"
TPD="${E_HOME}/scripts"                         && pathadd "${TPD}"
TPD="/Applications/SQLDeveloper.app/Contents/MacOS" && pathadd "${TPD}"
TPD="${E_HOME}/.docker/bin"                     && pathadd "${TPD}"
# Add RVM to the PATH last for Ruby scripting
TPD="${HOME}/.rvm/bin"                          && pathadd "${TPD}"
export PATH

## 
## manpathadd - add dir to manpath if not present
## 
## https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
## 
manpathadd() {
    if [[ -d "$1" ]] && [[ ":$MANPATH:" != *":$1:"* ]]; then
        MANPATH="${MANPATH:+$MANPATH:}$1"
    fi
}
manpathadd_right() {
    if [[ -d "$1" ]] && [[ ":$MANPATH:" != *":$1:"* ]]; then
        MANPATH="${MANPATH:+$MANPATH:}$1"
    fi
}
manpathadd_left() {
    if [[ -d "$1" ]] && [[ ":$MANPATH:" != *":$1:"* ]]; then
        MANPATH="$1${MANPATH:+:$MANPATH}"
    fi
}

##
## MANPATH
##
## Instead of just clobbering our MANPATH with directories that may 
## not be appropriate for this server, try to be intelligent about what we add
## First, tidy up the extant MANPATH to remove any duplicates
##
OLDMANPATH="${MANPATH}"
NEWMANPATH=
while [[ ${#OLDMANPATH} -gt 0 ]]; do
    adir="${OLDMANPATH%%:*}"
    OLDMANPATH="${OLDMANPATH:${#adir}+1}"
    if [[ -d "${adir}" ]] && [[ ":$NEWMANPATH:" != *":$adir:"* ]]; then
        NEWMANPATH="${NEWMANPATH:+$NEWMANPATH:}$adir"
    fi
done
## 
## Only replace MANPATH if the replacement is at least as long as "/man"
## 
[[ ${#NEWMANPATH} -ge 4 ]] && MANPATH="${NEWMANPATH}"
##
## MANPATH
##
## Instead of just clobbering our MANPATH with directories that may 
## not be appropriate for this system, try to be intelligent about what we add
##
## Old way of doing it (pre-function):
##   MANPATH=
##   MANPD=/usr/local/man   && [ -d "$MANPD" ] && MANPATH="$MANPATH:$MANPD"
##      (NOTE: really should have been MANPATH="${MANPATH:+$MANPATH:}$MANPD")
## New way of doing it (with function that checks dir validity and uniqueness):
##   MANPD=/usr/local/man   && manpathadd "${MANPD}"
## 
MANPD=/usr/local/man                   && manpathadd "${MANPD}"
MANPD=/usr/share/man                   && manpathadd "${MANPD}"
MANPD=/usr/local/share/man             && manpathadd "${MANPD}"
MANPD=/usr/man                         && manpathadd "${MANPD}"
MANPD=/usr/krb5/man                    && manpathadd "${MANPD}"
MANPD=/usr/kerberos/man                && manpathadd "${MANPD}"
MANPD=/usr/local/ssl/man               && manpathadd "${MANPD}"
MANPD=/usr/java/jre1.5.0_02/man        && manpathadd "${MANPD}"
MANPD=/usr/java1.2/man                 && manpathadd "${MANPD}"
MANPD=/usr/X11R6/man                   && manpathadd "${MANPD}"
MANPD=/usr/local/apache/man            && manpathadd "${MANPD}"
MANPD=/usr/local/mysql/man             && manpathadd "${MANPD}"
MANPD=/usr/perl5/man                   && manpathadd "${MANPD}"
MANPD=/usr/local/perl/man              && manpathadd "${MANPD}"
MANPD=/usr/local/perl5.8.0/man         && manpathadd "${MANPD}"
MANPD=/usr/openwin/man                 && manpathadd "${MANPD}"
MANPD=/opt/java/openjdk/man            && manpathadd "${MANPD}"
export MANPATH

## 
## INFOPATH
## 
for each_possible in \
    /usr/local/share/info \
    /usr/share/info
do
    if [[ -d "${each_possible}" ]] && [[ ":${INFOPATH}:" != *":${each_possible}:"* ]]; then
        INFOPATH="${each_possible}${INFOPATH:+:$INFOPATH}"
    fi
done
export INFOPATH

##
## PROMPT
##
## Zsh can use 'PS1' as well as 'PROMPT'
## Zsh can use 'RPS1' as a right-margin prompt for additional info
##   NOTE: the right-hand prompt will disappear as you type near it
##
#PS1="%B%n%b{%m}%B%~%b%# "
#RPS1="%(?..[%?])"
## Right-hand prompt with current/present working directory:
#RPS1="%~"
##
## A basic prompt with BOLD characters (bold username and current directory)
##
#PROMPT="%B%n%b@%m:%B%~%b%# "
##
## A basic prompt with non-bold characters
##   NOTE:  "%#" is zsh syntax for '%' for non-root user, '#' for root user
##          PROMPT will appear (non-root) as:  "username@server:PWD% "
##
#PROMPT="%n@%m:%~%# "
##
## Set your current prompt
##
## [[ $0 =~ "zsh" ]]       && PROMPT="%n@%m:%~%# " && export PROMPT
## [[ $0 =~ "bash" ]]      && PS1="\u@\h:\W\$ "    && export PS1
##
## NOTE: Set a Fancy Prompt or Set a Simple Prompt when needed
##   (i.e., before using "script" to capture output to avoid control chars)
##
if [[ $0 =~ "zsh" ]]; then
    # Basic PROMPT
    #PROMPT="%n@%m:%~%# " && export PROMPT
    # Set Simple Prompt
    ssp() { 
        case "$(uname -n)" in 
            ATL*)
                PS1="%n@laptop:%~%# " ;;
            *)
                PS1="%n@%m:%~%# " ;;
        esac
        export PS1
    }
    # Set Fancy Prompt
    sfp() { 
        setopt PROMPT_SUBST
        case "$(uname -n)" in 
            ATL*)
                PS1="%n@laptop:%B\$(parse_git_toplevel)%b\$(parse_git_branch):%~%B%#%b " ;;
            *)
                PS1="%n@%m:%B\$(parse_git_toplevel)%b\$(parse_git_branch):%~%B%#%b " ;;
        esac
        export PS1
    }
fi
if [[ $0 =~ "bash" ]]; then
    #PS1="\u@\h:\W\$ "    && export PS1
    # Set Simple Prompt
    ssp() { 
        PS1="\u@\h:\W\$ "
        export PS1
    }
    # Set Fancy Prompt
    sfp() { 
        #PS1="\u@\h \[\033[32m\]\W\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\$ "
        PS1="\u@\h:\[\033[32m\]\W\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\$ "
        export PS1
    }
fi
## Simple
ssp
## Fancy
#sfp


## 
## Detect whether we are bypassing the default account HOME for settings
## Override shared-account .vimrc if a user-specific one exists
## 
## NOTES: useful .vimrc settings are either "number" or "nonumber" and "paste"
##     set nonumber
##     set paste
##     set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
## 
if [[ "x${OVERRIDE_SHARED_VIMRC}" == "xYES" ]]; then
    if [[ "x${HOME}" != "x${E_HOME}" ]] && [[ -f "${E_HOME}/.vimrc" ]]; then
        [[ `which vi`  ]]  &&  alias vi="vi -u \"${E_HOME}/.vimrc\""
        [[ `which vim` ]]  &&  alias vim="vim -u \"${E_HOME}/.vimrc\""
        [[ `which view` ]] &&  alias view="view -u \"${E_HOME}/.vimrc\""
    fi
fi

##
## SSH-agent
##
if [[ -e "${E_HOME}"/.agent ]]; then source "${E_HOME}"/.agent; fi
mka() { 
    ssh-agent -s > "${E_HOME}"/.agent && \
    source "${E_HOME}"/.agent && \
    ssh-add; 
}
rka() {
    source "${E_HOME}"/.agent;
}
## Remove ("delete" or "kill") agent (accommodate both for choice/memory)
dka() {
    ssh-agent -k
    rm ${E_HOME}/.agent 2>/dev/null
}
kka() {
    ssh-agent -k
    rm ${E_HOME}/.agent 2>/dev/null
}

## 
## Local environment and SSH connection functions
## 
gojup() { 
    cd "${HOME}"/Documents/GitHub/Pierian-Data-Complete-Python-3-Bootcamp \
        && { jupyter-notebook &  jupyter-lab & } ;
}
gok8() { 
    #ssh k8bastion -t bash --rcfile tmp.bsnook/.bashrc -c "cd tmp.bsnook"; 
    ssh k8bastion; 
}
## tunnel VNC over SSH
TUNYUSER="bsnook"
TUNYHOST="10.0.0.22"
tuny() { 
    ssh -o ServerAliveCountMax=60 \
        -o ServerAliveInterval=90 \
        -L 127.0.0.1:5901:${TUNYHOST}:5901 \
        -p 22000 ${TUNYUSER}@${TUNYHOST}; 
}

##
## Aliases
##
## Set up aliases
##
#alias titleme='print -Pn "\e]0;%n@%m: %~\a"'
#alias mv='nocorrect mv'       # no spelling correction on mv
#alias cp='nocorrect cp'       # no spelling correction on cp
#alias mkdir='nocorrect mkdir' # no spelling correction on mkdir
#alias which='type -f'
alias ll="ls -al"

cacert=""
winca="${HOME}/Documents/Keyz/Certs/Node_CA.pem"
macca="${HOME}/Keyz/Certs/Node_CA.pem"
if [[ -f "${winca}" ]]; then
    cacert="${winca}"
elif [[ -f "${macca}" ]]; then
    cacert="${macca}"
fi
mycurl=$(which curl) && [[ -f "${cacert}" ]] && \
    alias curl="\"${mycurl}\" --cacert \"${cacert}\" \$@"


##
## Find Awk (or Nawk or Gawk)
##   Prefer `gawk` over `nawk` over `awk`
##   Default output shows all versions found and their real paths
##   Using the argument "-q" (quiet) will suppress all but the final choice
##
findawk() {
    ## Optionally set default verbosity to be overridden with flags
    VERBOSE_FA_TMP=
    if [[ "x${1}" == "x-q" ]]; then
        VERBOSE_FA_TMP=false
    fi
    if [[ "x${1}" == "x-v" ]]; then
        VERBOSE_FA_TMP=true
    fi

    ## Try to be sane and not search the entire PATH
    ## Search a reasonable (trusted) subset for possible versions of awk
    AWKSEARCH=
    awksearchadd() {
      if [[ -d "$1" ]] && [[ ":$AWKSEARCH:" != *":$1:"* ]]; then
        AWKSEARCH="${AWKSEARCH:+$AWKSEARCH:}$1"
      fi 
    }
    TASP=/bin                   && awksearchadd "${TASP}"
    TASP=/usr/bin               && awksearchadd "${TASP}"
    TASP=/usr/local/bin         && awksearchadd "${TASP}"
    TASP="${HOME}/homebrew/bin" && awksearchadd "${TASP}"

    for AWK_VER in awk nawk gawk; do
        AWKSEARCHPATH="${AWKSEARCH}"
        while [[ ${#AWKSEARCHPATH} -gt 0 ]]; do
            EACH_SEARCH_DIR="${AWKSEARCHPATH%%:*}"
            AWKSEARCHPATH="${AWKSEARCHPATH:${#EACH_SEARCH_DIR}+1}"
            AWKPATH="${EACH_SEARCH_DIR}/${AWK_VER}"
            if [[ -f "${AWKPATH}" ]]; then
                if [[ "$(uname)" =~ "BSD" ]]; then
                    REAL_AWKPATH="$(stat -f "%Y" "${AWKPATH}")"
                else
                    REAL_AWKPATH="$(readlink -f "${AWKPATH}")"
                fi
                AWK="${REAL_AWKPATH}"
                if ${VERBOSE_FA_TMP}; then
                    if [[ "x${AWKPATH}" == "x${REAL_AWKPATH}" ]]; then
                        ls -il "${AWKPATH}"
                    else
                        ls -il "${AWKPATH}"
                        echo "    \"${AWKPATH}\" => \"${REAL_AWKPATH}\""
                    fi
                fi
            fi
        done
    done
    echo "AWK=\"${AWK}\""
}
eval $( findawk -q )
export AWK


##
## USER
##
## When using shared screen sessions and changing to another user, 
## environment variable $USER gets clobbered.  Fix it.
## NOTE:  "id -un" does not work everywhere (i.e., Solaris 8 default)
##
## Extract the username from `id` output - TIMTOWTDI
#if [ "x${USER}" = "x" ]; then USER=`id | cut -d \) -f1 | cut -d \( -f2`; fi
if [[ "x${USER}" = "x" ]]; then USER=$(id | ${AWK} -F'[)(]' '{print $2}'); fi
export USER


##
## UMASK
##
### if [ `id -gn` = `id -un` -a `id -u` -gt 14 ]; then
###         umask 002
### else
###         umask 022
### fi
##
umask 022


##
## FUNCTIONS (define useful utilities)
##
is_interactive_shell() {
    [[ "$-" =~ "i" ]]
}


## Most of this file should only be run for interactive shells
if [[ is_interactive_shell ]]; then
    echo "INFO: \"showfuncs\" lists functions from \"${SHELL_STARTUP_FPATH}\""


##
## Find all instances of a Binary or Script in PATH
##
findbin_oldest() {
  echo ${PATH} | ${AWK} -F: -v TARGET=$1 '
  {
    for (i=1; i<=NF; i++) {
      cmd=sprintf("if [ -f %s/%s ]; then echo %s/%s; fi",$i,TARGET,$i,TARGET)
      system(cmd)
    }
  }'
}

findbin_old() {
  echo ${PATH} | ${AWK} -F: -v TARGET="$1" '
  {
    for (i=1; i<=NF; i++) {
      cmd=sprintf("if [ -f \"%s/%s\" ]; then echo %s/%s; fi",$i,TARGET,$i,TARGET)
      system(cmd)
    }
  }'
}

findbin() {
  if [[ ${#} -ge 1 ]]; then
    #echo "More than one argument: \$# = $#"
    if [[ "${1}" == "-l" ]] && [[ ${#} -ge 2 ]] ; then
      FB_LONG=1
      shift
    fi
    for item in "${@}"; do
      echo "${PATH}" | ${AWK} -F: -v TARGET="${item}" -v FB_LONG="${FB_LONG}" '
      {
        for (i=1; i<=NF; i++) {
          if (FB_LONG) {
            #cmd=sprintf("if [ -f \"%s/%s\" ]; then ls -l \"%s/%s\"; fi",$i,TARGET,$i,TARGET)
            cmd=sprintf("[[ -f \"%s/%s\" ]] && ls -l \"%s/%s\"",$i,TARGET,$i,TARGET)
          } else {
            #cmd=sprintf("if [ -f \"%s/%s\" ]; then echo \"%s/%s\"; fi",$i,TARGET,$i,TARGET)
            cmd=sprintf("[[ -f \"%s/%s\" ]] && echo \"%s/%s\"",$i,TARGET,$i,TARGET)
          }
          system(cmd)
        }
      }'
    done
    unset FB_LONG
  fi
}

## Show Functions
##
## Use [[:alnum:]] instead of [A-Za-z0-9] to include characters like "á"
## " {0,}" matches zero or more spaces between function name and parentheses
## 
## NOTE: SHELL_STARTUP_FPATH now includes the EFFECTIVE HOME variable E_HOME 
##   path to ease management of user-specific settings on shared accounts
## 
showfuncs() { 
    ${AWK} '/^[[:space:]]*[[:alnum:]_-]+ *\( *\)/{gsub("\\("," ");print $1}' \
    "${SHELL_STARTUP_FPATH}" | sort -u; 
}
## 
## Showfunc displays the definition of a function by parsing the init file
## Single-line functions break it
## "which [function]" in zsh and "type [function]" in bash do the same thing
## It is still an interesting regex exercise in awk
## 
showfunc() {
    ${AWK} -v FUNC="${1}" '
        function if_equal_braces(line) {
            ## gensub only works in gawk; be more portable
            #left=gensub("[^{]*","","g",$0); 
            #right=gensub("[^}]*","","g",$0); 
            left=$0
            gsub(/[^{]/,"",left)
            right=$0
            gsub(/[^}]/,"",right)
            if (length(left) > 0 && length(left) == length(right)) {
                return 1
            } else {
                return 0
            }
        }
        $0 ~ "^"FUNC" *\\(" && if_equal_braces($0) { print; exit }
        $0 ~ "^"FUNC" *\\(", /(^#|^}|^$)/ 
    ' "${SHELL_STARTUP_FPATH}"
}


## Site-specific example extracting stanza from a file with awk regex
## 
## Print the current passwd module info (path, version) from sysadmin/modules
## Assumes your CVS scratch space has been set up as "$HOME/cvs.saroot"
##   and stanzas are delimited by blank lines
##
awkpass() { 
  ${AWK} '/^\[(gate|)passwd-all(|-qe)\]/,/^$/' ~/cvs.saroot/sysadmin/modules; 
}

## 
## Query ARIN (American Registry for Internet Numbers) for whois info on IPs
##
if [[ $( command -v whois ) ]]; then
    awhois() { whois -h whois.arin.net ${1}; }
    swhois() { whois ${1} | awk '
        /^>>>/{exit}
        /Domain (Name|ID)|WHOIS Server|Registrar:|Expir|(Updated|Creation) Date/{print}'; }
fi

##
## Use OpenSSL to get the beginning and end dates of a secure certificate
##
## 
## A programmatic way of doing this:
## 
##     for i in host1 host2; do printf "=====\n%s\n=====\n" ${i}; \
##          printf "\n\n" | openssl s_client -connect ${i}:443 2>/dev/null | \
##          openssl x509 -noout -startdate -enddate; echo; done
##  OR
##     for i in host1 host2; do printf "=====\n%s\n=====\n" ${i}; \
##          printf "\n\n" | openssl s_client -connect ${i}:443 2>/dev/null | \
##          openssl x509 -noout -dates;  echo; done
## 
certdate() {
  which openssl
  result=$?
  if [[ ${result} != 0 ]]
    then
      echo "Could not find \"openssl\" in current path."
      echo "Update your path, install openssl, or run elsewhere."
      return ${result}
  fi
  echo $1 | ${AWK} -F: '
    $1==""{site="localhost"}
    $1!=""{site=$1}
    $2==""{port="443"}
    $2!=""{port=$2}
    {
      if (( $1 != "" ) || ( $2 != "")) {
        c_intro=sprintf("echo quit |")
        c_fetch=sprintf("openssl s_client -connect %s:%s",site,port)
        c_redir=sprintf("2>/dev/null")
        c_print=sprintf("| openssl x509")
        o_print=sprintf("-noout -startdate -enddate")
        cmd=sprintf("%s %s %s %s %s\n",c_intro,c_fetch,c_redir,c_print,o_print)
        system(cmd)
      } else {
        print "USAGE: "
        print "    certdate [site][:[port]]"
        print ""
        print "  Please include at least one; if left blank:"
        print "    \"site\" defaults to \"localhost\""
        print "    \"port\" defaults to \"443\""
        print ""
      }
    }'
}

certinfo() {
  which openssl
  result=$?
  if [[ ${result} != 0 ]]
    then
      echo "Could not find \"openssl\" in current path."
      echo "Update your path, install openssl, or run elsewhere."
      return ${result}
  fi
  echo $1 | ${AWK} -F: '
    $1==""{site="localhost"}
    $1!=""{site=$1}
    $2==""{port="443"}
    $2!=""{port=$2}
    {
      if (( $1 != "" ) || ( $2 != "")) {
        c_intro=sprintf("echo quit |")
        c_fetch=sprintf("openssl s_client -connect %s:%s",site,port)
        c_redir=sprintf("2>/dev/null")
        c_print=sprintf("| openssl x509 -noout ")
        o_print=sprintf("-issuer -startdate -enddate -subject -fingerprint")
        cmd=sprintf("%s %s %s %s %s",c_intro,c_fetch,c_redir,c_print,o_print)
        system(cmd)
      } else {
        print "USAGE: "
        print "    certinfo [site][:[port]]"
        print ""
        print "  Please include at least one; if left blank:"
        print "    \"site\" defaults to \"localhost\""
        print "    \"port\" defaults to \"443\""
        print ""
      }
    }'
}

eci() {
  which openssl
  result=$?
  if [[ ${result} != 0 ]]
    then
      echo "Could not find \"openssl\" in current path."
      echo "Update your path, install openssl, or run elsewhere."
      return ${result}
  fi
  for each_site in "$@"; do
  printf "## QUERY site \"%s\"\n" ${each_site}
  echo "${each_site}" | ${AWK} -F: '
    $1==""{site="localhost"}
    $1!=""{site=$1}
    $2==""{port="443"}
    $2!=""{port=$2}
    {
      if (( $1 != "" ) || ( $2 != "")) {
        c_intro=sprintf("echo quit |")
        c_fetch=sprintf("openssl s_client -connect %s:%s",site,port)
        c_redir=sprintf("2>/dev/null")
        c_print=sprintf("| openssl x509 -noout ")
        o_print=sprintf("-subject -issuer -startdate -enddate -fingerprint")
        o_print=sprintf("%s -serial -alias -ext subjectAltName",o_print)
        cmd=sprintf("%s %s %s %s %s",c_intro,c_fetch,c_redir,c_print,o_print)
        system(cmd)
      } else {
        print "USAGE: "
        print "    certinfo [site][:[port]]"
        print ""
        print "  Please include at least one; if left blank:"
        print "    \"site\" defaults to \"localhost\""
        print "    \"port\" defaults to \"443\""
        print ""
      }
    }'
  done
}

eciv() {
  which openssl 2>/dev/null
  result=$?
  if [[ ${result} != 0 ]]
    then
      echo "Could not find \"openssl\" in current path."
      echo "Update your path, install openssl, or run elsewhere."
      return ${result}
    else
      [[ "$(openssl version 2>/dev/null | egrep -o '[0-9]+(\.[0-9]+)*' | head -1)" > 1.0.99 ]] && \
        querySAN=1 || \
        querySAN=0
  fi
  for each_site in "$@"; do
  printf "## QUERY site \"%s\"\n" ${each_site}
  echo "${each_site}" | ${AWK} -F: -v querySAN=${querySAN} '
    $1==""{site="localhost"}
    $1!=""{site=$1}
    $2==""{port="443"}
    $2!=""{port=$2}
    {
      if (( $1 != "" ) || ( $2 != "")) {
        c_intro=sprintf("echo quit |")
        c_fetch=sprintf("openssl s_client -connect %s:%s",site,port)
        c_redir=sprintf("2>/dev/null")
        c_print=sprintf("| openssl x509 -noout ")
        o_print=sprintf("-subject -issuer -startdate -enddate -fingerprint")
        o_print=sprintf("%s -serial -alias",o_print)
        if (querySAN) {
          o_print=sprintf("%s -ext subjectAltName",o_print)
        }
        cmd=sprintf("%s %s %s %s %s",c_intro,c_fetch,c_redir,c_print,o_print)
        printf("%s\n",cmd)
        system(cmd)
      } else {
        print "USAGE: "
        print "    certinfo [site][:[port]]"
        print ""
        print "  Please include at least one; if left blank:"
        print "    \"site\" defaults to \"localhost\""
        print "    \"port\" defaults to \"443\""
        print ""
      }
    }'
  done
}

## 
## Count the number of logins each current user has on system
##
countu() { 
  w | ${AWK} '/^[a-z]/{
        users[$1]++
      }END{
        for(each in users){printf "%s\t%s\n",users[each],each}
      }' | sort -n 
}

## 
## Convert a binary string to an integer string
## 
b2i() { 
    conv_b2i() { ${AWK} '{l=split($1,b,"");for (i=1;i<=l;i++){d=(2*d)+b[i]};print d;d=0}' ; }
    ( [[ -f "$1" ]] && conv_b2i < "$1" ) || \
    ( [[ $# -gt 0 ]] && echo "$@" | conv_b2i ) || \
    conv_b2i
}

## Return the length of the longest line in a file/stream
len0() { ${AWK} 'length()>max{max=length()}END{print max}' $1; }
len2() { 
    [[ -f "$1" ]] && ${AWK} 'length()>max{max=length()}END{print max}' "$1" ||\
        echo "$1" | ${AWK} 'length()>max{max=length()}END{print max}'
}
len3() { 
    [[ -f "$1" ]] && ${AWK} 'length()>max{max=length()}END{print max}' "$1" || \
    ( [[ $# -gt 0 ]] && echo "$@" | 
        ${AWK} 'length()>max{max=length()}END{print max}' ) || \
    ${AWK} 'length()>max{max=length()}END{print max}';
}
len() { 
    get_len() { ${AWK} 'length()>max{max=length()}END{print max}' ; }
    ( [[ -f "$1" ]] && get_len < "$1" ) || \
    ( [[ $# -gt 0 ]] && echo "$@" | get_len ) || \
    get_len; 
}

## Merge every other line (merge odd line and following even line)
m2l() { 
    [[ -f "$1" ]] && ${AWK} 'NR%2{printf $0" "; if(getline){print}else{print ""}}' "$1" || \
    ( [[ $# -gt 0 ]] && echo "$@" | 
        ${AWK} 'NR%2{printf $0" "; if(getline){print}else{print ""}}' ) || \
    ${AWK} 'NR%2{printf $0" "; if(getline){print}else{print ""}}';
}

## "Header" awk -- print the header line and lines matching the specified pattern
hawk() {
    ( [[ $# -gt 1 ]] && \
        ( PATT="$1" && shift && ( \
            for each_arg in "$@"; do
                if [[ -f "${each_arg}" ]]; then
                    #echo "DEBUG: Arg \"${each_arg}\" is a file"
                    ${AWK} -v PATT="${PATT}" 'NR == 1 || $0 ~ PATT' "${each_arg}"
                else
                    2> printf "WARN: Argument \"${each_arg}\" is NOT a file; skipping\n"
                fi
                #echo
            done
            )
        ) 
    ) || \
    ( [[ $# -eq 1 ]] && \
        ( 2> printf "INFO: No files passed: scanning stdin for pattern \"$1\"\n";
            PATT="$1" && ${AWK} -v PATT="${PATT}" 'NR == 1 || $0 ~ PATT' ) 
    ) || \
    ( printf "You did not enter enough arguments: "
        printf "  Found %s argument but need: \n" "$#"
        printf "    1 argument: pattern and piped input\n"
        printf "      cat FILE | ${0} PATTERN\n"
        printf "  or \n"
        printf "    2 arguments: pattern and filename(s):\n"
        printf "      ${0} PATTERN FILE1 [FILE2 [FILE3 […]]]\n"
    )
}

## 
## Name a terminal ("echo -ne" also works instead of "print -Pn")
##
#nt() { print -Pn "\e]0;$1 - %y\a"; }          ## Name Term (nt)
nto() { 
    if [[ "x${1}" != "x" ]]
      then
      print -Pn "\e]0;$1 - %m\[$$\]\[%l\]\a"
    else
      print -Pn "\e]0;%n@%m($$) - %l\a"
    fi
} ## /Name Term (nt)

nt() { 
    if [[ "x${1}" != "x" ]]; then
      echo -ne "\e]0;$1 - $(uname -n)[$$][${0}]\a"
    else
      echo -ne "\e]0;${USER}@$(uname -n)($$) - ${0}\a"
    fi
} ## Name Term (nt)



## 
## Git Stuff
## 
alias gp='git pull'
## 
## Git Diff
##   diff the most recent commits
## 
gdiff() { git log $1 | \
    ${AWK} -v FN="$1" '/commit/{cmd=sprintf("%s %s",$2,cmd);\
        count++;if(count>=2){exit}}
        END{cmd=sprintf("git diff %s %s",cmd,FN);
        print cmd; system(cmd);close(cmd)}'; 
}
parse_git_branch() {
    #git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    git rev-parse --abbrev-ref HEAD 2>/dev/null | sed -e 's/\(.*\)/(\1)/'
}
parse_git_toplevel() {
    #basename $(git rev-parse --show-toplevel 2> /dev/null) | sed '/[^$]/s/\(.*\)/\[\1\]::/'
    GTL=$(git rev-parse --show-toplevel 2> /dev/null)
    if [[ "x${GTL}" != "x" ]]; then
        basename "${GTL}" | sed '/[^$]/s/\(.*\)/\[\1\]/'
    else 
        printf ""
    fi
}
## 
## Find Git Grep (egrep) - fgg
##   alias to exclude certain files/directories
## 
fgg() {
  find . -type f \
  -not \( -name "*.pack" -o -name "*.idx" \) \
  -not \( -path ./.git -prune \) \
  -exec egrep "${@}" {} \;
}


##
## Color 'ls' (optional)
##
UNAMES=`uname -s`
TERM=vt220
if [[ $UNAMES = "Linux" ]]; then
    if [[ is_interactive_shell ]]; then
        alias ls='ls --color' && \
        echo "INFO: 'ls' == 'ls --color' -- type 'unalias ls' to disable"
    fi
elif [[ $UNAMES = "OSF1" ]]; then
    export TERM=vt100
elif [[ $UNAMES = "FreeBSD" ]]; then
    export TERM=vt100
elif [[ $UNAMES = "BSDI" ]]; then
    export TERM=vt100
elif [[ "$UNAMES" =~ "MINGW" ]]; then 
    export TERM=xterm
fi
export TERM


## Set OS-specific Clipboard Copy command
## 
## MacOS - pbcopy/pbpaste
## 
#https://medium.com/@codenameyau/how-to-copy-and-paste-in-terminal-c88098b5840d
##   COPY:
##     pbcopy
##   PASTE:
##     pbpaste
## 
## Windows - DOS clip or PowerShell Get-Clipboard/Set-Clipboard
## 
#https://stackoverflow.com/questions/17819814/how-can-you-get-the-clipboard-contents-with-a-windows-command
#https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-clipboard?view=powershell-7.3
## In DOS (copy):
##   clip < file.txt
## In PowerShell (copy):
##   Get-Content C:\Users\user1\.ssh\id_ed25519.pub | Set-Clipboard
##   # Does this work?
##   Set-Clipboard -Value < file.txt
## In PowerShell (paste):
##   Get-Clipboard > myfile.txt
## 
## Linux - xclip or xsel
## Linux version of OSX pbcopy and pbpaste - xclip
#https://www.funoracleapps.com/2021/05/how-to-use-xclip-in-linux-for-clipboard.html
##   COPY:
##     xclip -i -selection clipboard
##     xclip -i -selection primary
##     xclip -i -selection secondary
##   PASTE:
##     xclip -o -selection clipboard
##       or
##     xclip -o -sel c
## 
## Linux version of OSX pbcopy and pbpaste - xsel
#https://medium.com/@codenameyau/how-to-copy-and-paste-in-terminal-c88098b5840d
##   alias pbcopy=’xsel — clipboard — input’
##   alias pbpaste=’xsel — clipboard — output’
## 
## https://ostechnix.com/access-clipboard-contents-using-xclip-and-xsel-in-linux/
##   COPY (to clipboard):
##     xsel -ib
##   PASTE (from clipboard):
##     xsel -ob
##   PASTE (from primary selection (i.e., equivalent to middle-click)):
##     xsel -op
##   CLEAR clipboard contents:
##     xsel -cb
## 
if [[ $(uname) =~ "Darwin" ]]; then
    CLIP_COPY_CMD="pbcopy"
elif [[ $(uname) =~ "_NT" ]] || \
    $( df -k / | egrep -o '^[A-Z]:' >/dev/null ); then 
    CLIP_COPY_CMD="clip"
elif [[ $( which xclip >/dev/null 2>&1 ) ]]; then
    CLIP_COPY_CMD="xclip -selection clipboard"
fi
[[ -n "${CLIP_COPY_CMD}" ]] && export CLIP_COPY_CMD


## 
## Print a formatted date suffix
## 
pfd () {
    DATE_BASE_FMT="%Y-%m-%d"
    DATE_TIME_FMT=""

    while getopts ":tf:" arg; do
        case "${arg}" in 
            t)
                DATE_TIME_FMT="_%H%M"
                ;;
            f)
                DATE_TIME_FMT=""
                DATE_BASE_FMT="${OPTARG}"
                break
                ;;
        esac
    done

    date "+__${DATE_BASE_FMT}${DATE_TIME_FMT}"
}

cppfd () {
    # check OS to use appropriate copy buffer command
    # use "echo -n" or "printf" to avoid CR/LF from being copied/pasted
    if [[ $(uname) =~ "Darwin" ]]
    then
        printf "$(pfd "${@}")" | tee $(tty) | pbcopy && echo
    elif [[ $(uname) =~ "_NT" ]] || $( df -k / | egrep -o '^[A-Z]:' >/dev/null )
    then
        MYC_TTY=$(tty)  && printf "$(pfd "${@}")" | tee ${MYC_TTY} | clip && echo
    elif [[ -n $( which xclip >/dev/null 2>&1 ) ]]
    then
        printf "$(pfd "${@}")" | tee $(tty) | xclip -selection clipboard
    else
        printf "$(pfd "${@}")\n"
    fi
}


## 
## Stub for date comparison function
## 
compdate ()
{
    # Check date binary
    # GNU date
    DATED=$(date -d "1800 seconds" "+%Y%m%d_%H%M%S" > /dev/null 2>&1; echo $?)  
    # AT&T/MacOS date
    DATEV=$(date -v "+1800S" "+%Y%m%d_%H%M%S" > /dev/null 2>&1; echo $?)             
    if [[ $(date -d "${1}" +%s) -lt $(date -d "${2}" +%s) ]]; then
        echo "${1}  <  ${2}  (to the FUTURE)";
    else
        if [[ $(date -d "${1}" +%s) -gt $(date -d "${2}" +%s) ]]; then
            echo "${1}  >  ${2}  (to the PAST)";
        else
            echo "${1}  =  ${2}  (in the NOW)";
        fi;
    fi;
}

## 
## Text Processing
## 
looppre() { 
    PREFIX="${1}";
    while true; 
        do read x && echo -n "${PREFIX}__$(mlc ${x//[\"\']/})__" ; 
    done; 
}
mlc() { 
    echo "${@}" | sed -e 's/[$.]/_/g' -e 's/\\/_/g' -e "s/'//g" | \
        awk '{
            gsub(" *& *"," and ");
            gsub("[][)({} :,;!?/|]","_");
            gsub("___{1,}","__");
            gsub("[^_]_$",substr($0,length($0)-1,1));
            gsub("^_[^_].*",substr($0,2));
            printf tolower($0)
        }' | tee $(tty) | pbcopy && echo;
}
lmlc() { while true; do read answer; mlc "${answer//[\"\']/}"; done; }
mlb()  { mlc "${@//[\"\']/}__" ; }
lmlb() { while true; do read answer; mlc "${answer//[\"\']/}__" ; done; }
mle()  { mlc "__${@//[\"\']/}" ; }
lmle() { while true; do read answer; mlc "__${answer//[\"\']/}" ; done; }
## sbs - strip backslashes from text (file or string)
sbs() { 
    [[ -f "$1" ]] && sed -e 's/\\//g' "$1" || echo "$1" | sed -e 's/\\//g';
}

## 
## ConvDate - convdate
##   convert back and forth between epoch and human date formats
## 
convdate_v1 ()
{
    if [[ "$1" == *"/"* ]]; then
        date -d "${1}" +"%s";
    else
        date --date="@${1}" +"%m/%d/%Y";
        if [[ $(expr length "$1") -gt 9 ]]; then
            date --date="@${1::-3}" +"%m/%d/%Y (second guess after truncating)";
        fi;
    fi
}

convdate() {
    [[ -f "$1" ]] && convertdate_awk "$1" || \
    ( [[ $# -gt 0 ]] && echo "$@" | 
       convertdate_awk ) || \
    convertdate_awk;
}

convertdate_awk() {
    ${AWK} '
    BEGIN {
        format=0
        CVFLAGS=""
        if (CVFLAGS ~ /h/) {
            format=1
        }
        if (CVFLAGS ~ /t/) {
            format=2
        }
    }
    function date_to_epoch_seconds(the_date) {
        the_epoch_seconds = 0
        cmd=sprintf("date -d \"%s\" +\"%%s\"",the_date)
        cmd | getline the_epoch_seconds
        close(cmd)
        return the_epoch_seconds
    }
    function print_switch(seconds) {
        switch (CVFLAGS) {
        case /v/:
            print_summary_verbose(seconds)
            break
        case /i/:
            print_date_iso(seconds)
            break
        case /n/:
            print_date_north_america(seconds)
            break
        case /e/:
            print_date_europe(seconds)
            break
        case /s/:
            print_seconds(seconds, format)
            break
        case /m/:
            print_milliseconds(seconds, format)
            break
        case /u/:
            print_microseconds(seconds, format)
            break
        default:
            print_summary(seconds)
            break
        }
    }
    function print_summary_verbose(seconds) {
        printf("Date (ISO): %s        %s (USA-MDY)        %s (EUR-DMY)\n",\
            strftime("%Y-%m-%d",seconds),\
            strftime("%m/%d/%Y",seconds),\
            strftime("%d/%m/%Y",seconds))
        printf("        Epoch: %25d seconds\n",seconds)
        printf("        Epoch: %25d milliseconds\n",seconds*1000)
        printf("        Epoch: %25d microseconds\n",seconds*1000*1000)
    }
    function print_summary(seconds) {
        printf("%s  %s  %12d s  %14d ms  %16d μs\n", \
            strftime("%Y-%m-%d",seconds), \
            strftime("%m/%d/%Y",seconds), \
            seconds, \
            seconds*1000, \
            seconds*1000*1000 )
    }
    function print_date_iso(seconds) {
        printf("%s\n", strftime("%Y-%m-%d",seconds))
    }
    function print_date_north_america(seconds) {
        printf("%s\n", strftime("%m/%d/%Y",seconds))
    }
    function print_date_europe(seconds) {
        printf("%s\n", strftime("%d/%m/%Y",seconds))
    }
    function print_seconds(seconds, formatting) {
        printf("%25d",seconds*1000*1000)
        if (formatting) { printf(" s") }
        if (formatting > 1) { printf(" (seconds from Unix Epoch)") }
        printf("\n")
    }
    function print_milliseconds(seconds, formatting) {
        printf("%25d",seconds*1000)
        if (formatting) { printf(" ms") }
        if (formatting > 1) { printf(" (milliseconds from Unix Epoch)") }
        printf("\n")
    }
    function print_microseconds(seconds, formatting) {
        printf("%25d",seconds*1000*1000)
        if (formatting) { printf(" μs") }
        if (formatting > 1) { printf(" (microseconds from Unix Epoch)") }
        printf("\n")
    }
    /[[:digit:]]+\/[[:digit:]]+\/[[:digit:]]+/ || \
    (NF>=3 && /[[:digit:]]/ && /[A-z][A-z][A-z]+/) || \
    /[[:digit:]]+-[[:digit:]]+-[[:digit:]]+/ {
#        print(date_to_epoch_seconds($0)); next
        print_summary(date_to_epoch_seconds($0)); next
    }
    /^[+-]?[[:digit:]]+$/ && ($0 <= -16769376000000 || $0 >= 16769376000000) {
#        print($0/1000/1000); next
        print_summary($0/1000/1000); next
    }
    /^[+-]?[[:digit:]]+$/ && ($0 <= -16769376000 || $0 >= 16769376000) {
#        print($0/1000); next
        print_summary($0/1000); next
    }
    /^[+-]?[[:digit:]]+$/ {
#        print($0); next
        print_summary($0); next
    }
    ' "${@}"
}


## 
## ReColumnize (recol)
##   Ensure each column is taking up only the maximum required to fit values
## 
recol() {
  "${AWK}" '
  BEGIN {
    NUM_PAD_SPACE=2
  }
  {
    num_elem=split($0,curr_line_array)
    for (elem=1; elem<=num_elem; elem++) {
        line_matrix[NR][elem] = curr_line_array[elem]
    }
    for (i=1; i<=length(curr_line_array); i++) {
      if (length(curr_line_array[i]) > max_col_width[i]) {
        max_col_width[i] = length(curr_line_array[i])
      }
    }
  }
  END {
    num_lines=length(line_matrix)
    for (line=1; line<=num_lines; line++) {
      num_line_cols = length(line_matrix[line])
      printf("%-*s", max_col_width[1], line_matrix[line][1])
      for (col=2; col<=num_line_cols; col++) {
        if (line_matrix[line][col] ~ /^[+-]?[[:digit:]]+$/) {
          printf("%*s%*s", \
            NUM_PAD_SPACE, \
            " " , \
            max_col_width[col], \
            line_matrix[line][col])
        } else {
          printf("%*s%-*s", \
            NUM_PAD_SPACE, \
            " " , \
            max_col_width[col], \
            line_matrix[line][col])
        }
      }
      printf("\n")
    }
  }' "${@}"
}


## 
## Concatenate to Archive and Unwind
## 
catar() {
    sample="${1}"
    shift
    nfsl=$(wc -l "${sample}" | gawk '{printf "%x\n",$1+2}')
    reborn="${sample%.*}_$(date +"%Y-%m-%d_%H%M")__${nfsl}.${sample##*.}"
    ( cat "${sample}" && echo "###" && tar cf - "${@}" | gzip -9 - ) > "${reborn}"
}

ratac() {
    hermes="${1}"
    xlb="${hermes//*__}"
    xlx="${xlb%.*}"
    #printf "${hermes} => \"${xlb}\" \"${xlx}\" \"${xle}\"\n"
    sln=$(echo "0x${xlx}" | ${AWK} '{printf "%d\n",strtonum($1)}')
    sed -n "${sln},$ p" "${hermes}" | gzip -dc - | tar xvf -
}


## 
## Sound stuff
## 
## Playing sound with ffplay - FFplay media player
## 
splay() { 
    for i in "${@}"; do ffplay -nodisp -autoexit -loglevel quiet "${i}"; done; 
}


##
## Zsh Options
##
## View or change current options by with either "set -o" or "set +o"
## 
## Enable an option
##     setopt OPTION
##     set -o OPTION
## 
## Disable an option
##     unsetopt OPTION
##     set +o OPTION
## 
## See all enabled options
##     setopt
## See all disabled options
##     unsetopt
## 
## See all options and their current settings
##   (formatted as a list of "on" or "off" values)
##     set -o
## See all options and their current settings
##   (formatted as commands to replicate via script)
##     set +o
## 
## Example: view a subset of values:
##     % setopt | awk '/correct/||(/glob/&&/ext|null|dot/&&!/csh/)'
##     correct
##     extendedglob
##     globdots
##     
##     % unsetopt | awk '/correct/||(/glob/&&/ext|null|dot/&&!/csh/)'
##     correctall
##     nullglob
##     
##     % set -o | awk '/correct/||(/glob/&&/ext|null|dot/&&!/csh/)'
##     correct               on
##     correctall            off
##     extendedglob          on
##     globdots              on
##     nullglob              off
##     
##     % set +o | awk '/correct/||(/glob/&&/ext|null|dot/&&!/csh/)'
##     set -o correct
##     set +o correctall
##     set -o extendedglob
##     set -o globdots
##     set +o nullglob
##     
## NOTE: Zsh can use Bash names (as "Option Aliases") when modifying options
##   See:
##     https://linux.die.net/man/1/zshoptions
##     https://zsh.sourceforge.io/Doc/Release/Options.html
## 
##   For example:
##     % set -o | awk '/glob/&&/dot/'
##     globdots              on
##     % unsetopt DOT_GLOB
##     % set -o | awk '/glob/&&/dot/'
##     globdots              off
##     
## NOTE: Options are commonly capitalized with underscores for readability
##   in shell resource files (i.e., .bashrc, .zshrc) for human convenience.
##     
##   Use and placement of case and underscores does not matter to the shell:
##     
##     % set -o | grep -i correct
##     correct               on
##     correctall            off
##     % set -o CORR_ECT_ALL
##     % set -o | grep -i correct
##     correct               on
##     correctall            on
##     % unsetopt C_ORRE_CTA_LL
##     % set -o | grep -i correct
##     correct               on
##     correctall            off
##     
if [[ $0 =~ "zsh" ]]; then
    bindkey -e                 # emacs key bindings in zsh
    HISTFILE="$E_HOME/.zsh_history"
    LOGCHECK=10
    WATCHFMT="%B%n%b has %a from %m"
    watch=(all)
    NULLCMD=cat
    READNULLCMD=less
    autoload -U compinit && compinit
    if [[ -d "${E_HOME}/myfunctions" ]]; then
        fpath+=("${E_HOME}/myfunctions")
        for function_file in "${E_HOME}/myfunctions"/*; do
            autoload -Uz "${function_file##*/}"
        done
    fi
    setopt ALLEXPORT
    setopt APPEND_HISTORY
    setopt AUTO_CD
    setopt AUTO_LIST
    unsetopt AUTO_MENU
    setopt AUTO_PARAM_SLASH
    setopt AUTO_PUSHD
    setopt BANG_HIST
    setopt BRACE_CCL
    setopt CDABLE_VARS
    setopt CLOBBER
    setopt CORRECT
#    setopt CORRECT_ALL
    unsetopt CORRECT_ALL
    setopt EXTENDED_HISTORY
#    setopt GLOB_DOTS
    unsetopt GLOB_DOTS
    setopt HIST_IGNORE_DUPS
    setopt LIST_TYPES
    setopt LOGIN
    setopt NOBEEP
    setopt NOTIFY
fi
## END Zsh Options


## 
## Bash Options
## 
## See shell options enabled
##     echo $BASHOPTS
##     shopt | grep on
##
##   shopt: shopt [-pqsu] [-o] [optname ...]
##     Set and unset shell options.
##     
##     Change the setting of each shell option OPTNAME.  Without any option
##     arguments, list each supplied OPTNAME, or all shell options if no
##     OPTNAMEs are given, with an indication of whether or not each is set.
##     
##     Options:
##       -o restrict OPTNAMEs to those defined for use with `set -o'
##       -p print each shell option with an indication of its status
##       -q suppress output
##       -s enable (set) each OPTNAME
##       -u disable (unset) each OPTNAME
## 
## Examples:
##     $ shopt | awk '/glob/&&/ext|null|dot/'
##     dotglob          off
##     extglob          on
##     nullglob         off
## 
##     $ shopt -p | awk '/glob/&&/ext|null|dot/'
##     shopt -u dotglob
##     shopt -s extglob
##     shopt -u nullglob
## 
if [[ $0 =~ "bash" ]]; then 
    ## emacs key bindings in bash (ctrl-a, ctrl-e, ctrl-u, ctrl-k, etc.)
    bind -m emacs
    HISTFILE="${E_HOME}/.bash_history"
    ## Bash Completion
    ##   https://sourabhbajaj.com/mac-setup/BashCompletion/
    ##   https://serverfault.com/questions/506612/standard-place-for-user-defined-bash-completion-d-scripts
    ##   https://serverfault.com/questions/506612/standard-place-for-user-defined-bash-completion-d-scripts/1013395#1013395
    ##   https://github.com/scop/bash-completion/blob/master/README.md
    ##   
    ##     "$(find "${E_HOME}"/homebrew -name 'bash_completion.d' 2>/dev/null)"
    ## 
    printf "INFO: Looking for bash completion configurations\n"
    ## printf "DEBUG: Determining possible bash completion ancestor dirs\n"
    possible_bc_ancestor_dirs=()
    possible_bc_ancestor_dirs=( $( for each_path in \
        "/etc" \
        "/opt" \
        "/usr/opt" \
        "/usr/local" \
        "/usr/share" \
        "${HOMEBREW_PREFIX}" \
        "${HOME}/.bash_completion.d" \
        "${E_HOME}/.bash_completion.d"
    do
        if [[ -d "${each_path}" ]]; then
            printf "\"${each_path}\"\n"
        fi
    done | xargs readlink -f | sort -u ) )  2>/dev/null
    #printf "FOUND possible parent dirs:\n"
    #printf "    %s\n" "${possible_bc_ancestor_dirs[@]}\n"


#    ## printf "DEBUG: finding completion DIRS\n"
#    found_bash_completion_dirs=( $(find "${possible_bc_ancestor_dirs[@]}" \
#        \( -name 'bash_completion' -o -name 'bash_completion.d' -o -name 'bash-completion.d' \) \
#        -type d  2>/dev/null | xargs readlink -f | sort -u) )
#    printf "FOUND bash completion dirs:\n"
#    printf "    %s\n" "${found_bash_completion_dirs[@]}"


    ## printf "DEBUG: finding completion FILES\n"
    found_bash_completion_files=( $(find "${possible_bc_ancestor_dirs[@]}" \
        "${E_HOME}/.bash_completion" \( \
                -name 'bash_completion' \
                -o -name '.bash_completion' \
                -o -name 'bash_completion.sh' \
                -o -name 'bash-completion.sh' \
            \) -type f  2>/dev/null | xargs readlink -f | sort -u) ) >2 /dev/null
    #printf "FOUND bash completion files:\n"
    #printf "    %s\n" "${found_bash_completion_files[@]}"


#    printf "DEBUG: processing completion DIRS\n"
#    for BC_PATH in "${found_bash_completion_dirs[@]}"; do 
#        for COMPLETION_FILE in "$(ls "${BC_PATH}")"; do 
#            echo source "${COMPLETION_FILE}"
#        done
#    done

    #printf "INFO: processing completion FILES\n"
    for BC_FILE in "${found_bash_completion_files[@]}"; do 
        #echo source "${BC_FILE}"
        source "${BC_FILE}"
    done

    if [[ -d "${E_HOME}/myfunctions" ]]; then
        for function_file in "${E_HOME}/myfunctions"/*; do
            source "${function_file}" && export -f "${function_file##*/}"
        done
    fi
fi
## END Bash Options


## 
## Common Options
## 
#EDITOR=emacs
EDITOR=vi
HISTSIZE=4096
TMOUT=0


##
## More Information
## 
## An example of listing/searching directories using a regular expression
# % ls -ld /{,ms/,usr/{,local/}{,share/}}man
# drwxr-xr-x  10 root     bin          512 Jun 16  2005 /usr/local/man
# drwxr-xr-x   4 root     bin          512 Jun 16  2005 /usr/local/share/man
# lrwxrwxrwx   1 root     root          11 May 19  2005 /usr/man -> ./share/man
# drwxr-xr-x  94 root     bin         2048 Jan  5  2006 /usr/share/man

## 
## Bash variable checks
## 
## https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
## https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash/16753536#16753536
## 

## 
## AWS
## 
goar1()  { export AWS_DEFAULT_REGION='us-east-1'; }
goar2()  { export AWS_DEFAULT_REGION='us-east-2'; }
goap1()  { export AWS_PROFILE='first'; }
goap2()  { export AWS_PROFILE='default'; }
## 
## Web Browser extension "SAML to AWS STS Keys Conversion" saves credentials
##   Generates file with AWS STS Keys after logging in to AWS webconsole 
##   using SSO (SAML 2.0).  It leverages 'assumeRoleWithSAML' API.
## 
## https://github.com/prolane/samltoawsstskeys
## https://chrome.google.com/webstore/detail/saml-to-aws-sts-keys-conv/ekniobabpcnfjgfbphhcolcinmnbehde
## https://addons.mozilla.org/en-US/firefox/addon/saml-to-aws-sts-keys/
## 
## Copy "credentials" file to a particular name under $HOME/.aws
cpaprod(){ cp -p "${E_HOME}"/Downloads/credentials "${E_HOME}"/.aws/credentials.prod; }
cpanpe() { cp -p "${E_HOME}"/Downloads/credentials "${E_HOME}"/.aws/credentials.non-prod; }
## Use a particular "credentials" file under $HOME/.aws
## 
##   https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
##     aws configure list-profiles
## 
goaprod(){ 
    #export AWS_PROFILE=prod
    export AWS_SHARED_CREDENTIALS_FILE="${E_HOME}/.aws/credentials.prod"; 
}
goanpe() { 
    #export AWS_PROFILE=npe
    export AWS_SHARED_CREDENTIALS_FILE="${E_HOME}/.aws/credentials.non-prod"; 
}
goaprodpci(){ 
    #export AWS_PROFILE=prod.pci
    export AWS_SHARED_CREDENTIALS_FILE="${E_HOME}/.aws/credentials.prod.pci"; 
}
goanpepci() { 
    #export AWS_PROFILE=npe.pci
    export AWS_SHARED_CREDENTIALS_FILE="${E_HOME}/.aws/credentials.non-prod.pci"; 
}
show_aws_env() {
    echo "AWS_PROFILE                  == \"$AWS_PROFILE\""
    echo "AWS_SHARED_CREDENTIALS_FILE  == \"$AWS_SHARED_CREDENTIALS_FILE\""
    echo "AWS_DEFAULT_REGION           == \"$AWS_DEFAULT_REGION\""
    echo "AWS_ACCESS_KEY_ID            == \"$AWS_ACCESS_KEY_ID\""
    echo "AWS_SECRET_ACCESS_KEY        == \"$AWS_SECRET_ACCESS_KEY\""
}
## 

aws_env() {
    if [[ $# -eq 1 ]]; then
        AWS_PROFILE="${1}"
    else
        AWS_PROFILE="default"
    fi
    export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile ${AWS_PROFILE});
    export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile ${AWS_PROFILE});
    export AWS_DEFAULT_REGION=$(aws configure get region --profile ${AWS_PROFILE});
    echo "${AWS_PROFILE} environment variables exported";
}

aws_env_tf() {
    if [[ $# -eq 1 ]]; then
        AWS_PROFILE="${1}"
    else
        AWS_PROFILE="default"
    fi
    export TF_VAR_aws_access_key=$(aws configure get aws_access_key_id --profile ${AWS_PROFILE});
    export TF_VAR_aws_secret_key=$(aws configure get aws_secret_access_key --profile ${AWS_PROFILE});
    export TF_VAR_region=$(aws configure get region --profile ${AWS_PROFILE});
    echo "${AWS_PROFILE} environment variables exported to terraform";
}

## AWS ECR list
ael() {
    LINE_COUNT=10
    while getopts ":l:" arg; do
        case "${arg}" in 
            l)
                LINE_COUNT="${OPTARG}"
                shift
                shift
                break
                ;;
        esac
    done
    if [[ "${1}" =~ "^[A-Za-z]+" ]]; then
        REPO="${1}"
    else
        echo "ERROR: please specify an ECR repository"
        return 1
    fi
    printf 'DEBUG: REPO = "%s"\n' ${REPO}
    aws ecr describe-images \
        --repository-name "${REPO}" \
        --query 'imageDetails[?(not_null(imageTags[0]))].[registryId,imageSizeInBytes,imagePushedAt,repositoryName,imageTags[0]]' \
        --output text | sort -Vk5 | tail -${LINE_COUNT}
}


## 
## Assume Account Role - assume AWS account roles
##   Original script by D. Shultz; modified to avoid a temp file 
##   for KEY/TOKEN values for security while sharing dotfile 
##   and avoiding session conflicts
## 
##   Requires a file with both EXTERNAL_ID and ARN_ROLE defined
##     Assume a format like 
##       % cat ~/.aws/externalid_role
##       EXTERNAL_ID="abcdefgh"
##       ARN_ROLE="delegate-admin-such-a-nice-instance-profile"
##     but accommodate if the user already specified an export command 
##     in anticipation of directly sourcing the file.
## 
aar () {
    #set +x
    export account_id=$1
    # Check whether GNU or AT&T/MacOS date binary
    # GNU date
    DATED=$(date -d "1800 seconds" "+%Y%m%d_%H%M%S" > /dev/null 2>&1; echo $?)  
    # AT&T/MacOS date
    DATEV=$(date -v "+1800S" "+%Y%m%d_%H%M%S" > /dev/null 2>&1; echo $?)             
    ID_ROLE_FILE="${E_HOME}/.aws/externalid_role"
    if [[ -f "${ID_ROLE_FILE}" ]]; then 
        eval $( sed -e '/^export/!s/^/export /' "${ID_ROLE_FILE}" )
    fi
    export DURATION=1800                # desired duration of session in seconds
    export TARGET_ARN="arn:aws:iam::${account_id}:role/${ARN_ROLE}"
    unset_cmd="unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN"
    # Print the current account/role if there is a valid session
    echo "Current role: $(aws sts get-caller-identity --query Arn --output text)"
    echo $unset_cmd
    eval $unset_cmd
    if [[ $# -gt 0 ]]; then
        #SESSION="temp"
        SESSION="expiry_$(date -d "$DURATION seconds" "+%Y%m%d_%H%M%S")"
        eval $( aws sts assume-role --duration-seconds $DURATION \
            --role-arn $TARGET_ARN \
            --role-session-name $SESSION \
            --external-id "${EXTERNAL_ID}" | \
          awk '
            /AccessKeyId/    {gsub("[\",]","");printf "export AWS_ACCESS_KEY_ID=%s\n",$2}
            /SecretAccessKey/{gsub("[\",]","");printf "export AWS_SECRET_ACCESS_KEY=%s\n",$2}
            /SessionToken/   {gsub("[\",]","");printf "export AWS_SESSION_TOKEN=%s\n",$2}
            /Expiration/     {gsub("[\",]","");printf "export AWS_SESSION_EXPIRY=%s\n",$2}
          ' )
    fi
    echo "Assumed role: $(aws sts get-caller-identity --query Arn --output text)"
    echo "Current time: $(date)"
    echo "Expiry  time: $(date -d "$AWS_SESSION_EXPIRY")"
    unset account_id DURATION TARGET_ARN;
}

## Other utilities: kubernetes, helm, etc.
alias kc="kubectl"


## 
## Linux
## 
## 
## Manually start a window manager if booting Linux to a console
##   Purposefully not indented to avoid breaking `showfuncs`
## 
## Start X in the background, disown the process, 
## and exit, so the parent tty can't be hijacked
##
if [[ $(which startx >/dev/null 2>&1) ]]; then
gox() { 
    startx &
    disown
    (sleep 5 && exit)
}
fi


## 
## MacOS
## 
if [[ `uname -s` =~ "Darwin" ]]; then
    ## 
    ## Variables
    ## 
    export CDPATH=".:${HOME}:${HOME}/Documents"

    ## 
    ## Text Processing
    ## 
    looppre() { 
        PREFIX="${1}";
        while true; 
            do read x && echo -n "${PREFIX}__${x}__" | pbcopy; 
        done; 
    }

    ## 
    ## Homebrew
    ## 
    ## Basic Installation (requires admin/sudo access)
    ##   https://brew.sh/
    ##     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ## 
    ##   https://docs.brew.sh/Installation
    ##     This script installs Homebrew to its default, supported, best prefix 
    ##          /usr/local                      for macOS Intel
    ##          /opt/homebrew                   for Apple Silicon
    ##          /home/linuxbrew/.linuxbrew      for Linux
    ##     so that you don’t need sudo after Homebrew’s initial installation when you brew install.
    ## 
    ## 
    ## Per-User Installation (shared system or no admin/sudo access)
    ## 
    ##   https://docs.brew.sh/Installation#multiple-installations
    ##   FIRST
    ##       mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | \
    ##           tar xz --strip 1 -C homebrew
    ##     OR
    ##       git clone https://github.com/Homebrew/brew homebrew
    ##   THEN
    ##       eval "$(homebrew/bin/brew shellenv)"
    ##       brew update --force --quiet
    ##       chmod -R go-w "$(brew --prefix)/share/zsh"
    ## 
    ## Show what the default "shellenv" output would be like 
    ##     (for adding to shell resource file)
    ## 
    show_brew_env() {
        BREW_APP="$(find \
            /opt/homebrew \
            /usr/local/Cellar \
            /usr/local/homebrew \
            "${HOMEBREW_PREFIX}" \
            "${HOME}/homebrew" \
            -maxdepth 2 -type f -name brew 2>/dev/null | tail -1
        )"
        if [[ "${1}" == "-a" ]]; then
            if [[ -n "${BREW_APP}" ]]; then
                printf "%s\n" "${BREW_APP}"
                return 0
            fi
        else
            if [[ -n "${BREW_APP}" ]]; then
                "${BREW_APP}" shellenv
                return 0
            else
                printf "No homebrew installation found." > /dev/stderr
                return 1
            fi
        fi
    }

    ## Default "brew shellenv" output is like:
    ##   export HOMEBREW_PREFIX="/usr/local/homebrew";
    ##   export HOMEBREW_CELLAR="/usr/local/homebrew/Cellar";
    ##   export HOMEBREW_REPOSITORY="/usr/local/homebrew";
    ##   export PATH="/usr/local/homebrew/bin:/usr/local/homebrew/sbin${PATH+:$PATH}";
    ##   export MANPATH="/usr/local/homebrew/share/man${MANPATH+:$MANPATH}:";
    ##   export INFOPATH="/usr/local/homebrew/share/info:${INFOPATH:-}";
    ##  or
    ##   export HOMEBREW_PREFIX="/Users/brian/homebrew";
    ##   export HOMEBREW_CELLAR="/Users/brian/homebrew/Cellar";
    ##   export HOMEBREW_REPOSITORY="/Users/brian/homebrew";
    ##   export PATH="/Users/brian/homebrew/bin:/Users/brian/homebrew/sbin${PATH+:$PATH}";
    ##   export MANPATH="/Users/brian/homebrew/share/man${MANPATH+:$MANPATH}:";
    ##   export INFOPATH="/Users/brian/homebrew/share/info:${INFOPATH:-}";
    ## 
    ## Build our own to take advantage of functions guaranteeing unique paths
    ## 
    BREW_APP="$(show_brew_env -a)"
    #HOMEBREW_PREFIX="${BREW_APP%/bin/brew}";
    if [[ -n "${BREW_APP}" ]]; then
        BREW_HOME="$(dirname "${BREW_APP}")"
        while [[ ! -d "${BREW_HOME}"/Cellar && "${BREW_HOME}" != "/" ]]; do
            BREW_HOME="$(dirname "${BREW_HOME}")"
        done
        if [[ "${BREW_HOME}" != "/" ]]; then
            HOMEBREW_PREFIX="${BREW_HOME}"
            HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar";
            HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}";
            pathadd_left "${HOMEBREW_PREFIX}/sbin"
            pathadd_left "${HOMEBREW_PREFIX}/bin"
            manpathadd_left "${HOMEBREW_PREFIX}/share/man"
            HOMEBREW_INFO="${HOMEBREW_PREFIX}/share/info"
            if [[ -d "${HOMEBREW_INFO}" ]] && [[ ":${INFOPATH}:" != *":${HOMEBREW_INFO}:"* ]]; then
                INFOPATH="${HOMEBREW_INFO}${INFOPATH:+:${INFOPATH}}"
            fi
            if [[ $0 =~ "bash" ]]; then
                if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
                then
                    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
                else
                    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
                    do
                        [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
                    done
                fi
            fi
            ## Ruby
            ##   Ruby Managers
            ##     RVM
            ##       https://rvm.io/rvm/install
            ##     rbenv
            ##       brew install rbenv
            ##       rbenv install -l
            ##       rbenv install 3.2.2
            ##     chruby and ruby-install
            ##       brew install chruby ruby-install
            ## 
            ## Ruby - RVM
            ##   Initialize RVM if present
            if [[   -s "${E_HOME}/.rvm/scripts/rvm" && -z "${__HOME_RVM_LOADED}" ]]; then
                source "${E_HOME}/.rvm/scripts/rvm" && __HOME_RVM_LOADED="true"
            fi
            ## Ruby - rbenv
            ##   Initialize rbenv if present
            if which rbenv > /dev/null; then
                pathadd_left "${HOME}/.rbenv/shims"
                export PATH
                eval "$(rbenv init - | grep -v 'PATH=')"
            fi
            ## 
            ## Ruby - chruby
            ##   Initialize chruby if present
            [[   -s  "${HOMEBREW_PREFIX}/opt/chruby/share/chruby/chruby.sh" ]] && \
              source "${HOMEBREW_PREFIX}/opt/chruby/share/chruby/chruby.sh"
            ##   Enable auto-switching of Rubies specified by .ruby-version files
            [[   -s  "${HOMEBREW_PREFIX}/opt/chruby/share/chruby/auto.sh" ]] && \
              source "${HOMEBREW_PREFIX}/opt/chruby/share/chruby/auto.sh"
            ## 
            ## Gems
            ##     gem list --local
            ##     gem install --user-install iStats      ## iStats reports CPU temp
            ## 
            LOCAL_GEM_DIR="${E_HOME}/.gem/ruby"
            if [[ -d "${LOCAL_GEM_DIR}" ]]; then
                for each_ruby_version_bin in \
                    $(find "${LOCAL_GEM_DIR}" -maxdepth 2 -type d -name bin); do
                    pathadd_right "${each_ruby_version_bin}"
                done
            fi
        fi  ## END check if HOMEBREW_PREFIX can be set
    fi
    export HOMEBREW_PREFIX HOMEBREW_CELLAR HOMEBREW_REPOSITORY PATH MANPATH INFOPATH

    ## curl / AWS / GCP
    [[ -f "${HOME}/.aws/nskp_config/netskope-cert-bundle.pem" ]] && \
        export REQUESTS_CA_BUNDLE="${HOME}/.aws/nskp_config/netskope-cert-bundle.pem"
    
    ## 
    ## Functions to open Mac Apps
    ## 

    ## MacVim
    ## 
    ## NOTE: Location/Order of configuration files MacVim reads
    ## :version reveals that MacVim loads configuration files in this order
    ##    system vimrc file: "$VIM/vimrc"
    ##      user vimrc file: "$HOME/.vimrc"
    ##  2nd user vimrc file: "~/.vim/vimrc"
    ##       user exrc file: "$HOME/.exrc"
    ##   system gvimrc file: "$VIM/gvimrc"
    ##     user gvimrc file: "$HOME/.gvimrc"
    ## 2nd user gvimrc file: "~/.vim/gvimrc"
    ##        defaults file: "$VIMRUNTIME/defaults.vim"
    ##     system menu file: "$VIMRUNTIME/menu.vim"
    ##   fall-back for $VIM: "/Applications/MacVim.app/Contents/Resources/vim"

    macvim() { for i in "${@}"; do
        [[ -f "${i}" ]] && open -a MacVim "${i}" || \
            { { printf "File \"%s\" does not exist. Create? [yN] " "${i}" && \
                read reply && [[ "$reply" =~ [yY] ]]; } && \
                { touch "${i}" && open -a MacVim "${i}"; } || \
                    echo "No file found to edit." ; }
        done;
    }

    macvim1() { open -a MacVim "${@}"; }

    ## Xcode
    ## 
    xc() { open -a Xcode "${@}"; }

    ## Visual Studio
    ## 
    ## NOTE: Settings are stored in the directory
    ##   "${HOME}"/"Library/Application Support/Code/User"
    ##   
    ##   % cd Library/Application\ Support/Code/User 
    ##   % for i in *.json; do echo "# FILE: $i"; cat $i && printf "\n\n"; done
    ##   # FILE: keybindings.json
    ##   // Place your key bindings in this file to override the defaults
    ##   [
    ##       // Enable (Shift-)Control-Tab to move between tabs based on 
    ##       //   (visible) adjacency rather than (invisible) last update time
    ##       // https://stackoverflow.com/a/38978993
    ##       {
    ##           "key": "ctrl+tab",
    ##           "command": "workbench.action.nextEditor"
    ##       },
    ##       {
    ##           "key": "ctrl+shift+tab",
    ##           "command": "workbench.action.previousEditor"
    ##       }
    ##   ]
    ##   
    ##   # FILE: settings.json
    ##   {
    ##       // Restore some sanity and make Visual Studio a better-behaved Mac app
    ##       // Enables macOS Sierra window tabs. 
    ##       // Note that changes require a full restart to apply and that 
    ##       // native tabs will disable a custom title bar style if configured.
    ##       // 
    ##       "window.nativeTabs": true,
    ##       // Adjust the appearance of the window title bar. 
    ##       // On Linux and Windows, this setting also affects the application 
    ##       // and context menu appearances. Changes require a full restart to apply.
    ##       // 
    ##       "window.titleBarStyle": "native",
    ##       "security.workspace.trust.untrustedFiles": "open",
    ##       "window.openFilesInNewWindow": "on"
    ##   }
    ##   
    [[ -e "/Applications/Visual Studio.app" ]] && \
        vs() { open -a "Visual Studio" "${@}"; }
    [[ -e "/Applications/Visual Studio Code.app" ]] && \
        vs() { open -a "Visual Studio Code" "${@}"; }

    LYNX='/Applications/Lynxlet.app/Contents/Resources/lynx/bin/lynx'
    [[ -f "${LYNX}" ]] && alias lynx="${LYNX}"


    ## Google Chrome
    ## 
    chrome() { open -a "Google Chrome" "${@}"; }
    ## 
    ## Define Functions to open Google Apps, if installed
    ## 
    ##   Should pass output like the following to 'eval':
    ##     docs()     { open -a "Docs"; }; 
    ##     gmail()    { open -a "Gmail"; }; 
    ##     calendar() { open -a "Google Calendar"; }; 
    ##     chat()     { open -a "Google Chat"; }; 
    ##     drive()    { open -a "Google Drive"; }; 
    ##     meet()     { open -a "Google Meet"; }; 
    ##     sheets()   { open -a "Sheets"; }; 
    ##     
    CHROME_APP_PATH="$(ls -1d "${E_HOME}/Applications/Chrome Apps.localized" 2>/dev/null)"
    if [[ "x${CHROME_APP_PATH}" != "x" ]]; then 
        eval $( ls -1 "${CHROME_APP_PATH}/" | \
            "${AWK}" -F/ '/app$/ {
                gsub(".app","");
                numparts=split($NF,appname," ");
                printf "%-10s { open -a \"%s\"; }; \n",tolower(appname[numparts])"()",$NF
            }' 
        )
    fi

    ## gocu - Go Chrome URL(s)
    ## Define function to open URL(s) in Google Chrome
    ##   Pass options to modify behavior:
    ##      new or existing window, incognito mode, prefix to add to all URLs)
    source ${HOME}/scripts/gocu.sh

    ## 
    ## cdf - Change Directory to Finder window path
    ##       Credit: https://superuser.com/a/1044651
    ## 
    cdf() {
        target=`osascript -e \
            'tell application "Finder" to \
                if (count of Finder windows) > 0 then 
                    get POSIX path of (target of front Finder window as text)
                end if'
        `
        if [ "x${target}" != "x" ]; then
            cd "${target}" && pwd || echo "Could not cd to \"${target}\"" >&2
        else
            echo 'No Finder window found' >&2
        fi
    }

    ## 
    ## show - Reveal (select, show) file(s) in the Finder
    ## 
    ##   NOTE: a single file may be revealed/selected with:
    ##       open -R "/path/to/some directory/and file.ext"
    ##   USAGE: 
    ##       To modify whether this function brings the Finder to foreground 
    ##       after highlighting files, add/uncomment/comment/remove the line 
    ##       "activate" after the line "reveal FILE_array"
    ##   CAVEAT:
    ##       Because this uses "readlink -f" to get full paths to files,
    ##       this will reveal the targets of symlinks in the Finder instead 
    ##       of the symlinks themselves.
    ##       This may or may not be what you are trying to do.
    ## 
    show() {
        if [[ $# -ge 1 ]] && [[ "x${1}" =~ "^x-[aA]$" ]]; then
            case "${1}" in 
                -a)
                    activateFinderWhenDone="true"
                    shift
                    ;;
                -A)
                    activateFinderWhenDone="false"
                    shift
                    ;;
                *)
                    activateFinderWhenDone="false"
                    ;;
            esac
        fi
        if [[ $# -ge 1 ]]; then
            FILE_ARRAY=()
            while [[ $# -gt 1 ]]; do
                CURR_FULL_PATH="$(readlink -f "${1}")"
                FILE_ARRAY+=("${CURR_FULL_PATH}")
                shift
            done
            CURR_FULL_PATH="$(readlink -f "${1}")"
            FILE_ARRAY+=("${CURR_FULL_PATH}")

            printf "%s " "${FILE_ARRAY[@]// /\ }" | xargs osascript -e 'on run argv
                set FILE_array to {}
                set files_found_count to 0
                repeat with i from 1 to length of argv
                    set curr_psx_file to item i of argv
                    set curr_hfs_file to POSIX file curr_psx_file
                    try
                        curr_hfs_file as alias
                        set the end of FILE_array to curr_hfs_file
                        set files_found_count to files_found_count + 1
                    on error
                    end try
                end repeat
                try
                    tell application "Finder"
                        reveal FILE_array
                    end tell
                on error
                    display dialog "Could not reveal files:\n" & FILE_array as string
                end try
                return "Found " & files_found_count & " files to display."
            end run'
            if [[ "x${activateFinderWhenDone}" = "xtrue" ]]; then 
                osascript -e   'tell application "Finder"
                                    activate
                                end tell'
            fi
        fi
    }


    ## 
    ## App Support and Library Environment Setup
    ## 

    # For compilers to find qt@5 you may need to set:
    LDFLAGS="-L/usr/local/opt/qt@5/lib -L/usr/local/opt/openssl@3/lib"
    CPPFLAGS="-I/usr/local/opt/qt@5/include -I/usr/local/opt/openssl@3/include"
    export LDFLAGS CPPFLAGS

    # For pkg-config to find qt@5 you may need to set:
    QT_BASE="/usr/local/opt/qt@5"
    OPENSSL_BASE="/usr/local/opt/openssl@3"
    PKG_CONFIG_PATH="${QT_BASE}/lib/pkgconfig:${OPENSSL_BASE}/lib/pkgconfig"
    export PKG_CONFIG_PATH


    ## 
    ## Perl Environment
    ## 
    #PATH="/Users/${USER}/perl5/bin${PATH:+:${PATH}}"
    #PERL5LIB="/Users/${USER}/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
    #PERL_LOCAL_LIB_ROOT="/Users/${USER}/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
    #PERL_MB_OPT="--install_base \"/Users/${USER}/perl5\""
    #PERL_MM_OPT="INSTALL_BASE=/Users/${USER}/perl5"
    #export PATH PERL5LIB PERL_LOCAL_LIB_ROOT PERL_MB_OPT PERL_MM_OPT
    ## 
    ## For issues with managing library paths and strategies, see:
    ##   https://www.sheepsystems.com/developers_blog/perl-fails-inc-again-after.html
    ##   https://github.com/Homebrew/homebrew-core/issues/10133
    ##   https://metacpan.org/pod/local::lib
    ## 

    UUP="/Users/${USER}/perl5"
    pathadd "${UUP}/bin"
    export PATH

    if [[ -d "${UUP}" ]]; then
        if ":$PERL5LIB:" != *":${UUP}/lib/perl5:"* ]; then
            PERL5LIB="${UUP}/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
        fi
        PLLR="${PERL_LOCAL_LIB_ROOT}"
        if ":$PLLR:" != *":${UUP}:"* ]; then
            PERL_LOCAL_LIB_ROOT="${UUP}${PLLR:+:${PLLR}}"
        fi
        PERL_MB_OPT="--install_base \"${UUP}\""
        PERL_MM_OPT="INSTALL_BASE=\"${UUP}\""
        [[ ! -z "${PERL5LIB}" ]]               &&   export PERL5LIB
        [[ ! -z "${PERL_LOCAL_LIB_ROOT}" ]]    &&   export PERL_LOCAL_LIB_ROOT
        [[ ! -z "${PERL_MB_OPT}" ]]            &&   export PERL_MB_OPT
        [[ ! -z "${PERL_MM_OPT}" ]]            &&   export PERL_MM_OPT
    fi

    get_apple_serial() { 
        /usr/sbin/ioreg -l | \
            "${AWK}" '/IOPlatformSerialNumber/{gsub("\"",""); print $NF; exit}'
    }
fi      ## /MacOS
## END MacOS


## 
## Docker
## 
dps() { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"; }

## 
## JAVA stuff, in case we use it
##    If not already set for the environment/system
## 
## jenv
##   Manage multiple JAVA instances with jenv if installed
## 
## For configuration and usage, see:
##   https://www.baeldung.com/jenv-multiple-jdk
## 
##   To activate jenv, add the following to your shell profile 
##       e.g. ~/.profile or ~/.zshrc
## 
##   export PATH="$HOME/.jenv/bin:$PATH"
##   eval "$(jenv init -)"
##     
if command -v jenv &>/dev/null; then
    pathadd_left "${HOME}/.jenv/shims"
    export PATH
    eval "$(jenv init - | grep -v 'PATH=')"

    printf "\nINFO: 'jenv' is installed to manage multiple Java versions\n"
    printf "INFO: use function 'refresh_jenv' to check for new versions\n"
    if [[ $(jenv versions | wc -l) -gt 1 ]]; then
        printf "INFO: jenv configured with multiple Java versions\n"
        printf "  USAGE:\n"
        printf "    jenv global           # view global configuration\n"
        printf "    jenv versions         # view installed versions\n"
        printf "    jenv global 1.8       # set global version\n"
        printf "      i.e., 1.8, 11.0, 18.0 (from \"jenv version\")\n"
        printf "    jenv local            # view local version for PWD\n"
        printf "    jenv local 1.8        # set local version for PWD\n"
    fi
fi
refresh_jenv() {
    if command -v jenv &>/dev/null; then
        printf "INFO: Checking for Java/JDK versions to manage with jenv (%s)\n" $(command -v jenv)
        #for i in /Library/Java/JavaVirtualMachines/*/Contents/Home; do 
        #for i in $(ls -d /Library/Java/JavaVirtualMachines/*/Contents/Home 2>/dev/null); do 
        for found_system_java_version in \
            $( find /Library/Java/JavaVirtualMachines -name Home -exec readlink -f {} \; | sort -u )
        do
            printf "DEBUG: trying: jenv add \"%s\"\n" "${found_system_java_version}"
            jenv add "${found_system_java_version}"
        done    >/dev/null  2>&1

        homebrew_paths=()
        homebrew_paths=( $( for each_possible_hb_path in \
            "/opt/homebrew" \
            "/usr/local/Cellar" \
            "/usr/local/homebrew" \
            "${HOMEBREW_PREFIX}" \
            "${HOME}/homebrew" \
            "${BREW_HOME}"
        do
            if [[ -d "${each_possible_hb_path}" ]]; then
                echo "${each_possible_hb_path}"
            fi
        done | xargs readlink -f | sort -u ) )

        for found_homebrew_java_version in \
            $(find $(find "${homebrew_paths[@]}" \
                -maxdepth 1 \( -name '*jdk*' -o -name '*jre*' -o -name '*java*' \) ) \
                -type d -name libexec -exec dirname {} \; | xargs readlink -f | sort -u)
        do
            jenv add "${found_homebrew_java_version}"
        done    >/dev/null  2>&1
    else
        printf "ERROR: jenv is not installed. Please install and retry.\n" >&2
    fi
}

## If jenv is not present, check default JAVA location for MacOS
## https://stackoverflow.com/questions/64968851/could-not-find-tools-jar-please-check-that-library-internet-plug-ins-javaapple
## 
## /usr/libexec/java_home -V 2>&1 | awk '/JavaVirtualMachines/{print $NF}'
##   /Library/Java/JavaVirtualMachines/jdk1.8.0_211.jdk/Contents/Home
if [[ -n "${JAVA_HOME}" ]]; then
    TJH="$(/usr/libexec/java_home -V 2>&1 | \
        awk '/JavaVirtualMachines/{print $NF}')"
    [[ -d "${TJH}" ]] && JAVA_HOME="$TJH"
fi

## 
## One more check in case JAVA_HOME is not set yet
## 
if [[ -z "${JAVA_HOME}" ]]; then
    if command -v java &>/dev/null; then
        JAVA_HOME="$(java -XshowSettings:properties -version 2>&1 | \
            sed -ne '/java\.home/ s/.*= *//p')"
    fi
fi
if [[ ${JAVA_HOME:+x} ]]; then
    export JAVA_HOME
    pathadd "${JAVA_HOME}/bin"
fi


## Ruby
## 
## Ruby rvm ruby gems - related tools and utilities
## 
##     gem list --local
## 
## RVM - load Ruby Version Manager into the shell session as a function
## 
if [[   -s "${E_HOME}/.rvm/scripts/rvm" && -z "${__HOME_RVM_LOADED}" ]]; then
    source "${E_HOME}/.rvm/scripts/rvm" && __HOME_RVM_LOADED="true"
fi
## 


## 
## OTHER Configurations
## 

## Google / gcloud
##   May be installed in "${HOME}" or "${HOME}/local"
## 
THIS_SHELL="${0//-}"
if [[ -d "${HOME}/google-cloud-sdk" ]]; then
    export GCLOUD_HOME="${HOME}/google-cloud-sdk"
elif [[ -d "${HOME}/local/google-cloud-sdk" ]]; then 
    export GCLOUD_HOME="${HOME}/local/google-cloud-sdk"
fi
if [[ "${THIS_SHELL}" =~ "^(bash|zsh)$" ]] && [[ -n "${GCLOUD_HOME}" ]]; then 
    # This updates PATH for the Google Cloud SDK.
    if [ -f "${GCLOUD_HOME}/path.${THIS_SHELL}.inc" ]; then 
        . "${GCLOUD_HOME}/path.${THIS_SHELL}.inc"; 
    fi
    # This enables shell command completion for gcloud.
    if [ -f "${GCLOUD_HOME}/completion.${THIS_SHELL}.inc" ]; then 
        . "${GCLOUD_HOME}/completion.${THIS_SHELL}.inc"; 
    fi
fi


if command -v bashcompinit &>/dev/null; then
    autoload -U +X bashcompinit && bashcompinit
    if [[ "x$(command -v terraform)" != "x" ]]; then
        complete -o nospace -C /usr/local/bin/terraform terraform
    fi
fi


## PRIVATE Configurations
## 
## Import settings or functions that may contain proprietary references  
## that cannot be easily obscured with regex or other references from 
## a separate configuration file to allow the base shell resource file 
## to be shared between a variety of systems.
## 
[[ -f "${SHELL_STARTUP_FPATH}.home" ]] && source "${SHELL_STARTUP_FPATH}.home"
[[ -f "${SHELL_STARTUP_FPATH}.work" ]] && source "${SHELL_STARTUP_FPATH}.work"


fi      ## END of: "if [[ is_interactive_shell ]]..."

