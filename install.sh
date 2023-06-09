#!/usr/bin/env bash
# This program is a shell script to set up my configuration files and 
# directories, and installs my essential packages on my new system.
# Created by Emile O.E Antat (eoea)

set -e

function usage() {
  echo "${0} is a shell script that sets up my configuration files and "
  echo "directories, and installs my essential packages on my new system." 
  echo 
  echo "Usage:"
  echo
  echo "        ${0} [flags]"
  echo
  echo "The flags are:"
  echo
  echo "        -h         Show help."
  echo "        -l         Creates all my missing directories, symlinks, "
  echo "                   and package manager + packages. Recommend for "
  echo "                   use on a brand new system."
  echo "        -s         Create symlinks only."
  echo
  echo "Examples:"
  echo
  echo "        ${0} -l"
  echo
}

######################################
# Runs the OS specific package manager, the package manager attempts to
# install these package from a text file based on the OS.
# For MacOS, brew is downloaded if it is not on the system.
# For Linux, apt or dnf is used based on availability on the system.
# Note: sudo is called with apt or dnf.
# Argument:
#   None
# Return:
#   (Naked return when neither apt or dnf is found on the system.)
#   (Naked return when neither Darwin or Linux kernel name detected.)
#######################################
function install_pkgs() {
  local pkg_mngr
  local packages
  local kernel
  kernel="$(uname -s)"

  case "${kernel}" in
    Darwin)
      if [[ ! -e "$(which brew)" ]]; then
        echo "installing brew"
        /bin/bash -c "$(curl -fsSL \
          https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      packages="$(cat "${PWD}/pkgs/brewmaster.txt")"
      pkg_mngr="$(which brew)"
      ;;
    Linux)
      if [[ -e "$(which apt)" ]]; then
        pkg_mngr="$(which apt)"
      elif [[ -e "$(which dnf)" ]]; then
        pkg_mngr="$(which dnf)"
      else
        echo "apt or dnf not detected" >&2
        echo "packages were not installed" >&2
        return
      fi
      packages="$(cat "${PWD}/pkgs/linuxbox.txt")"
      ;;
    *)
      echo "unkown kernel, skipping package installation" >&2
      return
      ;;
  esac

  for package in ${packages};
  do
    if [[ "${kernel}" == "Linux" ]]; then
      sudo "${pkg_mngr}" install "${package}"
    else
      "${pkg_mngr}" install "${package}"
    fi
  done
}

######################################
# Creates symlinks of my rcfiles from my repo to the home directory.
# A kernel name check is performed because the symlink for bashrc and
# tmux are different for MacOS and Linux. If the kernel name is Linux,
# then a further check is made to see if gnome-terminal is installed;
# if present, then the default config file for gnome-terminal is
# replaced with mine, otherwise, this is skipped.
# Argument:
#   None
# Return:
#   (Naked return when neither Darwin or Linux kernel name detected.)
#######################################
function creat_symlinks() {
  local kernel
  kernel="$(uname -s)"

  case "${kernel}" in
    Darwin)
      ln -sfv "${PWD}/bash/mac_os/profile" "${HOME}/.profile"
      ln -sfv "${PWD}/bash/mac_os/bashrc" "${HOME}/.bashrc"
      ln -sfv "${PWD}/tmux/mac_os/tmux.conf" "${HOME}/.tmux.conf"
      ;;
    Linux)
      ln -sfv "${PWD}/bash/linux/bashrc" "${HOME}/.bashrc"
      ln -sfv "${PWD}/bash/linux/bash_aliases" "${HOME}/.bash_aliases"
      ln -sfv "${PWD}/tmux/linux/tmux.conf" "${HOME}/.tmux.conf"
      ln -sfv "${PWD}/fonts/Hack-BoldItalic.ttf" "${HOME}/.local/share/fonts/Hack-BoldItalic.ttf"
      ln -sfv "${PWD}/fonts/Hack-Bold.ttf"  "${HOME}/.local/share/fonts/Hack-Bold.ttf"
      ln -sfv "${PWD}/fonts/Hack-Italic.ttf"  "${HOME}/.local/share/fonts/Hack-Italic.ttf"
      ln -sfv "${PWD}/fonts/Hack-Regular.ttf" "${HOME}/.local/share/fonts/Hack-Regular.ttf"

      if [[ ! -e "$(which dconf)" ]]; then
        echo "dconf for gnome-terminal not installed, skipping this" >&2
        echo "should you need to install:"
        echo "sudo apt install dconf-cli"
      else
        dconf load /org/gnome/terminal/ < "${PWD}/g-term/g_term.properties"
        echo "preferred settings has been applied to gnome-terminal"
      fi
      ;;
    *)
      echo "unkown kernel, skipping symlink creation" >&2
      return
      ;;
  esac

  ln -sfv "${PWD}/vim/vimrc" "${HOME}/.vimrc"
  ln -sfv "${PWD}/git/gitconfig" "${HOME}/.gitconfig"
  ln -sfv "${PWD}/git/gitignore" "${HOME}/.gitignore"
  ln -sfv "${PWD}/sqlite/sqliterc" "${HOME}/.sqliterc"
  ln -sfv "${PWD}/cobra/cobra.yaml" "${HOME}/.cobra.yaml"
  ln -sfv "${PWD}/vim/ftplugin/sh.vim" "${HOME}/.vim/ftplugin/sh.vim"
  ln -sfv "${PWD}/vim/ftplugin/markdown.vim" "${HOME}/.vim/ftplugin/markdown.vim"
  ln -sfv "${PWD}/vim/spell/en.utf-8.add" "${HOME}/.vim/spell/en.utf-8.add"
}

function install_vim_plugin_mngr() {
  echo "installing vim-plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

function main() {
  local exit_code=0
  while getopts "hls" flags; do 
    case "${flags}" in 
      h) 
        usage
        ;;
      s)
        creat_symlinks
        ;;
      l)
        mkdir -pv "${HOME}/.local/bin"
        mkdir -pv "${HOME}/.local/scripts"
        mkdir -pv "${HOME}/.local/share"
        mkdir -pv "${HOME}/.local/share/fonts"
        mkdir -pv "${HOME}/.vim/plugged"
        mkdir -pv "${HOME}/.vim/ftplugin"
        mkdir -pv "${HOME}/.vim/spell"
        mkdir -pv "${HOME}/Programming/Repos/github.com/eoea/"
        mkdir -pv "${HOME}/Programming/Repos/gitlab.com/eoea/"
        creat_symlinks
        install_pkgs
        install_vim_plugin_mngr
        source "${HOME}/.bashrc"
        ;;
      *)
        echo "error: invalid flag, use ${0} -h for help." >&2
        exit_code=1
        ;;
    esac
  done
  return "${exit_code}"
}

main "$@"
