export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export PATH=$HOME/.local/bin:$PATH
export GPG_TTY=$(tty)
export $(dbus-launch)

if ! pgrep -x fcitx5 > /dev/null; then
    fcitx5 --disable=wayland -d >/dev/null 2>&1
fi

# if [ -z "$SSH_AUTH_SOCK" ]; then
#     eval $(ssh-agent -s) >/dev/null
#     ssh-add ~/.ssh/id_ed25519 2>/dev/null
# fi
