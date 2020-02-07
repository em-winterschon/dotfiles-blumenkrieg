#!/bin/bash
echo "Opening proxy for https://localhost:32400"
echo "ctrl-c to stop"
ssh -L 32400:localhost:32400 root@bunny -N 
