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
    append)
        set -A new_elems $@
        ;;
    esac

    for ne in $new_elems; do
        [ ! -d $ne -a ! -h $ne ] && continue
        # so i remember it later, from the inside out:
        # ${(ps#:#)PATH}} - split $PATH on :
        # ${(A) ... } - treat contents (the split path) as an array
        # ${(@M) ... :#$ne} - find anything that matches $ne
        case "$var" in
        path)
            if [ -z ${(@M)${(A)${(ps#:#)PATH}}:#$ne} ]; then
                case "$op" in
                prepend)
                    PATH="$ne:$PATH"
                    ;;
                append)
                    PATH="$PATH:$ne"
                    ;;
                esac
            fi
            ;;
        manpath)
            if [ -z ${(@M)${(A)${(ps#:#)MANPATH}}:#$ne} ]; then
                case "$op" in
                prepend)
                    MANPATH="$ne:$MANPATH"
                    ;;
                append)
                    MANPATH="$MANPATH:$ne"
                    ;;
                esac
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

append_manpath() {
    munge_path manpath append $@
}

prepend_manpath() {
    munge_path manpath prepend $@
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
PATH='/usr/bin'

case "$SYS" in
    linux)
        LS="ls --color"
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

VENVBURRITO_STARTUP="$HOME/.venvburrito/startup.sh"
case "$OS_RELEASE_ID" in
    debian)
        [ -d "$HOME/.venvburrito-stretch" ] && VENVBURRITO_STARTUP="$HOME/.venvburrito-stretch/startup.sh"
        ;;
    ubuntu)
        [ -d "$HOME/.venvburrito-trusty" ] && VENVBURRITO_STARTUP="$HOME/.venvburrito-trusty/startup.sh"
        ;;
esac

# startup virtualenv-burrito
if [ -f $VENVBURRITO_STARTUP ]; then
    . $VENVBURRITO_STARTUP
fi

prepend_path $HOME/bin $HOME/bin/$SYSARCH $HOME/.rvm/bin

