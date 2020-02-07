#!/usr/bin/env bash
for each in `cat ~/etc/sync`; do
    echo "++++ Syncing to host: $each"
    rsync ~/.bashrc $each:.
    rsync -av ~/.emacs* $each:.    
    rsync ~/.gitconfig $each:.
    rsync ~/.screenrc $each:.
    rsync ~/.tmux.conf $each:.
    echo;
done

for each in `cat ~/etc/sync`; do
    echo "++++ Syncing to host: perfadmin@$each"
    USERHOST="perfadmin@$each"
    rsync ~/.bashrc $USERHOST:.
    rsync -av ~/.emacs* $USERHOST:.    
    rsync ~/.gitconfig $USERHOST:.
    rsync ~/.screenrc $USERHOST:.
    rsync ~/.tmux.conf $USERHOST:.
    echo;
done
