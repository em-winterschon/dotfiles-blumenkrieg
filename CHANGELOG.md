# 2.9.8
- updated tmux config and plugins

# 2.9.7
- updated tmux.conf to support pane border info

# 2.9.6
- updated tmux.conf to support C-s toggle for synchronize-panes command
- increased message display time for tmux

# 2.9.5
- adding additional tmuxp profiles

# 2.9.4
- zfs modprobe updated for additional RAM + L2ARC
- bootstrap doc/script for zfs updated for cache + log
- conky update for nvme naming
- scripts configs etc

# 2.9.3
- updated tmuxp profiles
- updated workstation bootstrap doc

# 2.9.2
- updating bootstrap doc for dpkg-dev and perfadmin commands
- updating yum.repos.d for sync

# 2.9.1
- sr-iov check script
- workstation build updates
- tmux configs for Set D
- tmux lab-connect expanded
- configs

# 2.9.0
- updated conky for cpu-monitor script
- re-built globalworkspace venv

# 2.8.9
- updated conky for ZFS and new IO output
- updated conky for dynamic mdraid mount point display

# 2.8.8
- updating grc and conky + others

# 2.8.7
- updating workstation bootstrap doc
- updating config files

# 2.8.6
- updated conky + scripts to support dual socket CPU

# 2.8.5
- cleaning up gnome desktop symlinks

# 2.8.4
- moving to dedicated repo dotfiles-blumenkrieg

# 2.8.3 - blumenkrieg
- migrating files using git-lfs

# 2.8.2 - blumenkrieg
- adding installers and updating system configs to prep for OS reinstall

# 2.8.1 - blumenkrieg
- tmuxp updates
- config updates

# 2.8.0 - blumenkrieg
- added more tmuxp profiles
- updated configs
- updated conkyrc

# 2.7.9 - blumenkrieg
- added iozoneBenchmark tmuxp profile
- added arcstats simple bash script

# 2.7.8 - blumenkrieg
- updating conkyrc to include OS-RAID10 smartctrl temp monitoring via bash script

# 2.7.7 - blumenkrieg
- large update before OS reinstall
- no RPM or other downloaded apps

# 2.7.6 - blumenkrieg
- added X11 config to support 4K modeline with nvidia commercial driver (no wayland support)
- added etc/default/grub file to support disabling of nouveau driver ^

# 2.7.5 - blumenkrieg
- updated global venv
- updated gnome settings

# 2.7.4 - blumenkrieg
- fixed gnome3 font issues, using montserrat

# 2.7.3 - blumenkrieg
- updated gnome3 settings for fonts + scaling

# 2.7.2 - blumenkrieg
- fixed issues with grc config links/dirs/files

# 2.7.1 - blumenkrieg
- various updates

# 2.7.0
- updated bootstrap commands

# 2.6.9
- adding workstation bootstrap files and commands doc
- adding blumenkrieg gnome configs

# 2.6.8
- updated stylish backup
- global conf updates

# 2.6.7
- updated sync-to-hosts.sh to support new functionality and command options
- added dot.grc config dir, .bash_grc alias loading

# 2.6.6
- adding dot.emacs.minimal (bare minimum config for root/basic usage)
- adding dot.emacs.simple (enables packages via gnu-elpa/melpa, no requirements for load-path)

# 2.6.5
- updated .gitignore

# 2.6.4
- updated / added tmuxp profiles

# 2.6.3
- adding globalworkspace-venv
- updating tmuxp profiles

# 2.6.2
- additional updates to .emacs, plugins, functions, macros, etc

# 2.6.1
- major updates to .emacs and related plugins

# 2.6.0
- updating .bash_linux aliases and functions
- added ThinkOrSwim application launcher to gnome3
- various config updates

# 2.5.9
- updating .bash_linux to include grc.log function and hostname matching for fraulein/flowers for dev shortcuts
- various config updates

# 2.5.8
- updating .bash_linux
- updating etc/host files

# 2.5.7
- adding some bash helper scripts, updating some configs

# 2.5.6
- updated tmuxp profiles

# 2.5.5
- minor changes to configs and etc host lists

# 2.5.4
- updating conkyrc
- adding tmuxp profiles
- local settings updates

# 2.5.3
- added grc and grcat to bin/python
- updated some tmuxp profiles

# 2.5.2
- added colored mysql prompt via grc config

# 2.5.1
- adding grc files and modding installer

# 2.5.0
- added tmuxpDjangoLogs alias for tmuxp load django-perftest-logs

