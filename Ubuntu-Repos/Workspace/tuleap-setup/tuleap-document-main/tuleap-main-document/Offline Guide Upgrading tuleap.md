# Offline Guide: Upgrading Tuleap Community Edition in Docker

# Step 1: Access the Container
docker exec -it 658fce84eb0a /bin/bash

# Step 2: Check Installed Tuleap Packages
rpm -qa | grep tuleap

# Step 3: Check Tuleap Version
tuleap --version

# Step 4: Check Docker Volumes
docker volume ls
docker volume inspect tuleap-setup_db-data
docker volume inspect tuleap-setup_tuleap-data


# Step 5: Identify Mounting Points on Host Machine
1. Database Volume (tuleap-setup_db-data):
# Mountpoint: /var/lib/docker/volumes/tuleap-setup_db-data/_data
# Purpose: This volume stores the MySQL database data, including all your records, tables, and schema. It's essential for maintaining your project, user, and configuration data.

2. Tuleap Data Volume (tuleap-setup_tuleap-data):
# Mountpoint: /var/lib/docker/volumes/tuleap-setup_tuleap-data/_data
# Purpose: This volume contains other Tuleap application data, such as configuration files and logs. It ensures Tuleap maintains its state and operates correctly.

# Step 6: Backup Your Data
# Volumes: Ensure all your data is stored in Docker volumes or bind mounts.
# Manual Backup: Use docker cp to copy important files from the container to your host.
# Volume Backup:
cp -r /var/lib/docker/volumes/tuleap-setup_db-data/_data /path/to/backup/
cp -r /var/lib/docker/volumes/tuleap-setup_tuleap-data/_data /path/to/backup/

# MySQL Database Backup:
docker exec -it <container_id> /usr/bin/mysqldump -u root --password=<your_password> tuleap_db > tuleap_backup.sql

# Step 7: Stop and Remove the Old Container
docker stop <container_id>
docker rm <container_id>
docker rmi <image_id>

# Step 8: Pull the Latest Update Image
docker pull tuleap/tuleap-community-edition:latest
docker save tuleap/tuleap-community-edition:latest -o tuleap_latest.tar
docker load -i tuleap_latest.tar

# Step 9: Bring Down and Up the Docker Compose
docker-compose down
docker-compose up -d

# Notes:
# 1. docker-compose down:
# Stops and Removes Containers: All running containers defined in your docker-compose.yml file will be stopped and removed.
# Networks: Any networks defined in the docker-compose.yml will also be removed.
# Volumes: By default, named volumes (tuleap-data, db-data) are not removed. Your data stored in these volumes will remain intact.

# 2. docker-compose up -d:
# Recreates Containers: Docker Compose will recreate all containers as per your docker-compose.yml file using the latest version of the images specified. If you haven't changed the image tag in your docker-compose.yml file, it will use the same images that were there before.
# Attaches Volumes: It will re-attach the named volumes (tuleap-data, db-data) to the new containers, thus preserving all your data.
# Starts Services: All services will start up again using the configurations and data from your volumes.

# Note: Docker does not support assigning fixed container IDs.

