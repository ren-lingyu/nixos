#!/usr/bin/env sh

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTION]...

Options:
  -m, --make      Run make with custom Makefile (~/org/config/Makefile)
  -p, --push      Sync ~/org to nutstore:WSL/org via rclone
  -c, --clone     Sync nutstore:WSL/org to ~/org via rclone
  -h, --help      Show this help message

If no option is given, the script defaults to entering ~/org and
preparing the make function (same as --make).
EOF
}

case "$1" in
    "-h"|"--help")
	show_help
	exit 0
	;;
    "-m"|"--make")
	make() { command make -f ~/org/config/Makefile $@; }
	;;
    "-t"|"--texlive")
	shift
	~/org/config/texlive.sh "$@"
	;;
    "-p"|"--push")
	rclone sync "$HOME/org" "nutstore:WSL/org" \
               --create-empty-src-dirs \
               --exclude ".git/**" \
               --exclude ".git" \
               --transfers 2 \
               --checkers 4 \
               --low-level-retries 10 \
               --retries 10 \
               --retries-sleep 10s \
               --progress
	;;
    "-c"|"--clone")
	rclone sync "nutstore:WSL/org" "$HOME/org" \
               --create-empty-src-dirs \
               --exclude ".git/**" \
               --exclude ".git" \
               --transfers 2 \
               --checkers 4 \
               --low-level-retries 10 \
               --retries 10 \
               --retries-sleep 10s \
               --progress
	;;
    *)
	cd ~/org
	make() { command make -f ~/org/config/Makefile $@; }
	;;
esac