# 2.4.9
- userland config updates

# 2.4.8
- bumped localhost back script to v1.5

# 2.4.7
- bumped localhost back script to v1.4

# 2.4.6
- bumped localhost back script to v1.2

# 2.4.5
- added incremental option to localhost backup script
- updated crontab

# 2.4.4
- adding backup-localhost-filesystem.sh script for nightly backups

# 2.4.3
- updating tmuxp profiles

# 2.4.2
- added perftest-django mode for tmuxp
- added stylish backup
- various local settings

# 2.4.1
- re-adding .gitignore

# 2.4.0
- adding tmuxp configs
- adding color profiles
- updating dot.local

# 2.3.9
- cleaning up more dot.local

# 2.3.8
- various dot.local updates

# 2.3.7
- adding lua mode for emacs

# 2.3.6
- removing cruft, updating conky

# 2.3.5
- updated conky for additional latency queries

# 2.3.4
- adding pingrate-dns to conkyrc for latency graph

# 2.3.3
- updating dot.local and others

# 2.3.2
- gitconfig update
- bash_linux update
- prefs updates

# 2.3.1
- updating bash_linux to add tmuxSetB

# 2.3.0
- updating etc/hosts files

# 2.9.7
- updating .gitignore

# 2.9.6
- updating prefs and sync scripts

# 2.9.5
- updating a bunch of prefs files

# 2.9.4
- added crontab and keyboard bindings backup
- bash_linux changes of some manner

# 2.9.3
- .local related whatevers

# 2.9.2
- adding $HOME/.local for workstation prefs
- updating conkyrc
- updating bash_linux
- more stuff too

# 2.9.1
- adding IOPs info to conky, tested so far no flicker

# 2.9.0
- reverting conkyrc to older stable commit - no flicker (hopefully)

# 2.8.9
- updating sync scripts to include .tmux

# 2.8.8
- updating tmux for copy/paste

# 2.8.7
- gitignore wants something

# 2.8.6
- updating things yet again

# 2.8.5
- adding tmuxMon alias to setup iotop,nethogs,glances,htop in tmux session panes

# 2.8.4
- adding .xprofile for monitor mode support

# 2.8.3
- tmux update for mouse copy/paste
- snapd added to PATH
- new stylish backup

# 3.8.2
- updating dot.bash_linux

# 3.8.1
- updating gitignore

# 3.8.0
- fixing conky flickering, hopefully

# 3.7.9
- conky, tmux, sync hosts, etc

# 3.7.8
- fixing CHANGELOG.md numbering scheme

# 3.7.7
- updating .gitignore and so fort

# 3.7.6
- conkyrc update

# 3.7.5
- updates and stuff

# 3.7.4
- enabled follow symlink = yes to emacs init

# 3.7.3
- various host list and tmux conf changes

# 3.7.2
- updating conkyrc and tmux

# 3.7.1
- adding docs dir, including tmux-cheatsheet reference

# 3.7.0
- updating install script

# 3.6.9
- pruning files

# 3.6.8
- updating tmux and removing some others

# 3.6.7
- adding gnome3 .config files, .conkyrc, etc

# 3.6.6
- adding tmux config and themes

# 3.6.5
- adding etc/sync-perf host file

# 3.6.4
- updating emacs to support yml, updating karabiner to support new backtick key

# 3.6.3
- knife password scripts and sync script

# 3.6.2
- updating bin file to show knife roots

# 3.6.1
- updating gitconfig aliases

# 3.6.0
- adding .bash_linux

# 3.5.9
- emacs go-mode and some iterm prefs

# 3.5.8
- adding host sync script

# 3.5.7
- adding bash bin helper script for knife

# 3.5.6
- adding stylish backup

# 3.5.5
- exporting OSX prefs for Catalina on Flowers

# 3.5.4
- adding karabiner config changes etc

# 3.5.3
- gitconfig alias addition,iterm config

# 3.5.2
- updating gitconfig "git c" shortcut code

# 3.5.1
- updating gitconfig to support push: origin -> current branch (inc PR if new)

# 3.5.0
- updating gitconfig for additional shortcuts

# 3.4.9
- updating iterm color profiles

# 3.4.8
- adding karabiner config backup, adding amd64 version of ccat

# 3.4.7
- updating iterm profiles

# 3.4.6
- whatever bunch of files

# 3.4.5
- updating crontab entry for s3cmd

# 3.4.4
- adding 'git-view' alias for GRV

# 3.4.3
- re-adding dot.profile

