FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN --mount=type=tmpfs,target=/tmp --mount=type=tmpfs,target=/run \
    yes | unminimize && apt update && apt install -y \
        ca-certificates jq p7zip-full curl \
        gnupg apt-utils apt-transport-https \
        git wget websockify \
        build-essential gdb libtool valgrind clang \
        sudo ssh rsync htop less lsof mc ncdu duf fd-find \
        asciinema man-db bash-completion command-not-found zsh \
        iproute2 iputils-ping \
        make cmake ninja-build autoconf automake \
        locales-all tzdata language-selector-common \
        vim nano dos2unix python-is-python3 \
        python3 python3-pip python3-venv python3-dev dotnet-sdk-8.0 && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash && \
    apt install -y nodejs $(check-language-support -l en_US) && \
    apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/* && \
    dotnet new install Mal.Mdk2.ScriptTemplates && corepack enable && \
    mkdir -p /opendevin && mkdir -p /opendevin/logs && chmod 777 /opendevin/logs && \
    wget --progress=bar:force -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p /opendevin/miniforge3 && chmod -R g+w /opendevin/miniforge3 && \
    bash -c ". /opendevin/miniforge3/etc/profile.d/conda.sh && conda config --set changeps1 False && conda config --append channels conda-forge" && \
    echo "" > /opendevin/bash.bashrc && rm -f Miniforge3.sh && \
    /opendevin/miniforge3/bin/pip install --upgrade pip && \
    /opendevin/miniforge3/bin/pip install jupyterlab notebook jupyter_kernel_gateway flake8 && \
    /opendevin/miniforge3/bin/pip install python-docx PyPDF2 python-pptx pylatexenc openai && \
    /opendevin/miniforge3/bin/pip install python-dotenv toml termcolor pydantic python-docx pyyaml docker pexpect tenacity e2b browsergym minio && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    sed 's/#force_color_prompt=yes/force_color_prompt=yes/' -i /root/.bashrc && \
    sed 's/plugins=(git)/plugins=(git command-not-found)/' -i /root/.zshrc && \
    rm /etc/ssh/ssh_host_* && userdel -rf ubuntu

RUN mkdir -p -m0755 /var/run/sshd /run/sshd && touch /run/utmp && \
    echo '#!/bin/sh\n\
set -e\n\
KEY_DIR="/etc/ssh"\n\
KEY_TYPES="rsa ecdsa ed25519"\n\
for key_type in $KEY_TYPES; do\n\
    KEY_FILE="${KEY_DIR}/ssh_host_${key_type}_key"\n\
    if [ ! -f "$KEY_FILE" ]; then\n\
        echo "Generating $key_type host key..."\n\
        ssh-keygen -t $key_type -f "$KEY_FILE" -N ""\n\
    fi\n\
done\n\
exec $@\n' > /entrypoint.sh && chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh

