#!/bin/bash

# Update system and install tools
#sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl  openjdk-17-jdk

# Set download directory
DOWNLOAD_DIR="/home/newuser/Downloads/"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR" || exit

# Fetch latest Jenkins RPM and version number
latest_url=$(curl -s https://mirrors.jenkins-ci.org/redhat-stable/ | grep -oP 'jenkins-[0-9]+\.[0-9]+\.[0-9]+-[0-9]+\.[0-9]+.noarch.rpm' | sort -V | tail -n 1)
version=$(echo $latest_url | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')
wget "https://mirrors.jenkins-ci.org/redhat-stable/$latest_url"


# Download the Jenkins Plugin Manager CLI
curl -L -o jenkins-plugin-manager.jar https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.2/jenkins-plugin-manager-2.13.2.jar

# Create plugins.txt file with desired plugins
cat <<EOL > plugins.txt
tuleap-api:latest
tuleap-git-branch-source:latest
tuleap-oauth:latest
# Git Plugins
git:latest
git-client:latest
github-api:latest
github:latest
github-branch-source:latest
git-server:latest
git-parameter:latest
github-pullrequest:latest
git-changelog:latest
github-autostatus:latest
git-tag-message:latest
last-changes:latest
# Blue Ocean Plugins
blueocean:latest
blueocean-commons:latest
blueocean-rest:latest
blueocean-web:latest
blueocean-pipeline-scm-api:latest
blueocean-git-pipeline:latest
blueocean-dashboard:latest
blueocean-pipeline-editor:latest
# Docker-related plugins
docker-plugin:latest
docker-commons:latest
docker-workflow:latest
docker-java-api:latest
docker-compose-build-step:latest
# SSH-related plugins
ssh-credentials:latest
ssh-slaves:latest
sshd:latest
ssh-steps:latest
# Test Plugins
junit:latest
plot:latest
testInProgress:latest
performance:latest
maven-plugin:latest
autograding:latest
testng-plugin:latest
test-results-aggregator:latest
test-stability:latest
robot:latest
seleniumhtmlreport:latest
junit-realtime-test-reporter:latest
# Email plugins
email-ext:latest
emailext-template:latest
mail-watcher-plugin:latest
mailer:latest
poll-mailbox-trigger-plugin:latest
view-job-filters:latest
# Pipelines plugins
pipeline-rest-api:latest
pipeline-stage-step:latest
pipeline-input-step:latest
pipeline-model-api:latest
pipeline-build-step:latest
pipeline-graph-analysis:latest
pipeline-stage-view:latest
pipeline-utility-steps:latest
pipeline-graph-view:latest
pipeline-timeline:latest
# Webhooks and triggers
webhook-step:latest
multibranch-scan-webhook-trigger:latest
parameterized-trigger:latest
gerrit-trigger:latest
generic-webhook-trigger:latest
authentication-tokens:latest
ws-cleanup:latest
# Backup and disk usage plugins
sonar:latest
prometheus:latest
thinBackup:latest
periodicbackup:latest
backup:latest
disk-usage:latest
diskcheck:latest
role-strategy:latest
cloudbees-disk-usage-simple:latest
EOL

# Download the Jenkins WAR file using the fetched version
wget "https://get.jenkins.io/war-stable/${version}/jenkins.war"

# Download plugins and their dependencies
java -jar jenkins-plugin-manager.jar --war jenkins.war --plugin-file plugins.txt --plugin-download-directory jenkins_plugins

# Set permissions for the entire DOWNLOAD_DIR directory and its contents
chmod -R 755 "$DOWNLOAD_DIR"  # Sets read, write, and execute permissions
chown -R newuser:newuser "$DOWNLOAD_DIR"  # Replace 'cair' with the appropriate username

# Clean up unwanted files if needed
rm -f jenkins.war jenkins-plugin-manager.jar plugins.txt "$latest_url"
