#!/bin/bash

# -----------------------------------------------------------------------------
# OS packages
# -----------------------------------------------------------------------------
manage_os_packages() {
  if (type 'apt-get' >/dev/null 2>&1); then
    # Debian variants

    # sudo apt-get update
    # sudo apt-get upgrade -y

    packages=(
      fuse
      git
      zsh
    )

    for package in "${packages[@]}"; do
      sudo apt-get install -y "$package"
    done
  elif (type 'dnf' >/dev/null 2>&1); then
    # Redhat variants

    # sudo dnf check-update
    # sudo dnf update -y

    packages=(
      epel-release
      fuse
      git
      util-linux-user
      zsh
    )

    for package in "${packages[@]}"; do
      sudo dnf install -y "$package"
    done
  else
    echo 'The current OS is not supported!'
    exit 1
  fi
}

manage_os_packages

# -----------------------------------------------------------------------------
# Terminal
# -----------------------------------------------------------------------------
# Tmux plugin manager
if [[ ! -e ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  [[ -e /.dockerenv ]] && export APPIMAGE_EXTRACT_AND_RUN=1
  ~/.tmux/plugins/tpm/bin/install_plugins
fi

# -----------------------------------------------------------------------------
# Shell
# -----------------------------------------------------------------------------
# Zsh
USER=$(whoami)
sudo chsh "$USER" -s /usr/bin/zsh
