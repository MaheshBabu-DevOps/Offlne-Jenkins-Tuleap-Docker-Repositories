#!/bin/bash

# Redhat Repository Sync Script

# Change to the target directory
pushd /home/cair/Downloads/redhat_repo || { echo "Failed to enter directory: /media/cair/redhat_repo"; exit 1; }

echo "Redhat sync start"

# Download files with wget
wget --recursive --mirror --continue https://updates.clustervision.com/mirror/rhel9/ || { echo "Download failed"; popd; exit 1; }

echo "Redhat sync done"

# Return to the previous directory
popd







#Offline Setup Steps:--

1.Disable SELinux:
sestatus  # Check SELinux status

# Set SELinux to permissive temporarily
sudo setenforce 0

# To disable SELinux permanently, edit the config file:
sudo sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

Note: After setting SELinux to disabled, a system reboot is required to apply the permanent change.



2. Mount the RHEL ISO and Create Local Repository

# Create directory for mounting the ISO
mkdir -p /mnt/cair/redhat_iso

# Mount the RHEL 9 ISO to the directory
sudo mount /run/media/cair/RHEL-9-4-0-BaseOS-x86_64 /mnt/cair/redhat_iso

# Copy the ISO contents to the repository directory for permanent storage
sudo cp -r /mnt/cair/redhat_iso/* /mnt/cair/redhat_iso/

# Unmount the ISO after copying
sudo umount /run/media/cair/RHEL-9-4-0-BaseOS-x86_64

Note: Ensure the ISO path is accurate; modify /run/media/cair/RHEL-9-4-0-BaseOS-x86_64 as needed.



3.Set Up Local YUM Repository Configuration

# Create a local YUM repository configuration file
sudo tee /etc/yum.repos.d/local.repo > /dev/null <<EOL
[local-repo]
name=Local Repository
baseurl=file:///mnt/cair/redhat_iso/
enabled=1
gpgcheck=0
EOL


4. Generate Repository Metadata

# Navigate to the ISO copy location and generate repository metadata
cd /mnt/cair/redhat_iso/
sudo createrepo .


5. Disable Subscription Manager for Offline Mode

# Disable Subscription Manager plugin by setting enabled to 0
sudo sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/subscription-manager.conf

# Optionally, rename the default redhat.repo file to avoid conflicts
sudo mv /etc/yum.repos.d/redhat.repo /etc/yum.repos.d/redhat.repo.disabled


6. Refresh YUM Cache and Verify Repository

# Clean all YUM cache to ensure it uses the new offline repository
sudo yum clean all
sudo yum repolist


7. Install Necessary Packages Manually

# Install createrepo
sudo yum install -y createrepo

# Install Java 17 (OpenJDK)
sudo yum install fontconfig java-17-openjdk

# Install Nginx
sudo yum install -y nginx

# Install Git
sudo yum install -y git









