#!/bin/bash

if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(ssh-agent -s) >/dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
