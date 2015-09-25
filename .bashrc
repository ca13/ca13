#
#                        __ ____    _____        _    __ _ _
#                       /_ |___ \  |  __ \      | |  / _(_) |
#                ___ __ _| | __) | | |  | | ___ | |_| |_ _| | ___  ___
#               / __/ _` | ||__ <  | |  | |/ _ \| __|  _| | |/ _ \/ __|
#              | (_| (_| | |___) | | |__| | (_) | |_| | | | |  __/\__ \
#               \___\__,_|_|____/  |_____/ \___/ \__|_| |_|_|\___||___/



##################################################################################
# INITIALISATION
#################################################################################

# Files will be created with these permissions:
# files 644 -rw-r--r-- (666 minus 022)
# dirs  755 drwxr-xr-x (777 minus 022)
umask 022

# Do not continue if we are not in a bash shell
[ -z "$BASH_VERSION" ] && return

# Do not continue if we are not running interactively
[ -z "$PS1" ] && return


#################################################################################
# OS DETECTION
#################################################################################

function is_osx() {
  [[ "$OSTYPE" =~ ^darwin ]] || return 1
}
function is_linux() {
  [[ "$(uname -s)" =~ Linux ]] || return 1
}
function is_mingw32() {
  [[ "$(uname -s)" =~ MINGW32 ]] || return 1
}
function get_os() {
  for os in osx linux mingw32; do
    is_$os; [[ $? == ${1:-0} ]] && echo $os
  done
}

#################################################################################
# HELPERS
#################################################################################

