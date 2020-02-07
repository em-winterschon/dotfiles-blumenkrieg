#!/bin/bash
## Purpose: command to use for proxying the required ports to connect TRex GUI to this server.
# REMOTE = IP of this server
# USER = username for ssh
# KEY = ssh key for user

REMOTE="test-sfo9942"
USER="mwinterschon"
KEY="$HOME/.ssh/_keys/mwinterschon.fastly.id_rsa"

ssh -v -N -i $KEY \
    -L 4500:$REMOTE:4500 \
    -L 4501:$REMOTE:4501 \
    -L 4507:$REMOTE:4507 \
    -L 8090:$REMOTE:8090 \
    $USER@$REMOTE
