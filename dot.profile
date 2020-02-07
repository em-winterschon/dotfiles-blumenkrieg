source $HOME/.bashrc
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
test -e /usr/libexec/java_home && export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)


