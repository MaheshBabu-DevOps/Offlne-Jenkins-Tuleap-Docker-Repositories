Offical document theory:

Prerequisites
#stage1

#Need docker on your host and docker-compose as well.

#stage2

#Deployment Assumption (outside on your server)
single Visible Container: The Tuleap container will be the only visible container on the server, meaning it will publish its web (80, 443) and SSH (22) ports directly on the host.

#Explanation:
Host Machine (Ubuntu): This is your server running the Ubuntu operating system where Docker is installed.

Docker Container (Tuleap): This is a lightweight, standalone, and executable software package that includes everything needed to run Tuleap: the code, runtime, system tools, libraries, and settings.

#Port Mapping:
When the Tuleap container is set up, it will map its internal service ports to the host machine's ports
#Tuleap Container Ports:
Internal HTTP port (usually 80)

Internal HTTPS port (usually 443)

Internal SSH port (usually 22)

#Host Machine Ports:
$sudo apt update
$sudo apt install ufw
$sudo ufw enable
$sudo ufw allow 22
$sudo ufw allow 80
$sudo ufw allow 443
$sudo ufw status

#screen
Status: active

To                         Action      From
--                         ------      ----
22                         ALLOW       Anywhere
80                         ALLOW       Anywhere
443                        ALLOW       Anywhere
22 (v6)                    ALLOW       Anywhere (v6)
80 (v6)                    ALLOW       Anywhere (v6)
443 (v6)                   ALLOW       Anywhere (v6)


#stage3

#External Dependencies
A dedicated MySQL v8.0 working database with admin credentials (at first run only)
A persistent filesystem for data storage

#Dedicated MySQL v8.0 Database:

Your Image: You have the mysql:8.0 image

Dedicated: This means that the MySQL database instance is exclusively for Tuleap. It's not shared with any other applications. This exclusivity ensures better performance, reliability, and easier management.

Admin Credentials: At the initial setup, Tuleap requires admin credentials to configure the database. This setup involves creating necessary databases and users.

#Persistent Filesystem:

Purpose: This is for storing Tuleap's data persistently. Docker volumes are used for this purpose, ensuring that data remains even if the containers are restarted or updated.


#stage4
#Docker images configuration

note:
#TLS Certificates & Certification Authority
tuleap will communicate securely, but the certificate may not be trusted by users' browsers.

Default: Tuleap uses a self-signed certificate.

Ingress Controller: Delegate to Kubernetes ingress controller.

Reverse Proxy: Use a reverse proxy to manage certificates.

Custom Certificate: Replace Tuleap’s self-signed certificate with your own.

#Backup/Restore
both the database and application


#stage5

#Verify the image authenticity
note:
By verifying the image, you're making sure that the Docker image you downloaded is the official Tuleap Community Edition image. This step ensures that the image has not been altered or tampered with and that it was indeed published by the Tuleap team. It's a way to confirm you're using a genuine and secure image.

#verify the authenticity of the Tuleap Community Edition image using cosign
#you need to install cosign to verify the authenticity of the Tuleap Community Edition Docker image.

commands:
curl -LO https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign
cosign version


offline:
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign
cosign version
cd /home/newuser/tuleap-setup
cosign verify -key tuleap_docker.pub tuleap/tuleap-community-edition
cosign verify --key tuleap_docker.pub --signature signature.json --rekor rekor-metadata tuleap/tuleap-community-edition:latest


nano ~/.bashrc
nano ~/.bash_profile
export PATH=/usr/local/bin:$PATH
source ~/.bashrc
source ~/.bash_profile
echo $PATH


#stage6
#Docker Standalone
A standalone Docker setup for Tuleap simplifies deployment and maintenance, provides consistent and isolated environments, and enhances portability and scalability. This makes it a practical choice for many users and organizations looking to implement Tuleap quickly and efficiently.

diff:
#Standalone Docker Setup:

Uses individual docker run commands.

Requires manual management of each container.

Best for simple, single-container deployments or quick tests.

#Docker Compose Setup:

Uses a docker-compose.yml file to define all services.

Simplifies orchestration and management of multi-container applications.

Best for more complex, multi-service setups that require persistent storage and consistent network configurations.


#stage7
#Docker Compose

In a folder you are going to create two files .env and compose.yaml.







#If it’s for a demo/test :

/home/$USERNAME/Workspace/test-tuleap/
    ├── .env
    └── compose.yaml

