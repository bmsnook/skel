
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

macvim() { for i in "${@}"; do
    [[ -f "${i}" ]] && open -a MacVim "${i}" || \
        ( echo -n "File \"${i}\" does not exist. Create? [yN] " && \
        read reply && [[ "$reply" =~ [yY] ]] ) && \ 
        ( touch "${i}" && open -a MacVim "${i}" ) || : ;
    done;
}

