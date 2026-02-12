# dotfiles
[![build_devcontainer_image](https://github.com/codequokka/dotfiles/actions/workflows/build_devcontainer_image.yaml/badge.svg)](https://github.com/codequokka/dotfiles/actions/workflows/build_devcontainer_image.yaml)
[![run_workflow_ci](https://github.com/codequokka/dotfiles/actions/workflows/run_workflow_ci.yaml/badge.svg)](https://github.com/codequokka/dotfiles/actions/workflows/run_workflow_ci.yaml)
[![test_dotfiles_deployment](https://github.com/codequokka/dotfiles/actions/workflows/test_dotfiles_deployment.yaml/badge.svg)](https://github.com/codequokka/dotfiles/actions/workflows/test_dotfiles_deployment.yaml)


## Overview

This is my personal dotfiles repository, managed with [chezmoi](https://www.chezmoi.io/).

## Features

This repository includes configurations for the following tools:

- **Shell**: zsh, nushell
- **Terminal**: Starship, Zellij, tmux
- **Editor**: Neovim (NvChad)
- **Git**: gitconfig
- **Others**: atuin, aqua, bat, docker, gh, kind, and more.

## Installation

### Prerequisites

The following tools must be installed beforehand:

- `git`
- `curl`

### Instructions

Run the following command to start the setup:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin" init --apply codequokka
```

## Usage

This repository uses [Task](https://taskfile.dev/) to automate common operations.

- `task diff`: Runs `chezmoi` in dry-run mode to show the difference in configurations.
- `task apply`: Applies the changes to your home directory by running `chezmoi apply`.
- `task test`: Uses [GOSS](https://goss.rocks/) to test if the configurations are deployed as intended.

## Development Environment

### Dev Containers

To use the Dev Container, you need to have the following installed on your machine:

- [Visual Studio Code](https://code.visualstudio.com/)
- The [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for VS Code
- [Docker](https://www.docker.com) (or another compatible container runtime) running. For installation instructions, refer to the [official Docker documentation](https://docs.docker.com/engine/install/). For Rocky Linux 8, you can also refer to the [guide in this repository](./docs/install_docker_into_rocky_8_linux.md).


[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/codequokka/dotfiles)

### GitHub Codespaces

To use the Dev Container, you need to click following icon then follow instructions:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/codequokka/dotfiles)