$mkdir -p /home/$USERNAME/Workspace/test-tuleap
$cd /home/$USERNAME/Workspace/test-tuleap
nano .env             nano compose.yaml


# Pull images from Docker Hub
docker pull tuleap/tuleap-community-edition
docker pull redis:latest
docker pull mysql:8.0

# Save Docker Images as TAR Files
docker save -o tuleap-community-edition.tar tuleap/tuleap-community-edition:latest
docker save -o mysql-8.0.tar mysql:8.0
docker save -o redis-latest.tar redis:latest



##offline:
#Prerequisites
Docker: You need Docker installed on your host machine to run Tuleap.
Docker Compose: Managing multi-container setups

#Load Images 
docker load -i tuleap-community-edition.tar
docker load -i mysql-8.0.tar
docker load -i redis-latest.tar

#1. Set Up Docker Compose for Tuleap, MySQL, Redis

/home/username/tuleap-setup/
  ├── .env
  ├── docker-compose.yml

$mkdir -p /home/newuser/tuleap-setup
$cd /home/newuser/tuleap-setup
$touch .env docker-compose.yml

#Create the .env File
sudo nano .env
TULEAP_FQDN="tuleap.isrd.cair.drdo"
MYSQL_ROOT_PASSWORD="StrongRootPassword123"
TULEAP_SYS_DBPASSWD="TuleapDBPassword456"
SITE_ADMINISTRATOR_PASSWORD="AdminPassword789"
REDIS_PASSWORD="RedisSecurePassword321"

#Create the docker-compose.yml File
sudo nano docker-compose.yml

version: '3.8'

services:
  tuleap:
    image: tuleap/tuleap-community-edition:latest
    hostname: ${TULEAP_FQDN}
    restart: always
    container_name: tuleap
    ports:
      - "80:80"
      - "443:443"
      - "22:22"
    volumes:
      - tuleap-data:/data
#      - ./certs:/etc/pki/undercloud-certs
#      - ./nginx:/etc/nginx/conf.d
#      - ./ca-trust:/etc/pki/ca-trust/source/anchors
    depends_on:
      - db
      - redis
    environment:
      - TULEAP_FQDN=${TULEAP_FQDN}
      - TULEAP_SYS_DBHOST=db
      - TULEAP_SYS_DBPASSWD=${TULEAP_SYS_DBPASSWD}
      - SITE_ADMINISTRATOR_PASSWORD=${SITE_ADMINISTRATOR_PASSWORD}
      - DB_ADMIN_USER=root
      - DB_ADMIN_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - TULEAP_REDIS_HOST=redis
      - TULEAP_REDIS_PASSWORD=${REDIS_PASSWORD}
      - MAILER_SMTP_HOST=${MAILER_SMTP_HOST}
      - MAILER_SMTP_PORT=${MAILER_SMTP_PORT}
      - MAILER_SMTP_USERNAME=${MAILER_SMTP_USERNAME}
      - MAILER_SMTP_MAILID=${MAILER_SMTP_MAILID}
      - MAILER_SMTP_PASSWORD=${MAILER_SMTP_PASSWORD}
      - MAILER_SMTP_TLS=${MAILER_SMTP_TLS}
    networks:
      - shared-network

  db:
    image: mysql:8.0
    command: ["--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci", "--sql-mode=NO_ENGINE_SUBSTITUTION"]
    restart: always
    container_name: tuleap_db
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - shared-network

  redis:
    image: redis:latest
    restart: always
    container_name: tuleap_redis
    environment:
      - REDIS_PASSWORD=${REDIS_PASSWORD}
    volumes:
      - redis-data:/data
    networks:
      - shared-network

  mailhog:
    image: mailhog/mailhog:latest
    restart: always
    ports:
      - "1025:1025"
      - "8025:8025"
    environment:
      - MAILER_SMTP_HOST=mailhog
      - MAILER_SMTP_PORT=1025
    networks:
      - shared-network

volumes:
  tuleap-data:
  db-data:
  redis-data:

networks:
  shared-network:
    driver: bridge



$docker-compose up -d
$docker-compose logs -f tuleap
$sudo ufw allow 80,443/tcp
127.0.0.1    tuleap.isrd.cair.drdo
https://tuleap.isrd.cair.drdo  or localhost or 127.0.0.1

