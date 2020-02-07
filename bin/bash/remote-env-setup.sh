#!/bin/bash
#------------------------------------------------------------------------------#
#-- Name    : remote-env-setup.sh
#-- Purpose : sets up my preferred settings on a remote node
#-- Author  : Madeline Everett <madeline.everett@tubemogul.com>
#-- Repo    : gerrit.tubemogul.info:29418/sandbox/madeline.everett
#-----------:
#-- Date    : 2016-09-13
#-- Version : 1.2
#------------------------------------------------------------------------------#


sudo /bin/rm -rf /home/madeline.everett/.ssh
mkdir /home/madeline.everett/.ssh
chmod 700 /home/madeline.everett/.ssh

echo "ssh-dss AAAAB3NzaC1kc3MAAACBANZ9ZiJVCsPB/hU2fCEI8PHVJQ5d7d2lXQwfKHNVLx01gaPMdQ0dY050bm8tsFJwDLr9dqH1+v8TuN1pzdYnu98WUgL4v+ASaMqWSZtdfIntjnl4pPtclr/+LfFrW9/r6dO78gvgH5UFmkQ6zY4Y1qb8My3OMGw6khKnsWMFiRWDAAAAFQDW+jeMTJs3DCb5p/vHs8iTt8E2KQAAAIAibItNklX6jLk+zFPKrkjWsj0y5MJMSDxNO8NC761PvEkAxxmgTjUjUnBHMHsuSFwbloIFf2sErd9RQPpjiin+7PrOBB4DIObyY/zAMyBQKvnmhq4v5OnQGNCpLEZw8aOSVbrcTJnmHUtcq/UoS0CjS4yxSn/Cux2Ca67iXaAy7AAAAIAE4eS5G2jrxW23m88tQ7nm+c/hpsHFmFMKJQu8ypAKxyNROtXksdnjb02tWFBMPVhwx+C3d9Lx8gxT6nkECqo6t1fY93hv0VINS1hCZ/05JPLQCpi2FXiCsqWiulE9P6uU9IYIpgqaHOOpnmwxZAcgySDdYr61seWdlwg4MBPzDA== madeline.everett@tubemogul.com" > /home/madeline.everett/.ssh/authorized_keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyj6wgi4mKheeEvHr8lw4uauKkpiCpIYgiGhNrJiZLZpxuivtG7DWc+kAenz5WH/muE/
ag2Ck9EW3gKD9uProWoiZXj2AOpbaEIZZrQQ+gmmfBk3+g+DqQd9pyvnYUvpuOMNR5IFQ38v2f7A+llZMRryHoNBH3QjEhpLidODtq8xMHkjgzHaRmypGsugOeJCDYzeD32FCifjFASz8QHnjmzdzPjZNJkxXZVlMWxrYGhpKjGkyVwb4DisrOm9J3UL6Orm3vAHwKd32VS8nwOr2kfUpkF8WmlER4EZmZPqB/XYl6SdlflYdZv60gIS+siydmYJJ4LIvbYa4+Y8PQAtqD madeline.everett@tubemogul.com" >> /home/madeline.everett/.ssh/authorized_keys

chmod 644 /home/madeline.everett/.ssh/authorized_keys
chown -R madeline.everett: /home/madeline.everett/.ssh
sudo cp /root/.my.cnf /home/madeline.everett/
sudo touch /home/madeline.everett/.mysql_history
sudo chown madeline.everett: /home/madeline.everett/.mysql_history
sudo chown madeline.everett: /home/madeline.everett/.my.cnf
sudo apt-get install emacs24-nox -y || sudo apt-get install emacs23-nox -y

/bin/rm -f $HOME/.bashrc
/bin/rm -f $HOME/.screenrc
/bin/rm -f $HOME/.bash_profile
/bin/rm -f $HOME/.emacs


cat<<'EOF' >> $HOME/.emacs
(global-unset-key (kbd "C-z"))
(setq make-backup-files nil)
(setq backup-inhibited t)
(setq auto-save-default nil)
EOF

cat<<'EOF' >> $HOME/.bash_profile
source $HOME/.bashrc
EOF

wget https://raw.githubusercontent.com/madeline-everett/superbash/master/dot.bashrc --output-document=$HOME/.bashrc

cat <<'EOF' >> /home/madeline.everett/.screenrc
## ScreenRC file from https://bitbucket.org/madeline-everett/dotfiles
startup_message off
vbell off

## Control key, set to Ctl-z (removes emacs clobber)
escape ^Bb

## Sets
defnonblock on
defutf8 on
attrcolor b ".I"
term xterm-256color
termcapinfo xterm 'Co#256:AB=\E[48;5;%dm:AF=\E[38;5;%dm'
defbce "on"
defscrollback 65535

# Enables use of shift-PgUp and shift-PgDn
termcapinfo xterm|xterms|xs|rxvt|bash|ssh ti@:te@

hardstatus alwayslastline 
hardstatus string '%{= Kd} %{= Kd}%-w%{= Kr}[%{= KW}%n %t%{= Kr}]%{= Kd}%+w %-= %{KG} %H%{KW}|%{KY}%101`%{KW}|%D %M %d %Y%{= Kc} %C%A%{-}'
bind f eval "hardstatus ignore"
bind F eval "hardstatus alwayslastline"
EOF

echo "complete"
