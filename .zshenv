# .zshenv is always read

# functiony stuff
munge_path() {

    local var=$1
    local op=$2
    shift
    shift

    # reverse the arg list so it prepends in the order you called it
    case $op in
    prepend)
        set -A new_elems ${(Oa)@}
        ;;
    append|pop)
        set -A new_elems $@
        ;;
    esac

    for ne in $new_elems; do
        case "$var" in
        path)
            # $path is a zsh-specific builtin of $PATH as an array
            # ${(@M) ... :#$ne} - find anything that matches $ne
            if [ -z ${(@M)path:#$ne} ]; then
                [ ! -d $ne -a ! -h $ne ] && continue
                case "$op" in
                    prepend)
                        path[1,0]=("$ne")
                        ;;
                    append)
                        path+=("$ne")
                        ;;
                esac
            elif [ "$op" = 'pop' ]; then
                path[$path[(i)$ne]]=()
            fi
            ;;
        esac
    done
}

append_path() {
    munge_path path append $@
}

prepend_path() {
    munge_path path prepend $@
}

pop_path() {
    munge_path path pop $@
}

: ${(AL)U_SYSARCH::=`uname -srm`}
SYS=${(L)U_SYSARCH[1]}
REL=${(L)U_SYSARCH[2]}
ARCH=${(L)U_SYSARCH[3]}
SYSARCH="$SYS-$ARCH"
#: ${SYS:=${(L)U_SYSARCH[1]}}
#: ${REL:=${(L)U_SYSARCH[2]}}
#: ${ARCH:=${(L)U_SYSARCH[3]}}
#: ${SYSARCH:="$SYS-$ARCH"}
export SYSARCH SYS REL ARCH

# defaults
LS='ls'

# This breaks Ansible Molecule since Molecule re-execs zsh, and then loses the venv you've installed Molecule into off
# of $PATH. I don't know why Molecule does this, it's the first time I've ever encountered a program that execs $SHELL
# instead of explicitly calling sh or bash.
#PATH='/usr/bin'

case "$SYS" in
    linux)
        LS="ls --color"
        pop_path /usr/local/games /usr/games
        append_path /bin /usr/sbin /sbin
        prepend_path /usr/local/bin
        ;;
    darwin)
        export CLICOLOR="1"
        export LSCOLORS="ExFxCxDxBxegedabagacad"
        append_path /bin /usr/sbin /sbin
        prepend_path /usr/local/bin
        ;;
esac

# Convert /etc/os-release to env vars
[ -f /etc/os-release ] && eval $(sed -re 's/(^[A-Z_]+)(=.*)/OS_RELEASE_\1\2/' /etc/os-release)

venvsetup() {
    python3 -m venv $HOME/.venvwrapper
    $HOME/.venvwrapper/bin/pip install virtualenvwrapper
}

# use virtualenvwrapper for venv management
if [ -f "$HOME/.venvwrapper/bin/virtualenvwrapper.sh" ]; then
    export WORKON_HOME="$HOME/.virtualenvs"
    VIRTUALENVWRAPPER_PYTHON="$HOME/.venvwrapper/bin/python"
    . "$HOME/.venvwrapper/bin/virtualenvwrapper.sh"
fi

prepend_path $HOME/bin $HOME/bin/$SYSARCH
