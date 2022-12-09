#!/usr/bin/env bash
#
# usage: ./dotfiles-install.sh
#
# All subdirs of this repo will be traversed unless the subdir contains a `.dotfiles.ln` file, in which case the subdir
# will be symlinked at the appropriate level, and that dir will not be traversed.
set -euo pipefail


cd "$(dirname "$0")"
dotfiles_root="$PWD"
dirents=()


function log_exec() {
    local rc
    set -x
    "$@"
    { rc=$?; set +x; } 2>/dev/null
}


function relfromhome() {
    echo ${PWD##$HOME/}
}


function relfromdotfilesroot() {
    echo ${PWD##$dotfiles_root}
}


function relfromsubdir() {
    local rel="$(relfromhome)"
    local slashes=${rel//[^\/]}
    local depth=${#slashes}
    for i in $(seq 1 $depth); do echo -n '../'; done
}


function dirents() {
    dirents=()
    while read dirent; do
        case "$dirent" in
            .|..|.git|.gitignore|dotfile-install.sh|*.sw?)
                continue
                ;;
            *)
                dirents+=("$dirent")
                ;;
        esac
    done < <(/bin/ls -1a)
}


function makelink() {
    local target="$1"
    local link_name="$2"
    if [ ! -d "$(dirname "$link_name")" ]; then
        log_exec mkdir -p "$(dirname "$link_name")"
    fi
    if [ ! -h "$link_name" ]; then
        log_exec ln -s "$target" "$link_name"
    fi
}


function install_dir() {
    pushd "$1"
    dirents
    local relfromhome="$(relfromhome)"
    local relfromsubdir="$(relfromsubdir)"
    local relfromdotfilesroot="$(relfromdotfilesroot)"
    for f in "${dirents[@]}"; do
        if [ -d "$f" -a ! -f "$f/.dotfiles.ln" ]; then
            install_dir "$f"
        elif [ -d "$f" -o -f "$f" ]; then
            makelink "${relfromsubdir}${relfromhome}/${f}" "${relfromsubdir}..${relfromdotfilesroot}/${f}"
        else
            echo "skipping unknown file type: $f"
        fi
    done
    popd
}


install_dir .
