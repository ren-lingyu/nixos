#!/usr/bin/env sh

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTION]...

Options:
  -m, --make      Set a function to run make with custom Makefile (~/org/config/Makefile)
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
    *)
	cd ~/org
	make() { command make -f ~/org/config/Makefile $@; }
	;;
esac
