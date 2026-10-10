#!/bin/bash

set -euo pipefail

# -----------------------------------------------------------------------------
# OS packages
# -----------------------------------------------------------------------------
manage_os_packages() {
  if (type 'apt-get' >/dev/null 2>&1); then
    # Debian variants

    sudo apt-get update
    sudo apt-get upgrade -y

    packages=(
      curl
      git
      openssh-client
    )

    for package in "${packages[@]}"; do
      sudo apt-get install -y "$package"
    done
  else
    echo 'The current OS is not supported!'
    exit 1
  fi
}

manage_os_packages

# -----------------------------------------------------------------------------
# mise
# -----------------------------------------------------------------------------
install_mise() {
  if command -v mise >/dev/null 2>&1 || [ -x "${HOME}/.local/bin/mise" ]; then
    echo 'mise is already installed.'
    return
  fi

  curl -fsSL https://mise.run | sh
}

install_mise
