#
# .zshrc, startup file for zsh
# Author: Brian Snook
# Date:   2008-03-28
# Update: 2008-04-23 (fixed bug with multi-line commands in some awks)
# Update: 2008-04-23 (modified so all lines fit in 80-char terminal)
# Update: 2008-05-14 (updated name terminal (nt) default behaviour)
# Update: 2008-05-23 (added findbin)
# Update: 2022-10-07 (cleanup of old acct refs; removed email address)
# 

# Example shell startup provided to get started
# Please modify to suit your needs.
#

##
## STARTUP FILE
##
## Define the startup file (this file) for use later
##
SHELL_STARTUP=.zshrc

echo "INFO: READING ${SHELL_STARTUP}"


## 
## JAVA_HOME
## 
# MacOS
# https://stackoverflow.com/questions/64968851/could-not-find-tools-jar-please-check-that-library-internet-plug-ins-javaapple
## 
## /usr/libexec/java_home -V 2>&1 | awk '/JavaVirtualMachines/{print $NF}'
##   /Library/Java/JavaVirtualMachines/jdk1.8.0_211.jdk/Contents/Home
TJH=`/usr/libexec/java_home -V 2>&1 | awk '/JavaVirtualMachines/{print $NF}'`
[ -d ${TJH} ] && JAVA_HOME=$TJH
export JAVA_HOME

##
## PATH
##
## Instead of just clobbering our PATH with directories that may 
## not be appropriate for this server, try to be intelligent about what we add
##
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
TPD=~/anaconda3/bin              && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/ucb                     && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/ccs/bin                 && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/local/ssl/bin           && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/krb5/bin                && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/krb5/sbin               && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/kerberos/sbin           && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/kerberos/bin            && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/java/jre1.5.0_02/bin    && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/java1.2/bin             && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/perl5/bin               && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/X11R6/bin               && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/etc/X11                     && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/opt/sfw/bin                 && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/local/apache/bin        && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/apache/bin              && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/openwin/bin             && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/xpg4/bin                && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/dt/bin                  && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/opt/google/chrome           && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/Applications/Bluefish.app/Contents/MacOS && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=~/Library/Python/3.8/bin     && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/local/opt/qt@5/bin      && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/local/Cellar/qt@5/5.15.3/bin && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=/usr/local/go/bin            && [ -d $TPD ]  &&  PATH=$PATH:$TPD
TPD=${JAVA_HOME}/bin             && [ -d ${TPD} ] && PATH=$PATH:$TPD

if [[ `uname -s` == "Darwin" ]]; then
	# For compilers to find qt@5 you may need to set:
	export LDFLAGS="-L/usr/local/opt/qt@5/lib -L/usr/local/opt/openssl@3/lib"
	export CPPFLAGS="-I/usr/local/opt/qt@5/include -I/usr/local/opt/openssl@3/include"

	# For pkg-config to find qt@5 you may need to set:
	export PKG_CONFIG_PATH="/usr/local/opt/qt@5/lib/pkgconfig:/usr/local/opt/openssl@3/lib/pkgconfig"
fi