username: admin
passwd: AdminPassword789
cat php /usr/share/tuleap/tools/cli/reset_password.php admin newpassword



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#ssl/tls-certificates-creation
#Steps on the Ubuntu Host Machine (main)

mkdir -p ~/workspace/tuleap-setup/certs
mkdir -p ~/workspace/tuleap-setup/nginx
mkdir -p ~/workspace/tuleap-setup/ca-trust

#Create Directory Structure for CA:
sudo mkdir -p /etc/pki/CA
sudo touch /etc/pki/CA/index.txt
echo '1000' | sudo tee /etc/pki/CA/serial


#Create a Certificate Authority (CA):
mkdir server
cd server
openssl genrsa -out ca.key.pem 4096
openssl req -key ca.key.pem -new -x509 -days 7300 -extensions v3_ca -out ca.crt.pem


#Install the CA Certificate:
sudo cp ca.crt.pem /usr/local/share/ca-certificates/my_ca.crt
sudo update-ca-certificates
ls /etc/ssl/certs | grep my_ca


#Generate Server Certificate:
openssl genrsa -out server.key.pem 2048
cp /etc/ssl/openssl.cnf .
nano openssl.cnf
openssl req -config openssl.cnf -key server.key.pem -new -out server.csr.pem
sudo mkdir /etc/pki/CA/newcerts
sudo chmod 700 /etc/pki/CA/newcerts
sudo chown root:root /etc/pki/CA/newcerts
sudo openssl ca -config openssl.cnf -extensions v3_req -days 3650 -in server.csr.pem -out server.crt.pem -cert ca.crt.pem -keyfile ca.key.pem




#Steps Within the Red Hat-based Docker Container

#Modify Docker Compose File:
volumes:
  - tuleap-data:/data
  - ./certs:/etc/pki/undercloud-certs  # Mount the certificates directory
  - ./nginx:/etc/nginx/conf.d  # Mount the Nginx configuration directory



#Prepare Certificates Directory:
mkdir -p ~/workspace/tuleap-setup/certs
sudo chown -R $USER:$USER ~/workspace/tuleap-setup/certs
sudo chmod -R 755 ~/workspace/tuleap-setup/certs


#Copy Certificates to the Host Directory:
sudo cp /home/newuser/server/server.crt.pem ~/workspace/tuleap-setup/certs/
sudo cp /home/newuser/server/server.key.pem ~/workspace/tuleap-setup/certs/
sudo cp /home/newuser/server/ca.crt.pem ~/workspace/tuleap-setup/certs/


#mkdir -p ~/workspace/tuleap-setup/nginx
#Copy the Nginx Configuration File from the Container to the Host:
docker cp tuleap:/etc/nginx/conf.d/tuleap.conf ~/workspace/tuleap-setup/nginx/
sudo cp /home/newuser/server/ca.crt.pem ~/workspace/tuleap-setup/ca-trust/

cat ~/workspace/tuleap-setup/nginx/tuleap.conf
nano ~/workspace/tuleap-setup/nginx/tuleap.conf


#Copy the Certificates into the Docker Container: (optional)
docker cp /home/newuser/server/server.crt.pem tuleap:/etc/pki/undercloud-certs/
docker cp /home/newuser/server/server.key.pem tuleap:/etc/pki/undercloud-certs/
docker cp /home/newuser/server/ca.crt.pem tuleap:/etc/pki/undercloud-certs/

#Access the Docker Container:
docker exec -it tuleap /bin/bash

#Combine Certificates (o)
cat /etc/pki/undercloud-certs/server.crt.pem /etc/pki/undercloud-certs/server.key.pem > /etc/pki/undercloud-certs/undercloud.pem


#Update the Configuration File:
vi /etc/pki/undercloud-certs/undercloud.conf
undercloud_service_certificate = /etc/pki/undercloud-certs/undercloud.pem


#Update Trusted Certificate Authorities:
cp /etc/pki/undercloud-certs/server.crt.pem /etc/pki/ca-trust/source/anchors/
cp /etc/pki/undercloud-certs/ca.crt.pem /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract
sudo update-ca-trust


#Update Nginx Configuration:

server {
    listen 443 ssl;
    server_name yourdomain.com;
    ssl_certificate /etc/pki/undercloud-certs/server.crt.pem;
    ssl_certificate_key /etc/pki/undercloud-certs/server.key.pem;
    ssl_client_certificate /etc/pki/undercloud-certs/ca.crt.pem;
}


