#!/usr/bin/env bash

# Logging stuff
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;34m➜\033[0m  $@"; }
function e_color()    { printf '\033[0;31m%s\033[0m\n' "$1"; }

function help() {
  logo
  e_header "$0 -v (install vim dotfiles)"
  e_header "$0 -b (install bash  dotfiles)"
  e_header "$0 -a (install all  dotfiles)"
  exit 0
}

function logo() {
  e_header "Install ca13 dotfiles !!!"
  e_color '                                                           '
  e_color '           __ ____    _____        _    __ _ _             '
  e_color '          /_ |___ \  |  __ \      | |  / _(_) |            '
  e_color '   ___ __ _| | __) | | |  | | ___ | |_| |_ _| | ___  ___   '
  e_color '  / __/ _` | ||__ <  | |  | |/ _ \| __|  _| | |/ _ \/ __|  '
  e_color ' | (_| (_| | |___) | | |__| | (_) | |_| | | | |  __/\__ \  '
  e_color '  \___\__,_|_|____/  |_____/ \___/ \__|_| |_|_|\___||___/  '
  e_color '                                                           '
}


# Init files
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
function init_files() { e_success "Tout est OK!!!"; }

# Sync repo
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
function sync_repo() { e_header "Copying files into home directory"; }

# Link files
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
function link_header() { e_header "Linking files into home directory"; }

# Copy files
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
function copy_header() { e_header "Copying files into home directory"; }

if [ $# -ne 1 ]; then
  help
fi

while getopts ":vba" opts; do
  case $opts in
    v)
      copy_header;;
    b)
      logo;;
    a)
      link_header;;
    :)
      help;;
    ?)
      help;;
  esac
done
