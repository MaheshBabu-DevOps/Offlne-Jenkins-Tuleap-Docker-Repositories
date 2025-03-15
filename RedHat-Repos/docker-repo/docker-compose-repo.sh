#!/bin/bash

# Create a directory for Docker Compose 
mkdir -p /home/cair/Downloads/docker-compose

pushd /home/cair/Downloads/docker-compose

echo "Docker Compose repo sync start"

# Syncing the Docker Compose binaries
wget --no-parent --no-host-directories --directory-prefix=. https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64

# Make the Docker Compose binary executable
chmod +x docker-compose-Linux-x86_64

echo "Docker Compose repo sync done"

popd





# Offline Installation:-----

# Move the binary to a directory in your PATH (optional)
sudo mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose

# Verify the installation (optional step)
docker-compose --version


