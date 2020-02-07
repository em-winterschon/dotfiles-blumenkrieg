#!/bin/bash
dconf dump / > dconf.global-settings-gnome3_$HOSTNAME.conf
dconf dump /org/gnome/desktop/wm/keybindings/ > gnome3.keyboard-remapping-generic-keys.conf
dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > gnome3.keyboard-remapping-media-keys.conf
