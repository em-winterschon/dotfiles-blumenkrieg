## Install git-lfs driver
```
cd /tmp
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash
yum install git-lfs
```

## Nvidia driver
```
sudo systemctl set-default multi-user.target
yum install elfutils-libelf-devel
```

- add the following to /etc/default/grub
```
rd.driver.blacklist=nouveau nouveau.modeset=0
```

- execute the following, then reboot, login as root and install the NVIDIA .run file
```
grub2-mkconfig
reboot
```

## Adaptec control app
- copy from dotfiles/etc/binaries/arcconf /usr/local/bin/

## Initial Web downloads for latest RPM files
- keeper password manager
- zoom: https://zoom.us/download?os=linux
- lnav: http://lnav.org/downloads

```
yum localinstall keeperpasswordmanager-14.10.0-1.x86_64.rpm
yum localinstall zoom_x86_64.rpm
yum localinstall iozone-3-489.x86_64.rpm
```

## Copy Applications dir from workstation.bootstrap.d
- Conky
```
cp -R ~/Projects/dotfiles/workstation.bootstrap.d/rootfs/home/mwinterschon/Applications ~/
```

## Git repos to configure
- Secure
- Dotfiles (branch = blumenkrieg)
- Superbash
- Transcrypt (copy updated transcrypt binary from dotfiles/bin/binaries/truecrypt to /usr/local/bin)

## Load Gnome3 Dconf Settings
Change to dotfiles repo directory
```
cd gnome3
dconf load /org/gnome/desktop/wm/keybindings/ < gnome3.keyboard-remapping-generic-keys.conf
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < gnome3.keyboard-remapping-media-keys.conf
dconf load /org/gnome/terminal/ < gnome3.terminal.blumenkrieg.conf
dconf load / < gnome3.desktop-init-prefs.conf
```

## Terminal commands in pseudo-sequential sequence
- copy yum.repos.d files from rootfs/ directory
```
yum update
yum --enhancement --security distro-sync
yum install -y tmux emacs-nox iotop nethogs htop snapd python3-devel NetworkManager-openvpn-gnome
yum install -y gnome-tweaks libcurl-devel fio sysbench p7zip* mysql mysql-common jq
yum install -y slack google-chrome-stable chromium ImageMagick7
yum install -y golang npm
```

## Python module installs
```
sudo pip3 install glances tmuxp
```

## NPM Installs
```
cd ~/
sudo npm install -g turbo-git
```

## Snapd Setup + Installs
```
yum install snapd
systemctl enable snapd
systemctl enable --now snapd.socket
systemctl restart snapd
snap install snap-store
snap install spotify
snap install pycharm-professional
snap install datagrip
```

## Vivaldi
- login to sync
- upload stylish backup from dotfiles/etc/stylish
- upload ublock backup from dotfiles/etc/ublock

## Chef Stuff
```
curl https://omnitruck.chef.io/install.sh > omnitruck_install
sudo ./omnitruck_install -P chefdk -v 3.6.57
chef gem install knife-block
chef gem install fpm
```

## Etc Settings
```
sudo cp ~/bin/bash/one.sh /usr/local/bin/
sudo cp ~/bin/bash/pingrate-dns /usr/local/bin/
sudo cp ~/etc/blumenkrieg/etc/crontab /etc/crontab
sudo cp ~/etc/blumenkrieg/etc/sysctl.d/idea.conf /etc/sysctl.d/
sudo cp ~/etc/blumenkrieg/etc/X11/xorg.conf /etc/X11/
sudo cp ~/etc/blumenkrieg/etc/grc.conf /etc/grc.conf
sudo cp ~/bin/grc /usr/local/bin/
sudo cp ~/bin/grcat /usr/local/bin/
```
