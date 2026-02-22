#!/bin/bash

case "$1" in
    "-m"|"--make")
	make() { command make -f ~/org/config/Makefile $@; }
	;;
    "-s"|"--sync")
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
    *)
	cd ~/org
	make() { command make -f ~/org/config/Makefile $@; }
	;;
esac
