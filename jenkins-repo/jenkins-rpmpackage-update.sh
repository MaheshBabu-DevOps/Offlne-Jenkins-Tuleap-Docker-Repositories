#!/bin/bash

# Update and upgrade existing packages
sudo apt update && sudo apt upgrade -y

# Install required tools
sudo apt install -y wget curl createrepo-c

# Verify createrepo_c installation
createrepo_c --version

# Download Latest Jenkins RPM and Generate Metadata

# Define the download directory
DOWNLOAD_DIR="/home/cair/Downloads/jenkins_repo"
mkdir -p "$DOWNLOAD_DIR"  # Create the download directory if it doesn't exist
pushd "$DOWNLOAD_DIR" || { echo "Failed to enter directory: $DOWNLOAD_DIR"; exit 1; }  # Navigate to the download directory

echo "Jenkins repo sync start"

# Download the latest Jenkins RPM package
latest_url=$(curl -s https://mirrors.jenkins-ci.org/redhat-stable/ | grep -oP '(?<=href=")(jenkins-[0-9]+\.[0-9]+\.[0-9]+-[0-9]+\.[0-9]+.noarch.rpm)(?=")' | sort -V | tail -n 1)
if [ -z "$latest_url" ]; then 
    echo "Failed to find the latest Jenkins RPM." 
    exit 1
fi

# Use wget to download the Jenkins RPM package
wget --continue "https://mirrors.jenkins-ci.org/redhat-stable/$latest_url" || { echo "Download failed."; exit 1; }
echo "Jenkins RPM download done"

# Generate repository metadata
createrepo_c "$DOWNLOAD_DIR" || { echo "Metadata generation failed."; exit 1; }
echo "Metadata generation done. Jenkins repo sync complete."

popd  # Return to the previous directory




//////////////////////////////////////////////////////////////////

offline setup:-

sudo yum clean all
sudo yum repolist
sudo yum install fontconfig java-17-openjdk
sudo yum install nginx
sudo yum install git


jenkins offline Installation:---------------------


sudo mkdir -p /media/cair/jenkins_repo
sudo cp -r /home/cair/Downloads/jenkins_repo/   /media/cair/jenkins_repo

sudo tee /etc/yum.repos.d/local-repo > /dev/null <<EOL
# Jenkins Local Repository
[jenkins-local]
name=Jenkins Local Repository
baseurl=file:///var/www/html/rhel9/jenkins/
gpgcheck=0
enabled=1
EOL


sudo dnf clean all
sudo dnf --disablerepo='*' --enablerepo='jenkins-local' install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

http://localhost:8080
sudo cat /var/lib/jenkins/secrets/initialAdminPassword






jenkins update process:---------------------

sudo systemctl stop jenkins

# Backup Jenkins Data

sudo dnf --disablerepo='*' --enablerepo='jenkins-local' list available Jenkins
sudo dnf --disablerepo='*' --enablerepo='jenkins-local' update jenkins -y
jenkins --version

sudo systemctl restart jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins





