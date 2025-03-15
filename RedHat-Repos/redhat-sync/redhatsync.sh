#!/bin/bash

# To create a local mirror of RHEL 9.4 repositories for future backup on an offline Red Hat machine only

# Step 0: Install yum-utils
echo "Installing yum-utils..."
sudo dnf install -y yum-utils

# Step 1: Create the custom repository file
echo "Creating custom repository configurations..."
sudo tee /etc/yum.repos.d/custom-repos.repo > /dev/null <<EOL
# Jenkins Online Repository
[jenkins]
name=Jenkins Repository
baseurl=https://pkg.jenkins.io/redhat-stable/
gpgcheck=1
gpgkey=https://pkg.jenkins.io/redhat-stable/jenkins.io.key
enabled=1

# Docker Online Repository
[docker-ce-stable]
name=Docker CE Stable Repository
baseurl=https://download.docker.com/linux/rhel/9/x86_64/stable
gpgcheck=1
gpgkey=https://download.docker.com/linux/rhel/gpg
enabled=1

# Red Hat Enterprise Linux 9 for x86_64 - AppStream (RPMs)
[rhel-9-for-x86_64-appstream-rpms]
name=Red Hat Enterprise Linux 9 for x86_64 - AppStream (RPMs)
baseurl=http://mirror.centos.org/centos/9-stream/AppStream/x86_64/os/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled=1

# Red Hat Enterprise Linux 9 for x86_64 - BaseOS (RPMs)
[rhel-9-for-x86_64-baseos-rpms]
name=Red Hat Enterprise Linux 9 for x86_64 - BaseOS (RPMs)
baseurl=http://mirror.centos.org/centos/9-stream/BaseOS/x86_64/os/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled=1
EOL
echo "Custom repository configurations created."



# Step 2: Create the directory for local mirror
echo "Creating directory for local mirror..."
sudo mkdir -p /var/www/html/rhel9

# Step 3: Sync repositories
echo "Syncing repositories..."

# Sync Jenkins repository
sudo reposync -p /var/www/html/rhel9 --download-metadata --repoid=jenkins

# Sync Docker repository
sudo reposync -p /var/www/html/rhel9 --download-metadata --repoid=docker-ce-stable

# Sync Red Hat AppStream repository
sudo reposync -p /var/www/html/rhel9 --download-metadata --repoid=rhel-9-for-x86_64-appstream-rpms

# Sync Red Hat BaseOS repository
sudo reposync -p /var/www/html/rhel9 --download-metadata --repoid=rhel-9-for-x86_64-baseos-rpms

# Step 4: Download Docker Compose
echo "Downloading Docker Compose..."
sudo mkdir -p /var/www/html/rhel9/docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /var/www/html/rhel9/docker-compose/docker-compose
sudo chmod +x /var/www/html/rhel9/docker-compose/docker-compose

# Step 5: Sync Tuleap repository
echo "Creating directory for Tuleap repository..."
sudo mkdir -p /var/www/html/rhel9/tuleap

echo "Tuleap repo sync start"
pushd /var/www/html/rhel9/tuleap || exit
wget --force-html --recursive --mirror --continue https://ci.tuleap.net/yum/tuleap/rhel/9/dev/x86_64/
popd
echo "Tuleap repo sync done"

echo "Repository syncing and Docker Compose setup completed successfully!"
