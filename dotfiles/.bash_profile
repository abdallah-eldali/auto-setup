# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
export EDITOR=$(which --skip-alias --skip-functions nvim 2>/dev/null || echo "/usr/bin/vi")