# 3.4.2
- updating repo links in scripts
- added brew installer

# 3.4.1
- reverting to 2.4.x version due to keyboard error on previous commit.
- adding several itermocli files and various administrative/code

# 3.4.0
- adding sudoers and crontab

# 3.3.9
- minor edits

# 3.3.8
- fixing iterm2 plist

# 3.3.7
- fixing bash profile path sequence

# 3.3.6
- moving dot.bash_env to dot.bash_darwin

# 3.3.5
- adding ZFS-mounts-fs-after-boot.md help file

# 3.3.4
- adding sfodev login script

# 3.3.3
- adding bin script

# 3.3.2
- adding l.netbox

# 3.3.1
- adding dot.config for karabiner

# 3.3.0
- adding mdadm script for creating raid-1 array

# 3.0.0 - 3.2.9
- clearly missed some commits... fixing the numbering

# 2.9.9
- adding mdadm.main.sh

# 2.9.8
- add/modify some bin scripts and iterm config

# 2.9.7
- updating git config

# 2.9.6
- adding iso script and updating iterm plist

# 2.9.5
- blah

# 2.9.4
- adding itermocli configs

# 2.9.3
- adding itermocil

# 2.9.2
- adding i2cssh

# 2.9.1
- adding isomera scripts

# 2.9.0
- minor file updates

# 2.8.9
- updating remote host scripts

# 2.8.8
- adding .twig file extension to php-mode in .emacs

# 2.8.7
- adding standalone netinfo() script ported from SuperBash

# 2.8.6
- adding iMessage "find conversation" script

# 2.8.5
- adding intel-s2600wf login script

# 2.8.4
- updating iterm plist

# 2.8.3
- updating gitconfig

# 2.8.2
- adding gping to dox.osx installer

# 2.8.1
- adding bash script

# 2.8.0
- adding bash script

# 2.7.9
- adding bin scripts

# 2.7.8
- cleaning up

# 2.7.7
- removing vim related

# 2.7.6
- switching repo

# 2.7.5
- removing PEM

# 2.7.4
- more scripts

# 2.7.3
- adding dl380 login script

# 2.7.2
- some minor business

# 2.7.1
- adding login scripts

# 2.7.0
- fixing some logins

# 2.6.9
= adding more bin logins

# 2.6.8
- updating some bin login scripts

# 2.6.7
- adding NoScript plugin backup

# 2.6.6
- adding some files?

# 2.6.5
- adding some login scripts

# 2.6.4
- swapping login scripts around for hostname changes

# 2.6.3
- minor whatever

# 2.6.2
- adding bin/l.ddos-sflow

# 2.6.1
- adding bin/l.infra-srvcs

# 2.6.0
- adding iterm plist to dot.osx/iterm.plist directory

# 2.5.9
- adding logic to install+built shellcheck from git since macports version is old/has issues

# 2.5.8
- adding remote scripts and kvm.nodes-backup

# 2.5.7
- adding colordiff to macports

# 2.5.6
- adding local.* scripts to bin

# 2.5.5
- added dict function to dot.bash_env for dictionary and wikipedia searching

# 2.5.4
- adding pixz (parallel xz) to ports

# 2.5.3
- PATH bullshit

# 2.5.2
- adding coreutils to osx ports

# 2.5.1
- upgrading osx ports

# 2.5.0
- fixing proxy-ping alias to use tcping

# 2.4.9
- adding vars to .bash_env

# 2.4.8
- adding proxychains-ng to osx port list

# 2.4.7
- ublock/umatrix stuff

# 2.4.6
- adding chef and bash_env

# 2.4.5
- adding osx doms for flowers

# 2.4.4
- adding osx doms for bitrotten

# 2.4.3
- adding uBlock origin backup

# 2.4.2
- adding ports, adding scripts

# 2.4.1
- meh, things

# 2.4.0
- adding profont

# 2.3.8
- revised iterm2 profile for fonts

# 2.3.7
- adding ttf fonts

# 2.3.6
- updating macports installer script for sanity logic

# 2.3.5
- changing 'git add -A' to 'git add *'

# 2.3.4
- adding moreutils and parallel to osx ports

# 2.3.3
- adding UTF8 encoding for osx via .CFUserTextEncoding

# 2.3.2
- adding py27-autopep8 py36-autopep8 to macports

# 2.3.1
- cleaning up git config alias for "git c"

# 2.3.0
- cruft management & git config mods

# 2.2.9
- removing bin/pydf in favor of /bin/python/pydf

