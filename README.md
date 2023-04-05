# skel
As a long-time zsh user who has often had to work on systems 
that only have bash installed, I have long worked to bring the 
same convenience I enjoy in zsh to bash. 

There are a few notable differences even casual users may notice: 
- functions defined on a single line in bash need a terminating semicolon
- zsh and bash use different variables for parts of the PS1 prompt
- zsh "which" returns both binary paths or functions
- bash "which " returns only binary paths; 
    use "type FUNCTION_NAME" or "typeset -f FUNCTION_NAME" to see 
    defined functions

Tab completion in bash continues to be a thorn in my side.
Zsh just makes things much easier by default, particularly being able to 
tab-complete previous commands/arguments when invoked with "$!" or "!!", 
is incredibly convenient and the lack of that makes me grumpy when I need 
to use bash. 

That being said, most functions and utilities are fairly easy to keep 
consistent between the two. Heavy reliance on awk/gawk helps eliminate 
differences between array implementations in zsh and bash.

This "skel" directory includes both .bashrc and .zshrc files.
I've stopped hardcoding a "proper" shebang at the beginning of the file 
because it's not really designed to be executed, but to be sourced, so 
the proper shell is already invoking it. The first line is strictly 
informational for the user, not the system.

In fact, in practice, since the files were identical anyway, I've taken 
to copying the file around as '.bashrc' everywhere I use a shell and just 
symlinking .zshrc to point to .bashrc on systems where I am able to use zsh.