#Test and Reload Nginx Configuration:
nginx -t
nginx -s reload
docker restart tuleap

#Verify the SSL/TLS Configuration(host and container)
openssl s_client -connect tuleap.isrd.cair.drdo:443 -servername tuleap.isrd.cair.drdo


#troubleshoot:

#Check Certificate Permissions
docker exec -it tuleap ls -l /etc/pki/undercloud-certs/
docker exec -it tuleap chmod 644 /etc/pki/undercloud-certs/server.crt.pem
docker exec -it tuleap chmod 644 /etc/pki/undercloud-certs/server.key.pem
docker exec -it tuleap chmod 644 /etc/pki/undercloud-certs/ca.crt.pem

#Verify Nginx Configuration
docker exec -it tuleap cat /etc/nginx/conf.d/tuleap.conf
docker exec -it tuleap nginx -s reload

#nginx logs
docker exec -it tuleap tail -f /var/log/nginx/access.log
docker exec -it tuleap tail -f /var/log/nginx/error.log

#verify host and container 
openssl s_client -connect tuleap.isrd.cair.drdo:443 -servername tuleap.isrd.cair.drdo


#Steps to Import the CA Certificate Correctly
For Firefox:
Open Firefox.
Go to Preferences > Privacy & Security > Certificates > View Certificates.
Import the CA Certificate:
Click on the "Authorities" tab.
Click on "Import" and select your CA certificate file (e.g., ca.crt.pem).
Ensure you are importing it as a "Certificate Authority" and not as a "Client Certificate".
Check the box to trust this CA to identify websites







#Tuleap
1. #network both side

1. login tuleap container
2. openssl s_client -connect tuleap.isrd.cair.drdo:443 -showcerts
3. Save the Tuleap server's certificate
4. openssl on container tuleap copy and create a host 

#cd jenkins-setup
#sudo nano tuleap.crt
paste here conternt ssl



2. ##$ sudo nano entrypoint.sh 

#!/bin/bash

# Update CA certificates
update-ca-certificates

# Import Tuleap certificate into Java truststore
keytool -import -noprompt -trustcacerts -alias tuleap -keystore /opt/java/openjdk/lib/security/cacerts -file /etc/ssl/certs/tuleap.crt -storepass changeit

# Start Jenkins
exec /usr/local/bin/jenkins.sh



3. #keypoints
newuser@localhost:~/workspace/jenkins-setup$ ls
ca-certificates  certs  docker-compose.yml  entrypoint.sh  tuleap.crt

newuser@localhost:~/workspace/jenkins-setup/ca-certificates$ ls
my_ca.crt

newuser@localhost:~/workspace/jenkins-setup/certs$ ls
ca.crt.pem  ca.key.pem  jenkins.jks  jenkins.p12  openssl.cnf  server.crt.pem  server.csr.pem  server.key.pem  undercloud.conf

#network
3a1822e36982   tuleap-setup_shared-network   bridge    local



4. jenkins java keys setup

#https jenkins

#   Jenkins container is running and accessible through both HTTP (port 8080) and HTTPS (port 8443), the next step is to set up a reverse proxy with Nginx to ensure proper routing to Jenkins via the domain jenkins.isrd.cair.drdo

#host
mkdir ~/workspace/jenkins-setup/certs  (copy all to certs)
sudo cp /home/newuser/server/server.crt.pem ~/workspace/jenkins-setup/certs/
sudo cp /home/newuser/server/server.key.pem ~/workspace/jenkins-setup/certs/
sudo cp /home/newuser/server/ca.crt.pem ~/workspace/jenkins-setup/certs/


sudo chown -R $USER:$USER ~/workspace/jenkins-setup/certs
sudo chmod -R 755 ~/workspace/jenkins-setup/certs

#certs

#doc
sudo openssl pkcs12 -export -in /home/newuser/workspace/jenkins-setup/certs/server.crt.pem -inkey /home/newuser/workspace/jenkins-setup/certs/server.key.pem -out /home/newuser/workspace/jenkins-setup/certs/jenkins.p12 -name jenkins -CAfile /home/newuser/workspace/jenkins-setup/certs/ca.crt.pem -caname root -password pass:cair123

#ls -l /home/newuser/workspace/jenkins-setup/certs/jenkins.p12


#Convert PKCS12 to JKS Format

