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
    ip-10*)
        E_HOME="${HOME}/tmp.bsnook" ;;
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
TPD=~/anaconda3/bin                             && pathadd "${TPD}"
TPD=/usr/ucb                                    && pathadd "${TPD}"
TPD=/usr/ccs/bin                                && pathadd "${TPD}"
TPD=/usr/local/ssl/bin                          && pathadd "${TPD}"
TPD=/usr/krb5/bin                               && pathadd "${TPD}"
TPD=/usr/krb5/sbin                              && pathadd "${TPD}"
TPD=/usr/kerberos/sbin                          && pathadd "${TPD}"
TPD=/usr/kerberos/bin                           && pathadd "${TPD}"
TPD=/usr/java/jre1.5.0_02/bin                   && pathadd "${TPD}"
TPD=/usr/java1.2/bin                            && pathadd "${TPD}"
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
TPD="${E_HOME}/homebrew/bin"                    && pathadd "${TPD}"
TPD=/Applications/Bluefish.app/Contents/MacOS   && pathadd "${TPD}"
TPD=~/Library/Python/3.8/bin                    && pathadd "${TPD}"
TPD=/usr/local/opt/qt@5/bin                     && pathadd "${TPD}"
TPD=/usr/local/Cellar/qt@5/5.15.3/bin           && pathadd "${TPD}"
TPD=/usr/local/go/bin                           && pathadd "${TPD}"
TPD="${JAVA_HOME}/bin"                          && pathadd "${TPD}"
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
TPD="${E_HOME}/.local/bin"                      && pathadd "${TPD}"
TPD="${E_HOME}/bin"                             && pathadd "${TPD}"
TPD="${E_HOME}/scripts"                         && pathadd "${TPD}"
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
MANPD="${E_HOME}/homebrew/manpages"    && manpathadd "${MANPD}"
export MANPATH

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
        PS1="%n@%m:%~%# "
        export PS1
    }
    # Set Fancy Prompt
    sfp() { 
        setopt PROMPT_SUBST
        PS1="%n@%m:%B\$(parse_git_toplevel)%b\$(parse_git_branch):%~%B%#%b "
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

## 
## Local environment and SSH connection functions
## 
gojup() { 
    cd ~/Documents/GitHub/Pierian-Data-Complete-Python-3-Bootcamp \
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
## FUNCTIONS (define useful utilities)
##
## Start X in the background, disown the process, 
## and exit, so the parent tty can't be hijacked
##
is_interactive_shell() {
    [[ "$-" =~ "i" ]]
}


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
showfuncs0() { 
    ${AWK} '/^[[:alnum:]_-]+ {0,}\( *\)/{print $1}' "${SHELL_STARTUP_FPATH}"; 
}
showfuncs() { 
    ${AWK} '/^[[:space:]]*[[:alnum:]_-]+ {0,}\( *\)/{print $1}' \
    "${SHELL_STARTUP_FPATH}" | sort -u; 
}
## 
## Showfunc displays the definition of a function by parsing the init file
## Single-line functions break it
## "which [function]" in zsh and "type [function]" in bash do the same thing
## It is still an interesting regex exercise in awk
## 
showfunc0()  { 
    ${AWK} -v FUNC="${1}" '$0 ~ "^"FUNC" *\\(",/^}/' "${SHELL_STARTUP_FPATH}";
}
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


if [[ is_interactive_shell ]]; then
    echo "INFO: \"showfuncs\" lists functions from \"${SHELL_STARTUP_FPATH}\""
fi

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
if [[ $(which whois >/dev/null 2>&1) ]]; then
awhois() { whois -h whois.arin.net $1; }
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

## Return the length of the longest line in a file/stream
len0() { ${AWK} 'length()>max{max=length()}END{print max}' $1; }
len2() { 
    [[ -f "$1" ]] && ${AWK} 'length()>max{max=length()}END{print max}' "$1" ||\
        echo "$1" | ${AWK} 'length()>max{max=length()}END{print max}'
}
len() { 
    [[ -f "$1" ]] && ${AWK} 'length()>max{max=length()}END{print max}' "$1" || \
    ( [[ $# -gt 0 ]] && echo "$@" | 
        ${AWK} 'length()>max{max=length()}END{print max}' ) || \
    ${AWK} 'length()>max{max=length()}END{print max}';
}

## Merge every other line (merge odd line and following even line)
m2l() { 
    [[ -f "$1" ]] && ${AWK} 'NR%2{printf $0" "; if(getline){print}else{print ""}}' "$1" || \
    ( [[ $# -gt 0 ]] && echo "$@" | 
        ${AWK} 'NR%2{printf $0" "; if(getline){print}else{print ""}}' ) || \
    ${AWK} 'NR%2{printf $0" "; if(getline){print}else{print ""}}';
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
gdiff() { git log $1 | \
    ${AWK} -v FN="$1" '/commit/{cmd=sprintf("%s %s",$2,cmd);\
        count++;if(count>=2){exit}}
        END{cmd=sprintf("git diff %s %s",cmd,FN);
        print cmd; system(cmd);close(cmd)}'; 
}

parse_git_branch() {
    #git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
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
## Color 'ls' (optional)
##
UNAMES=`uname -s`
TERM=vt220
if [[ $UNAMES = "Linux" ]]; then
    alias ls='ls --color'
    if [[ is_interactive_shell ]]; then
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
pfd() { date "+__%Y-%m-%d"; }
cppfd() { 
    # use "echo -n" or "printf" to avoid CR/LF from being copied/pasted
    if [[ $(uname) =~ "Darwin" ]]; then
        printf `date "+__%Y-%m-%d"` | tee $(tty) | pbcopy && echo; 
    elif [[ $(uname) =~ "_NT" ]] || \
        $( df -k / | egrep -o '^[A-Z]:' >/dev/null ); then 
        MYC_TTY=$(tty) && \
            printf `date "+__%Y-%m-%d"` | tee ${MYC_TTY} | clip && echo; 
    elif [[ $( which xclip >/dev/null 2>&1 ) ]]; then
        echo `date "+__%Y-%m-%d"` | tee $(tty) | xclip -selection clipboard
    else
        echo `date "+__%Y-%m-%d"`
    fi;
}

## 
## Stub for date comparison function
## 
compdate ()
{
    DATED=$(date -d "1800 seconds" "+%Y%m%d_%H%M%S" > /dev/null 2>&1; echo $?)  
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
      for (col=2; col<num_line_cols; col++) {
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
## Sound stuff
## 
splay() { 
    for i in "${@}"; do ffplay -nodisp -autoexit -loglevel quiet "${i}"; done; 
}

##
## Zsh Options
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
#[[ $0 =~ "bash" ]] && HISTFILE="$E_HOME/.bash_history"
if [[ $0 =~ "bash" ]]; then 
    bind -m emacs             # emacs key bindings in bash
    HISTFILE="$E_HOME/.bash_history"
    for BC_PATH in "/usr/share/bash-completion/bash_completion" \
        "/usr/local/share/bash-completion/bash_completion"; do
        [[ -f "${BC_PATH}" ]] && BASH_COMPLETION_PATH="${BC_PATH}" && \
            export BASH_COMPLETION_PATH
    done
    [[ $PS1 && -n "${BASH_COMPLETION_PATH}" ]] && \
        . /usr/share/bash-completion/bash_completion
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
goar1() { export AWS_DEFAULT_REGION='us-east-1'; }
goar2() { export AWS_DEFAULT_REGION='us-east-2'; }
goap1() { export AWS_PROFILE='first'; }
goap2() { export AWS_PROFILE='default'; }

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

## 
## Assume Account Role - assume AWS account roles
##   Original script by D. Shulz; modified to avoid a temp file 
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


## 
## JAVA stuff, in case we use it
## 
if [[ -z "${JAVA_HOME}" ]]; then
    if [[ $(which java >/dev/null 2>&1) ]]; then 
        JAVA_HOME="$(java -XshowSettings:properties -version 2>&1 | \
            sed -ne '/java\.home/ s/.*= *//p')"
    fi
fi
#if [ ${JAVA_HOME:+x} ]; then export JAVA_HOME; fi
if [[ ${JAVA_HOME:+x} ]]; then
    export JAVA_HOME
    pathadd "${JAVA_HOME}/bin"
fi


## 
## Linux
## 
## 
## Manually start a window manager if booting Linux to a console
##   Purposefully not indented to avoid breaking `showfuncs`
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
            { { echo -n "File \"${i}\" does not exist. Create? [yN] " && \
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
    [[ -e "/Applications/Visual Studio.app" ]] && \
        vs() { open -a "Visual Studio" "${@}"; }
    [[ -e "/Applications/Visual Studio Code.app" ]] && \
        vs() { open -a "Visual Studio Code" "${@}"; }

    LYNX='/Applications/Lynxlet.app/Contents/Resources/lynx/bin/lynx'
    [[ -f "${LYNX}" ]] && alias lynx="${LYNX}"

    [[ "${UN}" =~ "^ATL" ]] && BREW_HOME="${HOME}"/homebrew

    ## Google Chrome
    ## 
    chrome() { open -a "Google Chrome"; }
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
    ## 
    show() {
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
            #           activate
                    end tell
                on error
                    display dialog "Could not reveal files:\n" & FILE_array as string
                end try
                return "Found " & files_found_count & " files to display."
            end run'
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
    ## JAVA_HOME on MacOS
    ## 
    ## https://stackoverflow.com/questions/64968851/could-not-find-tools-jar-please-check-that-library-internet-plug-ins-javaapple
    ## 
    ## /usr/libexec/java_home -V 2>&1 | awk '/JavaVirtualMachines/{print $NF}'
    ##   /Library/Java/JavaVirtualMachines/jdk1.8.0_211.jdk/Contents/Home
    TJH="$(/usr/libexec/java_home -V 2>&1 | \
        awk '/JavaVirtualMachines/{print $NF}')"
    [ -d ${TJH} ] && JAVA_HOME=$TJH
    [[ ${JAVA_HOME:+x} ]] && export JAVA_HOME


    ## 
    ## Perl Environment
    ## 
    #PATH="/Users/${USER}/perl5/bin${PATH:+:${PATH}}"
    #PERL5LIB="/Users/${USER}/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
    #PERL_LOCAL_LIB_ROOT="/Users/${USER}/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
    #PERL_MB_OPT="--install_base \"/Users/${USER}/perl5\""
    #PERL_MM_OPT="INSTALL_BASE=/Users/${USER}/perl5"
    #export PATH PERL5LIB PERL_LOCAL_LIB_ROOT PERL_MB_OPT PERL_MM_OPT

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
fi      ## /MacOS

## Import settings or functions that may contain proprietary references  
## that cannot be easily obscured with regex or other references from 
## a separate configuration file to allow the base shell resource file 
## to be shared between a variety of systems.
## 
[[ -f "${SHELL_STARTUP_FPATH}.work" ]] && source "${SHELL_STARTUP_FPATH}.work"