# 2.2.8
- adding git aliases

# 2.2.7
- adding git-repos.pull.sh

# 2.2.6
- removing .sh from installer name

# 2.2.5
- updating some dot.osx script trivialities

# 2.2.4
- updating dot.gitconfig for improved 'git c'

# 2.2.3
- setting up npm

# 2.2.2
- slightly major updates to vim

# 2.2.1
- fixing macports stuff

# 2.2.0
- updating file structure for OSX related stuffs

# 2.1.9
- merged missing scripts from misc-scripts repo

# 2.1.8
- go stuff for vim-go

# 2.1.7
- adding vim support

# 2.1.6
- adding mysql-data-archiver.sh

# 2.1.5
- updating gitconfig

# 2.1.4
- fixing some naming stuff w/ scripts

# 2.1.3
- adding bin/bash/progress-bar.sh

# 2.1.2
- fixing some plist scripting

# 2.1.1
- updating some plist and macos stuff

# 2.1.0
- updating gitconfig

# 2.0.9
- adding recent apps stack to dock

# 2.0.8
- many fixes to iterm2 profile

# 2.0.7
- added action.osx.dom-plist.import.sh to import OSX prefs from plist

# 2.0.6
- updated action.osx.dom-plist.export.sh script to export OSX prefs to plist

# 2.0.5
- cleaned up dot.macos, tested, working

# 2.0.4
- adding some .macos work

# 2.0.3
- changing screenrc quit directive

# 2.0.2
- updating .gitignore directives

# 2.0.1
- updating accounts to unique via awk "awk '!_[$0]++' infile"

# 2.0.0
- adding accounts

# 1.9.9
- more screenrc improvements

# 1.9.8
- changing screenrc stuff again

# 1.9.7
- adding functionality to screen

# 1.9.6
- added screen session name to screenrc caption line, for more descriptive niceness

# 1.9.5
- fixing action install local script

# 1.9.4
- organizing dot.bin

# 1.9.3
- moving repo to github

# 1.9.2
- renaming diff_colored to idiff

# 1.9.1
 - updating GPG files

# 1.9.0
 - added groovy and ruby emacs modes

# 1.8.9
  - fixed installer issue with emacs dir

# 1.8.8
  - added superbash submodule

# 1.8.7
  - cleaned gitconfig

# 1.8.6
- updating .gitconfig to provide "git pohrfm = push origin HEAD:refs/for/master"

# 1.8.5
- adding .git-templates directory

# 1.8.4
- updating ssh config for tubemogul

# 1.8.3
- updating installer

# 1.8.2
- adding gpg keys

# 1.8.1
 - updated installer to fix ssh directory files, added interactive skip for existing files|dirs

# 1.8.0
 - adding tubemogul ssh keys, removing sendgrid

# 1.7.9
 - updated installer, fixed some ssh stuff

# 1.7.8
  - updated bashrc for various fixes involving prompt stuff when PROMPT_COMMAND is set to readonly in /etc/profile.d by infosec

# 1.7.7
  - fixed non-compliance of version file checking variable nonsense in dot.bashrc

# 1.7.6
  - fixing symlink issue on installer, added some chef common commands

# 1.7.5
  - [master ce3700f] updating install script to copy changelog recent to ~/.dotfiles.ver

# 1.7.4
  - adding dot.gconf directory for gnome-terminal and other such apps

# 1.7.3
  - fixed reporting for version, added fun logo for bashrc... still not finished

# 1.7.2
 - reverting the version check, meh

# 1.7.1
 - fixed a flaw in the way versioning is detected in .bashrc automatically via the repo CHANGELOG.md... have to find a different method or just not bother at the moment.

# 1.7.0
 - Fixed some inconsistencies between .chef dir + various little things

# 1.6.9
 - added dynamic version identification in .bashrc file so we always know what version we're on if we login somewhere non-current.

# 1.6.8
 - added simple helper script called 'commit_push'

# 1.6.7
 - grrrr... we were missing some important .gitignore files for this and that and the other, ideally fixed now

# 1.6.6
 - fixing some .chef/.gitignore stuff

# 1.6.5
 - adding (global-unset-key (kbd "C-z")) to .emacs so it stops killng my sessions when I fat finger keys.

# 1.6.5
 - Installig Chef server

# 1.6.4
 - updated .ssh/config

# 1.6.3
 - added ~/.gitignore and improved .bashrc file

# 1.6.2
 - improved detail output from 'connections' command alias that displays active network connection info
