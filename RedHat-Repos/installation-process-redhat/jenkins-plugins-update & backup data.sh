#!/bin/bash

# Automated Jenkins Plugin Downloader (Latest Versions)
# This script automates the process of downloading the latest versions of a comprehensive list of Jenkins plugins
# to a specified directory. It ensures that all the plugins listed in your directory are downloaded efficiently.

# Set download directory
download_dir="/home/cair/Downloads/plugins"
mkdir -p "$download_dir"

# Define plugins you want to download (only .jpi plugins)
declare -a plugins=( 
    "authentication-tokens" 
    "blueocean-autofavorite" 
    "blueocean-commons" 
    "blueocean-dashboard" 
    "blueocean-github-pipeline" 
    "blueocean-git-pipeline" 
    "blueocean-jwt" 
    "blueocean-pipeline-api-impl" 
    "blueocean-pipeline-editor" 
    "blueocean-pipeline-scm-api" 
    "blueocean-rest" 
    "blueocean-rest-impl" 
    "blueocean-web" 
    "bootstrap5-api" 
    "branch-api" 
    "build-token-trigger" 
    "build-user-vars-plugin" 
    "caffeine-api" 
    "checks-api" 
    "cloudbees-disk-usage-simple" 
    "cloudbees-folder" 
    "cmakebuilder" 
    "cortex-metrics" 
    "coverage" 
    "credentials" 
    "credentials-binding" 
    "delivery-pipeline-plugin" 
    "disk-usage" 
    "display-url-api" 
    "distfork" 
    "docker-build-publish" 
    "docker-commons" 
    "docker-compose-build-step" 
    "docker-plugin" 
    "docker-slaves" 
    "docker-workflow" 
    "echarts-api" 
    "email-ext" 
    "email-ext-recipients-column" 
    "emailext-template" 
    "external-monitor-job" 
    "fail-the-build-plugin" 
    "favorite" 
    "file-parameters" 
    "font-awesome-api" 
    "forensics-api" 
    "generic-webhook-trigger" 
    "git" 
    "git-changelog" 
    "git-client" 
    "github" 
    "github-api" 
    "github-autostatus" 
    "github-branch-source" 
    "github-checks" 
    "github-oauth" 
    "github-pullrequest" 
    "gitlab-api" 
    "gitlab-branch-source" 
    "gitlab-oauth" 
    "gitlab-plugin" 
    "git-parameter" 
    "git-server" 
    "git-tag-message" 
    "gradle" 
    "junit" 
    "junit-realtime-test-reporter" 
    "last-changes" 
    "ldap" 
    "mailer" 
    "mail-watcher-plugin" 
    "mapdb-api" 
    "matrix-auth" 
    "matrix-project" 
    "maven-plugin" 
    "metrics" 
    "metrics-diskusage" 
    "monitoring" 
    "multibranch-scan-webhook-trigger" 
    "parallel-test-executor" 
    "parameterized-trigger" 
    "performance" 
    "pipeline-build-step" 
    "pipeline-github-lib" 
    "pipeline-githubnotify-step" 
    "pipeline-graph-analysis" 
    "pipeline-graph-view" 
    "pipeline-groovy-lib" 
    "pipeline-input-step" 
    "pipeline-maven" 
    "pipeline-maven-api" 
    "pipeline-milestone-step" 
    "pipeline-model-api" 
    "pipeline-model-definition" 
    "pipeline-model-extensions" 
    "pipeline-rest-api" 
    "pipeline-stage-step" 
    "pipeline-stage-tags-metadata" 
    "pipeline-stage-view" 
    "pipeline-timeline" 
    "pipeline-utility-steps" 
    "plain-credentials" 
    "plot" 
    "plugin-util-api" 
    "prometheus" 
    "publish-over" 
    "publish-over-ssh" 
    "pubsub-light" 
    "python" 
    "qtest" 
    "remote-file" 
    "role-strategy" 
    "scm-api" 
    "scp" 
    "script-security" 
    "sonar" 
    "ssh" 
    "ssh2easy" 
    "ssh-agent" 
    "ssh-credentials" 
    "sshd" 
    "ssh-slaves" 
    "ssh-steps" 
    "terminate-ssh-processes-plugin" 
    "TestComplete" 
    "testInProgress" 
    "testng-plugin" 
    "test-results-aggregator" 
    "test-results-analyzer" 
    "thinBackup" 
    "token-macro" 
    "trilead-api" 
    "tuleap-api" 
    "tuleap-git-branch-source" 
    "tuleap-oauth" 
    "view-job-filters" 
    "warnings-ng" 
    "webhook-step" 
    "workflow-aggregator" 
    "workflow-api" 
    "workflow-basic-steps" 
    "workflow-cps" 
    "workflow-cps-global-lib" 
    "workflow-durable-task-step" 
    "workflow-job" 
    "workflow-multibranch" 
    "workflow-scm-step" 
    "workflow-step-api" 
    "workflow-support" 
    "xunit" 
)