sudo keytool -importkeystore -deststorepass cair123 -destkeypass cair123 -destkeystore /home/newuser/workspace/jenkins-setup/certs/jenkins.jks -srckeystore /home/newuser/workspace/jenkins-setup/certs/jenkins.p12 -srcstoretype PKCS12 -srcstorepass cair123 -alias jenkins


#docker cp server.crt.pem jenkins:/tmp/server.crt.pem
docker cp ca.crt.pem  jenkins:/tmp/ca.crt.pem
docker cp server.crt.pem  jenkins:/tmp/server.crt.pem


# Import Jenkins certificate--(container inside)
keytool -import -alias jenkins -keystore $JAVA_HOME/lib/security/cacerts -file /tmp/server.crt.pem -storepass changeit -noprompt
keytool -import -alias tuleap -keystore $JAVA_HOME/lib/security/cacerts -file /tmp/server.crt.pem -storepass changeit -noprompt
 
keytool -import -alias jenkins -keystore $JAVA_HOME/lib/security/cacerts -file /tmp/ca.crt.pem -storepass changeit -noprompt
keytool -import -alias tuleap -keystore $JAVA_HOME/lib/security/cacerts -file /tmp/ca.crt.pem -storepass changeit -noprompt
 

#delete key (optional)
keytool -delete -alias jenkins -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit

 
#verify
keytool -list -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit | grep tuleap
keytool -list -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit | grep jenkins


#host and container verify
openssl s_client --connect jenkins.isrd.cair.drdo:8443
openssl s_client --connect tuleap.isrd.cair.drdo:443






///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

###Docker commands main

# List Docker Volumes
docker volume ls

# Remove a Specific Volume
docker volume rm <volume_name>

# List Containers Using a Specific Volume
docker ps -a --filter volume=jenkins_home

# Stop a Specific Container
docker stop <container_id>

# Remove a Specific Container
docker rm <container_id>

# Remove a Specific Volume
docker volume rm jenkins_home

# List Docker Volumes Again
docker volume ls

# Inspect a Specific Volume
docker volume inspect <volume_name>

# Prune Unused Volumes
docker volume prune

# Remove All Volumes
docker volume rm $(docker volume ls -q)

# Check Disk Usage
docker system df

# Inspect a Container and Find Source Path
docker inspect <container_id> | grep Source

# Backup a Volume
docker run --rm -v <volume_name>:/volume_data -v $(pwd):/backup busybox tar cvf /backup/<backup_file>.tar /volume_data

# Restore a Volume from Backup
docker run --rm -v <volume_name>:/volume_data -v $(pwd):/backup busybox tar xvf /backup/<backup_file>.tar -C /volume_data








#Additional Docker Commands

# Create a Docker Volume
docker volume create <volume_name>

# Mount a Volume to a Container
docker run -d -v <volume_name>:/path/in/container <image_name>

# Copy Files from a Container to the Host
docker cp <container_id>:/path/in/container /path/on/host

# Copy Files from the Host to a Container
docker cp /path/on/host <container_id>:/path/in/container

# List All Running Containers
docker ps

# List All Containers (including stopped ones)
docker ps -a

# Start a Stopped Container
docker start <container_id>

# Restart a Running Container
docker restart <container_id>

# Pause a Running Container
docker pause <container_id>

# Unpause a Paused Container
docker unpause <container_id>

# Inspect a Container
docker inspect <container_id>

# View Logs of a Container
docker logs <container_id>

# Execute a Command in a Running Container
docker exec -it <container_id> /bin/bash

# Remove All Stopped Containers
docker container prune

# Remove All Unused Images
docker image prune

# Remove All Unused Networks
docker network prune

# Remove All Unused Data
docker system prune

# Save a Docker Image to a Tar File
docker save -o <image_name>.tar <image_name>

# Load a Docker Image from a Tar File
docker load -i <image_name>.tar

# Tag a Docker Image
docker tag <source_image> <target_image>

# Push a Docker Image to a Registry
docker push <image_name>

# Pull a Docker Image from a Registry
docker pull <image_name>

# Build a Docker Image from a Dockerfile
docker build -t <image_name> .

# Run a Container from a Docker Image
docker run -d --name <container_name> <image_name>

# Attach to a Running Container
docker attach <container_id>

# Detach from a Running Container
Ctrl+P, Ctrl+Q

# Stop All Running Containers
docker stop $(docker ps -q)

# Remove All Containers
docker rm $(docker ps -a -q)

# Remove All Images
docker rmi $(docker images -q)