##
## MANPATH
##
## Instead of just clobbering our MANPATH with directories that may 
## not be appropriate for this server, try to be intelligent about what we add
##
MANPATH=/usr/local/man
[ -d /usr/share/man ]            && MANPATH=$MANPATH:/usr/share/man
[ -d /usr/local/share/man ]      && MANPATH=$MANPATH:/usr/local/share/man
[ -d /usr/man ]                  && MANPATH=$MANPATH:/usr/man
[ -d /usr/krb5/man ]             && MANPATH=$MANPATH:/usr/krb5/man
[ -d /usr/kerberos/man ]         && MANPATH=$MANPATH:/usr/kerberos/man
[ -d /usr/local/ssl/man ]        && MANPATH=$MANPATH:/usr/local/ssl/man
[ -d /usr/java/jre1.5.0_02/man ] && MANPATH=$MANPATH:/usr/java/jre1.5.0_02/man
[ -d /usr/java1.2/man ]          && MANPATH=$MANPATH:/usr/java1.2/man
[ -d /usr/X11R6/man ]            && MANPATH=$MANPATH:/usr/X11R6/man
[ -d /usr/local/apache/man ]     && MANPATH=$MANPATH:/usr/local/apache/man
[ -d /usr/local/mysql/man ]      && MANPATH=$MANPATH:/usr/local/mysql/man
[ -d /usr/perl5/man ]            && MANPATH=$MANPATH:/usr/perl5/man
[ -d /usr/local/perl/man ]       && MANPATH=$MANPATH:/usr/local/perl/man
[ -d /usr/local/perl5.8.0/man ]  && MANPATH=$MANPATH:/usr/local/perl5.8.0/man
[ -d /usr/openwin/man ]          && MANPATH=$MANPATH:/usr/openwin/man


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
PROMPT="%n@%m:%~%# "


##
## USER
##
## When using shared screen sessions and changing to another user, 
## environment variable $USER gets clobbered.  Fix it.
## NOTE:  "id -un" does not work everywhere (i.e., Solaris 8 default)
##
if [ "x${USER}" = "x" ]; then USER=`id | cut -d \) -f1 | cut -d \( -f2`; fi


export PATH MANPATH PROMPT USER SHELL_STARTUP


##
## SSH-agent
##
if [ -e $HOME/.agent ]; then source $HOME/.agent; fi
mka() { ssh-agent -s > $HOME/.agent && source $HOME/.agent && ssh-add }


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
alias lynx='/Applications/Lynxlet.app/Contents/Resources/lynx/bin/lynx'

looppre() { while true; do read x && echo -n "PREFIX__${x}__" | pbcopy; done; }

##
## LOCATE AWK
##
AWK=
[ -f /usr/local/bin/awk ]       && AWK=/usr/local/bin/awk
[ -f /usr/bin/awk ]             && AWK=/usr/bin/awk
[ -f /bin/awk ]                 && AWK=/bin/awk
[ -f /usr/local/bin/nawk ]      && AWK=/usr/local/bin/nawk
[ -f /usr/bin/nawk ]            && AWK=/usr/bin/nawk
[ -f /bin/nawk ]                && AWK=/bin/nawk
[ -f /usr/local/bin/gawk ]      && AWK=/usr/local/bin/gawk
[ -f /usr/bin/gawk ]            && AWK=/usr/bin/gawk
[ -f /bin/gawk ]                && AWK=/bin/gawk
export AWK


##
## FUNCTIONS (define useful utilities)
##
## Start X in the background, disown the process, 
## and exit, so the parent tty can't be hijacked
##
gox() { 
  startx &
  disown
  (sleep 5 && exit)
}

## 
goweb() { source ${HOME}/.zshrc.more.d/.zshrc.cfg-webcom }
goweb

## Find Awk (or Nawk or Gawk)
##
findawk() {
  AWK=
  [ -f /usr/local/bin/awk ]       && AWK=/usr/local/bin/awk && ls -il ${AWK}
  [ -f /usr/bin/awk ]             && AWK=/usr/bin/awk && ls -il ${AWK}
  [ -f /bin/awk ]                 && AWK=/bin/awk && ls -il ${AWK}
  [ -f /usr/local/bin/nawk ]      && AWK=/usr/local/bin/nawk && ls -il ${AWK}
  [ -f /usr/bin/nawk ]            && AWK=/usr/bin/nawk && ls -il ${AWK}
  [ -f /bin/nawk ]                && AWK=/bin/nawk && ls -il ${AWK}
  [ -f /usr/local/bin/gawk ]      && AWK=/usr/local/bin/gawk && ls -il ${AWK}
  [ -f /usr/bin/gawk ]            && AWK=/usr/bin/gawk && ls -il ${AWK}
  [ -f /bin/gawk ]                && AWK=/bin/gawk && ls -il ${AWK}
  export AWK
  echo "AWK=${AWK}"
}

