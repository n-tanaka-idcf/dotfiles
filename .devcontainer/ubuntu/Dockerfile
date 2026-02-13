FROM ubuntu:24.04

ARG USER=vscode
ARG GROUP=${USER}
ARG UID=1000
ARG GID=1000

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash-completion=1:2.11* \
    sudo=1.9* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid ${GID} ${GROUP} && \
    useradd --uid ${UID} --gid ${GID} --groups sudo --shell /bin/bash --create-home ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER}

USER ${USER}