# Function to download plugin
download_plugin() {
    plugin=$1
    echo "Downloading $plugin.jpi..."
    curl -L -o "$download_dir/$plugin.jpi" "https://updates.jenkins-ci.org/download/plugins/$plugin/latest/$plugin.jpi" || {
        echo "Failed to download $plugin.jpi"
        return 1
    }
    echo "$plugin.jpi downloaded successfully."
}

# Iterate over plugins and download each one
for plugin in "${plugins[@]}"; do
    download_plugin "$plugin"
done

echo "All plugins downloaded."








offline Update Plugins:--------------

Download the latest versions of the plugins using the script.
Stop Jenkins, transfer the ZIP file to the offline machine, extract the plugins, copy them to the Jenkins plugins directory, change ownership, and start Jenkins.
# Stop Jenkins


# Transfer the ZIP file to the offline machine
# Unzip the file
sudo unzip <>.zip

sudo systemctl stop jenkins

# Copy the plugins to the Jenkins plugins directory
sudo cp /path/to/downloaded/plugins/*.hpi /var/lib/jenkins/plugins/

# Change ownership of the plugins
sudo chown jenkins:jenkins /var/lib/jenkins/plugins/*.hpi
# Restart Jenkins
sudo systemctl restart jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins



Notes:
Version Compatibility: Ensure that the new versions of the plugins are compatible with your version of Jenkins. This is important to avoid issues when starting Jenkins.
Configuration Changes: If the new version of a plugin includes changes that affect configuration or features, review the plugin's release notes for any necessary updates to your Jenkins setup.
Testing: After restarting Jenkins, check that the plugins load correctly without errors. Monitor the Jenkins logs for any issues related to the plugins.






#Backup jenkins data:---------

#!/bin/bash

# Define backup path and filename with a timestamp
BACKUP_DIR="/home/cair/jenkins_backup"
BACKUP_FILE="$BACKUP_DIR/jenkins_backup_$(date +%F).tar.gz"

# Create backup directory if it doesn’t exist
mkdir -p "$BACKUP_DIR"

# Define Jenkins directories to backup
JENKINS_HOME="/var/lib/jenkins"
JENKINS_LOGS="/var/log/jenkins"

# Run the backup command to compress
sudo tar -czvf "$BACKUP_FILE" "$JENKINS_HOME" "$JENKINS_LOGS"

# Set permissions on the backup file
sudo chown jenkins:jenkins "$BACKUP_FILE"

# Print completion message
echo "Backup completed and saved to $BACKUP_FILE"

# Optional: Cleanup old backups (e.g., keep only the last 7 backups)
find "$BACKUP_DIR" -type f -name "jenkins_backup_*.tar.gz" -mtime +7 -exec rm {} \;

# Optional: Log the backup process
echo "$(date) - Jenkins backup completed and saved to $BACKUP_FILE" >> "$BACKUP_DIR/backup.log"