# Logging stuff
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;34m➜\033[0m  $@"; }

# Setup paths
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
function remove_from_path() {
  [ -d $1 ] || return
  # Doesn't work for first item in the PATH but don't care.
  export PATH=$(echo $PATH | sed -e "s|:$1||") 2>/dev/null
}

function add_to_path_start() {
  [ -d $1 ] || return
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

function add_to_path_end() {
  [ -d "$1" ] || return
  remove_from_path "$1"
  export PATH="$PATH:$1"
}

function force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

function quiet_which() {
  which $1 1>/dev/null 2>/dev/null
}


#################################################################################
# EXPORT
#################################################################################

# Path
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Set PATH so it includes user bin if it exists.
[ -d "$HOME/bin" ] && PATH=$HOME/bin:$PATH

if [ -d "$HOME/.rbenv/bin" ]; then
  PATH=$HOME/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
fi

[ -d "$HOME/.pear/bin" ] && PATH=$HOME/.pear/bin:$PATH

[ -d "$HOME/.composer/vendor/bin" ] && PATH=$HOME/.composer/vendor/bin:$PATH

if [ "$PLATFORM" = Darwin ]; then
  PATH="$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin"
  PATH="$PATH:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
fi

export PATH

# History and Shopt options
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Enable some Bash 4 features when possible
# checkwinsize : Update $LINES and $COLUMNS after each command
# histappend : Append to the history file
# autocd : e.g $(**/dir) will enter $(./foo/bar/baz/dir)
# globstart : recursive globbing, eg $(echo **/*.txt)
for option in checkwinsize histappend autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;

export HISTCONTROL=erasedups:ignoreboth
export HISTSIZE=
export HISTFILESIZE=
export HISTTIMEFORMAT="[ %d/%m/%Y ] [ %H:%M:%S ]  "
export HISTIGNORE='cd:ls:l:ll:la:lk:lh:lsd:lo:q:s:c:fs:history:h:hgrep:alg:v:o:st:a:sb'

# Easily re-execute the last history command.
alias r="fc -s"

# Editors, Lang, Grep options, Github Api
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
[ -z "$TMPDIR" ] && export TMPDIR=/tmp

export EDITOR=vim
export LANG=fr_FR.UTF-8
export GREP_OPTIONS='--color=auto'

# Prevent less from clearing the screen while still showing colors.
export LESS=-XR

is_osx || export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.:/usr/local/lib

# Load Homebrew GitHub API key
[ -s ~/.brew_github_api ] && export HOMEBREW_GITHUB_API_TOKEN=$(cat ~/.brew_github_api)


#################################################################################
# CONFIGS
#################################################################################

# Bash completion
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
if [ -f /usr/local/etc/bash_completion ]; then
  source /usr/local/etc/bash_completion
elif [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

# Docker
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
command -v docker-machine > /dev/null 2>&1 && eval "$(docker-machine env default)"

# Z
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Init z https://github.com/rupa/z
[ -f ~/z/z.sh ] && . ~/z/z.sh

# SSH completion based on entries in known_hosts.
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
if [[ -e ~/.ssh/known_hosts ]]; then
  complete -o default -W "$(cat ~/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp sftp
fi

#################################################################################
# PROMPT
#################################################################################

# Maxi prompt
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
if [ -e ~/.git_hg_svn_prompt.sh ]; then
  source ~/.git_hg_svn_prompt.sh
else
  PROMPT_COMMAND='history -a; history -c; history -r; printf "\[\e[38;5;59m\]%$(($COLUMNS - 4))s\r" "$(__git_ps1) ($(date +%d/%m\ %H:%M:%S))"'
  PS1="\[\e[34m\]\u\[\e[1;32m\]@\[\e[0;33m\]\h\[\e[35m\]:"
  PS1="$PS1\[\e[m\]\w\[\e[1;31m\]> \[\e[0m\]"
fi

# Mini prompt
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
function miniprompt() {
  unset PROMPT_COMMAND
  PS1="\[\e[1;38m\]\u\[\e[1;34m\]@\[\e[1;31m\]\h\[\e[1;30m\]:"
  PS1="$PS1\[\e[0;38m\]\w\[\e[1;35m\]> \[\e[0m\]"
}

# Super Mini prompt
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
function superminiprompt() {
  unset PROMPT_COMMAND
  PS1="\[\e[38;5;168m\]> \[\e[0m\]"
}

#################################################################################
# ALIASES
#################################################################################

# Directory and file listing
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
elif is_osx; then
  alias ls="command ls -G"
elif is_mingw32; then
  export LS_COLORS='di=01;36'
  alias pt='pt --nocolor'
else
  alias ls="command ls --color"
  export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
fi

if [[ "$(type -P tree)" ]]; then
  alias ll='tree --dirsfirst -aLpughDFiC 1'
  alias lsd='ll -d'
else
  alias ll='ls -al'
  alias lsd='CLICOLOR_FORCE=1 ll | grep --color=auto"^d"'
  #is_linux && exec sudo apt-get install tree
fi

alias l='ls -al'
alias la='ls -a'
alias lk='ls -lah  | grep "\->" 2> /dev/null || echo "no symlinked files here..."'
alias lh='ls .???* 2> /dev/null || echo "no hidden files here..."'
alias li='ls -lai'
# List ALL files (colorized() in long format, show permissions in octal
alias lo="ls -laF | awk '
{
  k=0;
  for (i=0;i<=8;i++)
    k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));
  if (k)
    printf(\"%0o \",k);
  print
}'"

# Misc, Git, Bookmarks
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The space following sudo tells tells bash to check if the command that follow the space is also an alias
alias sudo='sudo '

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

alias vi='vim'
alias h='history'
alias c='clear'
alias s='cd .. && ls -ltr'
alias q='exit'
alias sb='source ~/.bashrc'
alias rmf='rm -rf'
alias hgrep='history | grep'
alias alg='alias | grep'
alias hosts='sudo $EDITOR /etc/hosts'
alias df="df -h"

# Git
# command -v hub > /dev/null 2>&1 || alias git="hub"
alias gitl='git log --graph --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

# Bookmarks
# show pour voir la liste des bookmarks existants
# save foo sauvergarde le dossier courant dans le bookmark foo
# cd foo pour y revenir
[ ! -f ~/.dirs ] && touch ~/.dirs

alias show='cat -n ~/.dirs | sed "s/^\([^.]*\)\=\(.*\)/-\1 --> \2/g"'
save (){ command sed "/!$/d" ~/.dirs > ~/.dirs1; \mv ~/.dirs1 ~/.dirs; echo "$@"=\"`pwd`\" >> ~/.dirs; source ~/.dirs ;}
source ~/.dirs  # initialisation de la fonction 'save': source le fichier .sdirs

# Networking
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# View HTTP traffic
alias httpdump="sudo tcpdump -i en3 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
# IP addresses
alias ip="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias whois="whois -h whois-servers.net"
alias sniff="sudo ngrep -d 'en3' -t '^(GET|POST) ' 'tcp and port 80'"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache"

# Virtual machines
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Veewee
command -v bundle > /dev/null 2>&1 && alias veewee='bundle exec veewee'

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null 2>&1 || alias hd="hexdump -C"

# Make Grunt print stack traces by default
command -v grunt > /dev/null 2>&1 && alias grunt="grunt --stack"

# Use always htop if installed
# sudo apt-get install htop
command -v htop > /dev/null 2>&1 && alias top='htop'

# OSX specific aliases
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if is_osx; then

  command -v md5sum > /dev/null || alias md5sum="md5"

  command -v sha1sum > /dev/null || alias sha1sum="shasum"

  alias pb="tr -d '\n' | pbcopy"

  # Recursively delete `.DS_Store` files
  alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

  # Show/hide hidden files in Finder
  alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

  # Hide/show all desktop icons (useful when presenting)
  alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
  alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Package management
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install -g npm@latest; sudo gem update --system; sudo gem update'

  # Lessipe
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  [[ "$(type -P lesspipe.sh)" ]] && eval "$(lesspipe.sh)"

fi

# Linux specific aliases
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

if is_linux; then

  # Package management
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  alias update='sudo apt-get -qq update && sudo apt-get upgrade'
  alias install='sudo apt-get install'
  alias remove='sudo apt-get remove'
  alias search='apt-cache search'
  alias policy='sudo apt-cache policy'

  # Lessipe
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Better-looking less for binary files
  [ -x /usr/bin/lesspipe    ] && eval "$(SHELL=/bin/sh lesspipe)"

fi


#################################################################################
# FUNCTIONS
#################################################################################

# Create a new directory and enter it
function md() {
  mkdir -p "$@" && cd "$_";
}

# change to parent directory matching partial string, eg:
# in directory /home/foo/bar/baz, 'bd f' changes to /home/foo
function bd () {
  local old_dir=`pwd`
  local new_dir=`echo $old_dir | sed 's|\(.*/'$1'[^/]*/\).*|\1|'`
  index=`echo $new_dir | awk '{ print index($1,"/'$1'"); }'`
  if [ $index -eq 0 ] ; then
    echo "No such occurrence."
  else
    echo $new_dir
    cd "$new_dir"
  fi
}

# `st` with no arguments opens the current directory in Sublime Text, otherwise
# opens the given location
function st() {
  if [ $# -eq 0 ]; then
    command -v subl > /dev/null 2>&1 || subl .;
  else
    command -v subl > /dev/null 2>&1 || subl "$@";
  fi;
}

# `a` with no arguments opens the current directory in Atom Editor, otherwise
# opens the given location
function a() {
  if [ $# -eq 0 ]; then
    command -v subl > /dev/null 2>&1 || atom .;
  else
    command -v subl > /dev/null 2>&1 || atom "$@";
  fi;
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() {
  if [ $# -eq 0 ]; then
    command -v subl > /dev/null 2>&1 || vim .;
  else
    command -v subl > /dev/null 2>&1 || vim "$@";
  fi;
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
  if [ $# -eq 0 ]; then
    command -v subl > /dev/null 2>&1 || open .;
  else
    command -v subl > /dev/null 2>&1 || open "$@";
  fi;
}


function rvm() {
  # Load RVM into a shell session *as a function*
  if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    unset -f rvm

    [ ! -e "$HOME/.rvmrc" ] && echo "rvm_autoupdate_flag=2" >> "$HOME/.rvmrc"

    source "$HOME/.rvm/scripts/rvm"
    # Add RVM to PATH for scripting
    PATH=$PATH:$HOME/.rvm/bin
    rvm $@
  fi
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  local port="${1:-8000}";
  sleep 1 && open "http://localhost:${port}/" &
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# Create a git.io short URL
function gitio() {
  if [ -z "${1}" -o -z "${2}" ]; then
    echo "Usage: \`gitio slug url\`";
    return 1;
  fi;
  curl -i http://git.io/ -F "url=${2}" -F "code=${1}";
}

# Determine size of a file or total size of a directory
function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* *;
  fi;
}

#################################################################################
# EXTRA
#################################################################################

LOCAL=$BASE/.bashrc.local
[ -f "$LOCAL" ] && source "$LOCAL"
