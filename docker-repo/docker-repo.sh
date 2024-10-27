#!/bin/bash

# This script syncs the Docker repository for RHEL9 for offline installation.

# Define the target directory
TARGET_DIR="/home/cair/Downloads/docker_repo"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Change to the target directory
pushd "$TARGET_DIR" || { echo "Failed to enter directory: $TARGET_DIR"; exit 1; }

echo "Docker repo sync start"

# Syncing the Docker repository
wget --mirror --no-parent --no-host-directories --cut-dirs=4 --directory-prefix=. https://download.docker.com/linux/rhel/9/x86_64/stable/ || { echo "Docker repo sync failed"; popd; exit 1; }

echo "Docker repo sync done"

# Return to the previous directory
popd





///////////////////////////////////////////////offline process//////////////////////////////


sudo tee /etc/yum.repos.d/local-repo > /dev/null <<EOL
# Docker CE Stable Local Mirror
[docker-ce-stable]
name=Docker CE Stable Local Mirror
baseurl=file:///media/cair/docker-ce-stable/
gpgcheck=0
enabled=1


# Steps to Install Docker on Offline Red Hat 9

echo "Installing Docker..."

# Clean YUM cache
sudo yum clean all
sudo yum makecache

# Install Docker
sudo dnf --disablerepo='*' --enablerepo='docker-local' install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

# Verify Docker installation
sudo docker --version



