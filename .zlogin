# .zlogin is only read during login shells

# maintain ssh agent forward in tmux
if [ -n "$TMUX" ]; then
    # inside tmux
    export SSH_AUTH_SOCK="${HOME}/.ssh/ssh_auth_sock"
elif [ -n "$SSH_TTY" -a "$SSH_AUTH_SOCK" ]; then
    # ssh non-tmux login shell
    ln -sf "$SSH_AUTH_SOCK" "${HOME}/.ssh/ssh_auth_sock"
fi
