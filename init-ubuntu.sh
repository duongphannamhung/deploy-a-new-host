#!/bin/bash
# Init script for new Ubuntu host

set -e

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y tmux curl git vim build-essential ca-certificates


# Directory containing dotfiles (relative to script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="."

# Copy or symlink .bashrc, .bash_profile, and .gitconfig if they exist in dotfiles
for file in .bashrc .bash_profile .gitconfig; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        cat "$DOTFILES_DIR/$file" >> ~/$file
        echo "$file appended to existing file in home directory."
    else
        cp "$DOTFILES_DIR/$file" ~/ 
        echo "$file copied to home directory."
    fi
done


# Install additional libraries (add as needed)
sudo apt install -y python3-pip

# Check .env for INSTALL_PYTHON_DEPENDENCIES=true and install requirements.txt
if [ -f "$SCRIPT_DIR/.env" ]; then
    set -a
    . "$SCRIPT_DIR/.env"
    set +a
    if [ "$INSTALL_PYTHON_DEPENDENCIES" = "true" ]; then
        if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
            python3 -m pip install --user -r "$SCRIPT_DIR/requirements.txt"
            echo "Python dependencies installed from requirements.txt."
        else
            echo "requirements.txt not found, skipping Python dependencies installation."
        fi
    fi
fi


# Install Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
# Install Docker Engine, CLI, and Containerd
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin zip unzip
# Check status docker
sudo systemctl status docker --no-pager

sudo bash install-pathpicker.sh

# Done
echo "Init script completed. Please restart your shell."