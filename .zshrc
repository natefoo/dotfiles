# .zshrc is only read during interactive shells

bindkey -v

# env stuff that's specific to an interactive shell

export PAGER='less'
export EDITOR='vi'

# this was useful on Solaris...
#[ -n `whence vim` ] && export EDITOR='vim' || export EDITOR='vi'

# this was not initially necessary, but now it is
[ "$HOST" = "weyerbacher" -a "$DISPLAY" = ":0" ] && export PASSWORD_STORE_X_SELECTION='primary'

# may not be suitable for all
#stty erase 

alias ls="$LS -F"
alias ll="$LS -Fl"
alias lla="$LS -Fla"
alias lh="$LS -Flh"
alias lrt="$LS -Flhrt"
alias lsd="$LS -Fld"
alias r='screen -r'
alias rd='screen -rd'
alias aki='kinit ; aklog'
alias akr='kinit -R ; aklog'

# hg/galaxy aliases
alias central='hg clone ssh://hg@bitbucket.org/galaxy/galaxy-central'
alias qdiff='hg diff -r $(hg parents -r qbase --template "#rev#") -r qtip'
alias stage='pass ansible/vault/usegalaxy | ansible-playbook -i stage/inventory galaxy.yml --vault-password-file=/bin/cat'
alias production='pass ansible/vault/usegalaxy | ansible-playbook -i production/inventory galaxy.yml --vault-password-file=/bin/cat'

# slurm aliases
alias sqj="squeue -o '%i %P %2t %.10M %j'"

# courtesy dave b.
grepvi() {
    vim `grep -Hni "$1" "$2" | awk -F ":" '{print $1 " +" $2}' | head -n 1`
}

# get homebrew zsh functions
if [ -d "/usr/local/share/zsh/site-functions" ]; then
    fpath+=(/usr/local/share/zsh/site-functions)
fi

# enable compsys completion.
autoload -U compinit
# use -u to ignore the brew-owned files in fpath
compinit -u


# case-insensitive (uppercase from lowercase) completion
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
## case-insensitive (all) completion
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
## case-insensitive,partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

## Prompt magic support
set_krb5princ() {
    KRB5PRINC=`klist 2>/dev/null | grep "^Default principal: " | awk '{print $NF}'`
    [ -z "$KRB5PRINC" ] && KRB5PRINC=`klist 2>/dev/null | grep "^        Principal: " | awk '{print $NF}'`
    t_arr=(${(s:@:)KRB5PRINC})
    KRB5USER=$t_arr[1]
    KRB5REALM=$t_arr[2]
    unset t_arr

    case $KRB5REALM in
        BX.PSU.EDU) KRB5SHORTREALM='BX' ;;
        GALAXYPROJECT.ORG) KRB5SHORTREALM='GXY' ;;
        *) KRB5SHORTREALM="$KRB5REALM" ;;
    esac
}

set_afsid() {
    AFSID=
    [ -d /afs ] && AFSID=$(tokens | awk '$2 == "(AFS" {print $4}' | awk -F')' '{print $1}')
}

## Override commands
_kcmd() {
    cmd=$1; shift
    opt=$1; shift


    # never automatically aklog/unlog
    case "$@" in 
        *${opt}*)
            `whence -p $cmd` "$@" && set_krb5princ
            ;;
        *)
            `whence -p $cmd` $opt "$@" && set_krb5princ
            ;;
    esac
}

kinit() {
    _kcmd kinit --no-afslog "$@"
}

kdestroy() {
    _kcmd kdestroy --no-unlog "$@"
}

aklog() {
    `whence -p aklog` "$@"
    set_afsid
}

unlog() {
    `whence -p unlog` "$@"
    set_afsid
}

## Prompt magic
KENV='default'
[ -z "$KRB5PRINC" ] && set_krb5princ
[ -z "$AFSID" ] && set_afsid
case "$TERM" in
    xterm|xtermc|xterm-color|rxvt-unicode|linux)
        precmd() {
            if [ -n "$TITLE" ]; then
                print -Pn "\e]0;$TITLE: %n@%m: %~\a"
            else
                print -Pn "\e]0;%n@%m: %~\a"
            fi

            case "$VIRTUAL_ENV" in
                '')         VENV_PROMPT="" ;;
                *)          VENV_PROMPT="(%F{yellow}${VIRTUAL_ENV:t}%f)" ;;
            esac
            case "$PASSENV" in
                ''|default) PENV_PROMPT="" ;;
                *)          PENV_PROMPT="(%F{cyan}${PASSENV}%f)" ;;
            esac
            case "$USER" in
                root)       USER_PROMPT="%F{red}${USER}%f" ;;
                nate)       USER_PROMPT="%F{green}${USER}%f" ;;
                *)          USER_PROMPT="%F{magenta}${USER}%f" ;;
            esac
            case "$KRB5PRINC" in
                */admin@*)  KRB5_PROMPT=";%F{red}${KRB5USER}@${KRB5SHORTREALM}%f" ;;
                nate@*)     KRB5_PROMPT=";%F{magenta}${KRB5USER}@${KRB5SHORTREALM}%f" ;;
                *@*)        KRB5_PROMPT=";%F{yellow}${KRB5USER}@${KRB5SHORTREALM}%f" ;;
                "")         KRB5_PROMPT="" ;;
                *)          KRB5_PROMPT=";%F{magenta}${KRB5PRINC}%f" ;;
            esac
            case "$KENV" in
                default)    KENV_PROMPT="" ;;
                *)          KENV_PROMPT="(%F{magenta}${KENV}%f)" ;;
            esac
            case "$AFSID" in
                2048)       AFS_PROMPT="%F{cyan}%#%f" ;;
                10001)      AFS_PROMPT="%F{red}%#%f" ;;
                "")         AFS_PROMPT="%f%#" ;;
                *)          AFS_PROMPT="%F{magenta}%#%f" ;;
            esac
            export PROMPT="${VENV_PROMPT}${PENV_PROMPT}${USER_PROMPT}${KRB5_PROMPT}${KENV_PROMPT}@%F{cyan}%m%f${AFS_PROMPT} "
        }
    ;;
esac

export RPROMPT="%F{yellow}%~%f"

## Useful things maybe
function pgr() {
    pgrep -f $1 | xargs ps uwwp
}

function dotpath() {
    pwd_arr=(${(s:/:)PWD})
    [ "${pwd_arr[1]}" != 'afs' ] && return
    if [ ${${pwd_arr[2]}[1]} = '.' ]; then
        cd /afs/${${pwd_arr[2]}[2,-1]}/${(j:/:)pwd_arr[3,-1]}
    else
        cd /afs/.${(j:/:)pwd_arr[2,-1]}
    fi
}

function ldapedit() {
    case "$1" in
    "")
        echo 'usage: ldapedit <ou>'
        ;;
    *)
        EDITOR=vim ldapvi -Y GSSAPI -h ldap-1 -b ou=$1,dc=bx,dc=psu,dc=edu
        ;;
    esac
}

function ldapedit() {
    # ldapvi -Y EXTERNAL -h ldapi:/// -b cn=config
    case "$1" in
    "")
        echo 'usage: ldapedit <ou>'
        echo 'usage: ldapedit config <server>'
        ;;
    config)
        case "$KRB5REALM" in
            BX.PSU.EDU)
                EDITOR=vim ldapvi -Y GSSAPI -h $2.bx.psu.edu -b cn=config
                ;;
            GALAXYPROJECT.ORG)
                EDITOR=vim ldapvi -Y GSSAPI -h $2.galaxyproject.org -b cn=config
                ;;
            *)
                echo "error: get tickets"
                ;;
        esac
        ;;
    *)
        case "$KRB5REALM" in
            BX.PSU.EDU)
                EDITOR=vim ldapvi -Y GSSAPI -h ldap-1.bx.psu.edu -b ou=$1,dc=bx,dc=psu,dc=edu
                ;;
            GALAXYPROJECT.ORG)
                EDITOR=vim ldapvi -Y GSSAPI -h ldap1.galaxyproject.org -b ou=$1,dc=galaxyproject,dc=org
                ;;
        esac
        ;;
    esac
}


# TODO: galaxyproject.org
function ipmi() {
    case "$2" in
        "")
            echo 'usage: ipmi <host> sol'
            echo 'usage: ipmi <host> <pass> <pxe|off|on|reset|ipmitool command ...>'
            ;;
        sol)
            ipmitool -I lanplus -H $1 -U root sol activate
            ;;
        *)
            case "$3" in
                "")
                    echo 'usage: ipmi <host> sol'
                    echo 'usage: ipmi <host> <pass> <pxe|off|on|reset|ipmitool command ...>'
                    ;;
                pxe)   ipmitool -I lanplus -H $1 -U root -P $2 chassis bootdev pxe  ;;
                off)   ipmitool -I lanplus -H $1 -U root -P $2 chassis power off    ;;
                on)    ipmitool -I lanplus -H $1 -U root -P $2 chassis power on     ;;
                reset) ipmitool -I lanplus -H $1 -U root -P $2 chassis power reset  ;;
                *)     ipmitool -I lanplus -H $1 -U root -P $2 $*[3,$#-1]           ;;
            esac
            ;;
    esac
}

## Kerberos env support
typeset -A KENVS
[ -z "$DEFAULT_KRB5CCNAME" ] && export DEFAULT_KRB5CCNAME=`klist 2>&1 | egrep ' (cache|No ticket file):' | awk '{print $NF}'`
KENVS[default]="$DEFAULT_KRB5CCNAME"
KENV="default"
kenv() {
    env=$1
    [ -z "$env" ] && env='default'
    [ -z "$KENVS[$env]" ] && KENVS[$env]="/tmp/krb5cc_${UID}_${env}"
    if [ "$KRB5CCNAME" = "$KENVS[$env]" ]; then
        echo "Already in '${env}' Kerberos environment"
    else
        export KRB5CCNAME="$KENVS[$env]"
        KENV=$env
        set_krb5princ
    fi
}

## pass env support
typeset -A PASSENVS
PASSENVS[default]="$HOME/.password-store"
export PASSWORD_STORE_DIR=$PASSENVS[default]
PASSENV='default'
function penv () {
    env=$1
    [ -z "$env" ] && env='default'
    [ -z "$PASSENVS[$env]" ] && PASSENVS[$env]="$HOME/.password-store-${env}"
    if [ "$env" = "$PASSENV" ]; then
        echo "Already in '${env}' pass environment"
    else
        export PASSWORD_STORE_DIR="$PASSENVS[$env]"
        PASSENV=$env
    fi
}

## gpg-agent
shorthost=$(hostname -s)
gpg_hosts=(weyerbacher fanboy galaxy01)
gpg_agent_info="${HOME}/.gnupg/gpg-agent-info-$shorthost"

start_gpg_agent() {
    eval $(gpg-agent --daemon --write-env-file $gpg_agent_info)
}

# http://stackoverflow.com/questions/5203665/zsh-check-if-string-is-in-array
if [[ ${gpg_hosts[(i)$shorthost]} -le ${#gpg_hosts} ]]; then
    if [ -f $gpg_agent_info ]; then
        . $gpg_agent_info
        export GPG_AGENT_INFO
        [ "`ps -p ${(z)${(ps#:#)GPG_AGENT_INFO}[-2]} -o comm=`" != 'gpg-agent' ] && start_gpg_agent
    else
        start_gpg_agent
    fi
fi
