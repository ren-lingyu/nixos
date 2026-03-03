export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export PATH=$HOME/.local/bin:$PATH
export GPG_TTY=$(tty)
export $(dbus-launch)

# 用于提供在 WSL terminal 中直接打开 VSCode 的 wrapper, 不必允许 Windows PATH 注入. 
export PATH="/mnt/c/Users/Lingyu/AppData/Local/Programs/Microsoft VS Code/bin":$PATH

if ! pgrep -x fcitx5 > /dev/null; then
    fcitx5 --disable=wayland -d >/dev/null 2>&1
fi

# if [ -z "$SSH_AUTH_SOCK" ]; then
#     eval $(ssh-agent -s) >/dev/null
#     ssh-add ~/.ssh/id_ed25519 2>/dev/null
# fi
