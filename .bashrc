# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

# exec zsh if possible and this is a login shell
[ "${0:0:1}" == "-" -a -x /bin/zsh ] && exec /bin/zsh -l
