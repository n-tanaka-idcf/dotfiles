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
      gcc
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
# Commands
# -----------------------------------------------------------------------------
# Aqua
aqua_installer_ver='v3.1.2'
aqua_installer_url="https://raw.githubusercontent.com/aquaproj/aqua-installer/${aqua_installer_ver}/aqua-installer"
curl -sSfL $aqua_installer_url | bash
export AQUA_GLOBAL_CONFIG=~/.config/aquaproj-aqua/aqua.yaml
~/.local/share/aquaproj-aqua/bin/aqua install --all

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