## Find a Binary or Script in PATH
##
findbin() {
  echo ${PATH} | ${AWK} -F: -v TARGET=$1 '
  {
    for (i=1; i<=NF; i++) {
      cmd=sprintf("if [ -f %s/%s ]; then echo %s/%s; fi",$i,TARGET,$i,TARGET)
      system(cmd)
    }
  }'
}

## Show Functions
##
showfuncs() { ${AWK} '/^[A-Za-z]/&&/\(\)/{print $1}' ${HOME}/${SHELL_STARTUP}; }
echo "INFO: type \"showfuncs\" to list functions defined in ${SHELL_STARTUP}"

## Print the current passwd module info (path, version) from sysadmin/modules
## Assumes your CVS scratch space has been set up as "$HOME/cvs.saroot"
##
awkpass() { 
  ${AWK} '/^\[(gate|)passwd-all(|-qe)\]/,/^$/' ~/cvs.saroot/sysadmin/modules; 
}

## Query ARIN (American Registry for Internet Numbers) for whois info on IPs
##
awhois() { whois -h whois.arin.net $1; }

##
## Use OpenSSL to get the beginning and end dates of a secure certificate
##
certdate() {
  which openssl
  result=$?
  if [ ${result} != 0 ]
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

##
## Use OpenSSL to get the secure certificate info from Issuer to Subject:
##
certinfo() {
  which openssl
  result=$?
  if [ ${result} != 0 ]
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
len() { ${AWK} 'length()>max{max=length()}END{print max}' $1; }
len2() { 
	[[ -f "$1" ]] && ${AWK} 'length()>max{max=length()}END{print max}' "$1" ||\
		echo "$1" | ${AWK} 'length()>max{max=length()}END{print max}'
}

## Name a terminal ("echo -ne" also works instead of "print -Pn")
##
#nt() { print -Pn "\e]0;$1 - %y\a"; }          ## Name Term (nt)
nt() { 
    if [ "x${1}" != "x" ]
      then
      print -Pn "\e]0;$1 - %m\[$$\]\[%l\]\a"
    else
      print -Pn "\e]0;%n@%m($$) - %l\a"
    fi
} ## Name Term (nt)



## Git Stuff
## 
gdiff() { git log $1 | \
	${AWK} -v FN="$1" '/commit/{cmd=sprintf("%s %s",$2,cmd);\
		count++;if(count>=2){exit}}
		END{cmd=sprintf("git diff %s %s",cmd,FN);
		print cmd; system(cmd);close(cmd)}'; }

##
## Color 'ls' (optional)
##
UNAME=`uname -s`

TERM=vt100
if [ $UNAME = "Linux" ]; then
        alias ls='ls --color'
	echo "INFO: 'ls' == 'ls --color' -- type 'unalias ls' to disable"
elif [ $UNAME = "OSF1" ]; then
        export TERM=vt100
elif [ $UNAME = "FreeBSD" ]; then
        export TERM=vt100
elif [ $UNAME = "BSDI" ]; then
        export TERM=vt100
fi

## 
## Print a formatted date suffix
## 
pfd() { date "+__%Y-%m-%d"; }
cppfd() { echo -n `date "+__%Y-%m-%d"` | pbcopy; }

## 
#mlc() { echo "${1}" | tr '[ /:,()A-Z]' '[______a-z]' | sed 's/&/and/' | sed "s/'//" | sed -e 's/!/_/g'; }
mlc() { echo "${1}" | tr '[\[] /:,()A-Z' '[________a-z]' | sed 's/&/and/' | sed "s/'//" | sed -e 's/!/_/g' | sed -e 's/\|//'; }
#mlu() { echo "__${1}" | tr '[ /:,()A-Z]' '[______a-z]' | sed 's/&/and/' | sed "s/'//" | sed -e 's/!/_/g'; }
mlu() { echo "__${1}" | tr '[\[] /:,()A-Z' '[________a-z]' | sed 's/&/and/' | sed "s/'//" | sed -e 's/!/_/g' | sed -e 's/\|//'; }
lmlu() { while true; do read answer; echo "__${answer}" | tr '[ /:,()A-Z]' '[______a-z]' | sed 's/&/and/' | sed "s/'//" | sed -e 's/!/_/g'; done; }
mlu2() { echo "__${*}" | tr '[ /:,()A-Z]' '[______a-z]' | sed 's/&/and/' | sed "s/'//" | sed -e 's/!/_/g'; }
ph() { echo "ph__${1}__" | tr '[ /:,()A-Z]' '[______a-z]' | sed 's/&/and/' | sed "s/'//" | sed -e 's/!/_/g'; }
yp() { echo "yp__${1}__" | tr '[ /:,()A-Z]' '[______a-z]' | sed 's/&/and/' | sed "s/'//" | sed -e 's/!/_/g'; }
sbs() { 
	[[ -f "$1" ]] && sed -e 's/\\//g' "$1" || echo "$1" | sed -e 's/\\//g'
}

## 
## Sound stuff
## 
splay() { for i in "${@}"; do ffplay -nodisp -autoexit -loglevel quiet "${i}"; done; }

## 
## Mac Apps
## 
macvim() { for i in "${@}"; do 
	[[ -f "${i}" ]] && open -a MacVim "${i}" || \
		(echo -n "File \"${i}\" does not exist. Create? [yN] " \
		&& read reply && [[ "$reply" =~ [yY] ]] \
		&& touch "${i}"  && open -a MacVim "${i}") || :
	done; 
}
macvim1() { open -a MacVim "${@}"; }
xc() { open -a Xcode "${@}"; }
vs() { open -a "Visual Studio" "${@}"; }

gojup() { cd ~/Documents/GitHub/Pierian-Data-Complete-Python-3-Bootcamp && ( jupyter-notebook &; jupyter-lab &; ) }

##
## Zsh Options
##
HISTFILE="$HOME/.zsh_history"
HISTSIZE=4096
#TMOUT=36000
TMOUT=0

LOGCHECK=10
WATCHFMT="%B%n%b has %a from %m"
watch=(all)

#EDITOR=emacs
EDITOR=vi
NULLCMD=cat
READNULLCMD=less

# emacs key bindings with bindkey (use arrows for command history)(man zshzle)
bindkey -e                              # emacs key bindings

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
setopt CORRECT_ALL
setopt EXTENDED_HISTORY
setopt GLOB_DOTS
setopt HIST_IGNORE_DUPS
setopt LIST_TYPES
setopt LOGIN
setopt NOBEEP
setopt NOTIFY


##
## More Information
## 
## An example of listing/searching directories using a regular expression
#ls -ld /{,ms/,usr/{,local/}{,share/}}man
#drwxr-xr-x  10 root     bin          512 Jun 16  2005 /usr/local/man
#drwxr-xr-x   4 root     bin          512 Jun 16  2005 /usr/local/share/man
#lrwxrwxrwx   1 root     root          11 May 19  2005 /usr/man -> ./share/man
#drwxr-xr-x  94 root     bin         2048 Jan  5  2006 /usr/share/man

## 
tuny() { ssh -o ServerAliveCountMax=60 -o ServerAliveInterval=90 -L 127.0.0.1:5901:10.0.0.22:5901 -p 22000 bsnook@10.0.0.22 }

## AWS
goar1() { export AWS_DEFAULT_REGION='us-east-1'; }
goar2() { export AWS_DEFAULT_REGION='us-east-2'; }
goap1() { export AWS_PROFILE='first'; }
goap2() { export AWS_PROFILE='default'; }



PATH="/Users/bmsnook/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/bmsnook/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/bmsnook/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/bmsnook/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/bmsnook/perl5"; export PERL_MM_OPT;

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
