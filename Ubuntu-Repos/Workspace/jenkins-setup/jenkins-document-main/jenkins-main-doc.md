#Downloading and running Jenkins in Docker(http to https)

docker pull jenkins/jenkins

#Save Docker Images as Tar File
docker save -o jenkins-latest.tar jenkins/jenkins:latest

#Load Docker Images on the Offline Machine
docker load -i jenkins-latest.tar

#Setting Up Jenkins Using Docker Compose
mkdir -p /home/username/jenkins-setup
cd /home/username/jenkins-setup
touch  docker-compose.yml

#Create the docker-compose.yml File
nano docker-compose.yml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:latest  # Use the latest Jenkins image
    container_name: jenkins        # Name the container 'jenkins'
    ports:
      - "8080:8080"                # Map port 8080 of the host to port 8080 of the container (Jenkins web interface)
      - "50000:50000"              # Map port 50000 of the host to port 50000 of the container (Jenkins agent communication port)
#      - "8443:8443"                # Map port 8443 of the host to port 8443 of the container (Jenkins HTTPS interface)
    volumes:
      # Named Volume
      - jenkins_home:/var/jenkins_home  # Persist Jenkins data using a named volume 'jenkins_home'

      # Bind Mounts
      - /var/run/docker.sock:/var/run/docker.sock  # Allow Jenkins to manage Docker containers by mounting the Docker socket, Allows Jenkins to communicate with and manage Docker containers on the host.
      - /usr/bin/docker:/usr/bin/docker  # Mount the Docker binary to enable Jenkins to use Docker commands, provides Jenkins access to the Docker CLI to execute Docker commands.
    environment:
      - JENKINS_HOME=/var/jenkins_home  # Set Jenkins home directory
    restart: unless-stopped  # Automatically restart Jenkins if it stops

volumes:
  jenkins_home:



#main
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:latest
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock  #allows Jenkins to communicate with Docker.
      - /usr/bin/docker:/usr/bin/docker #makes the Docker CLI available to Jenkins.
    environment:
      - JENKINS_HOME=/var/jenkins_home
    restart: unless-stopped

volumes:
  jenkins_home:



##note:
Named Volumes (e.g., jenkins_home) are defined in the global volumes section for persistent storage managed by Docker.

Bind Mounts (e.g., /var/run/docker.sock and /usr/bin/docker) are defined within the services section for direct access to host resources specific to the service's needs.


#Start Jenkins
docker-compose up -d

#Accessing Jenkins
http://localhost:8080  http://jenkins.isrd.cair.drdo:8080

#Unlock Jenkins:
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword

#plugins setup

The main reason for this is the Jenkins Plugin Manager CLI, which ensures that all specified plugins and their dependencies are downloaded to guarantee proper functionality.

#Copy Plugins into the Running Jenkins Container:
docker cp /home/newuser/github-online/dokcer-setup/jenkins-docker-doc/jenkins_plugins/. jenkins:/var/jenkins_home/plugins
docker restart jenkins
docker exec -it jenkins bash
cd /var/jenkins_home/plugins
exit

http://localhost:8080





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

##jenkins for https docker-compose.yml file

sudo nano docker-compose.yml
version: '3.8'
services:
  jenkins:
    image: jenkins/jenkins:latest
    hostname: jenkins.isrd.cair.drdo
    container_name: jenkins
    user: root
    ports:
      - "8080:8080"
      - "8443:8443"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
      - ./certs/jenkins.jks:/var/jenkins_home/ssl/jenkins.jks
      - ./ca-certificates:/usr/local/share/ca-certificates
      - ./tuleap.crt:/etc/ssl/certs/tuleap.crt
      - ./entrypoint.sh:/entrypoint.sh
    entrypoint: ["/entrypoint.sh"]
    environment:
      - JENKINS_HOME=/var/jenkins_home
      - JENKINS_OPTS=--httpPort=-1 --httpsPort=8443 --httpsKeyStore=/var/jenkins_home/ssl/jenkins.jks --httpsKeyStorePassword=cair123
    networks:
      - tuleap-setup_shared-network

volumes:
  jenkins_home:

networks:
  tuleap-setup_shared-network:
    external: true

    
##jenkins web-server file    
#jenkins.conf
server {
    listen 80;
    server_name jenkins.isrd.cair.drdo;

    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 8443 ssl;
    server_name jenkins.isrd.cair.drdo;

    ssl_certificate /etc/pki/undercloud-certs/server.crt.pem;
    ssl_certificate_key /etc/pki/undercloud-certs/server.key.pem;
    ssl_client_certificate /etc/pki/undercloud-certs/ca.crt.pem;
   

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_redirect http://localhost:8080 https://jenkins.isrd.cair.drdo;
    }

    location /websocket {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}




#theory
1. bridge:
--Bridge Network: A virtual network that connects multiple containers, allowing them to communicate with each other.
--driver: bridge: Creates a virtual network bridge, allowing containers to communicate with each other.
--In Docker Compose, driver refers to the network driver that manages the network.
--shared-network is a more general term that refers to any network that is shared among multiple containers.

2. driver
To avoid confusion, let's simplify:

In Docker, a "driver" refers to a built-in component that manages a specific aspect of containerization, such as:

- Network drivers (e.g., bridge, overlay)
- Volume drivers (e.g., local, nfs)

3. jenkins

--root-user: root - runs the container with root privileges (admin access)
--- Grant administrative access
- Allow the container to perform actions that require root privileges
- Enable the container to modify system files and settings
eg: jenkin-user
--limited access and permissions

4. Volumes
1. --jenkins_home:/var/jenkins_home:Maps Jenkins data to a persistent storage location, so data is retained even if the container is restarted or deleted.
2. --/var/run/docker.sock:is a Unix socket file that allows communication between the container and the Docker daemon on the host.
- 1. Docker CLI (command-line interface)
- 2. Docker daemon (the background process that manages containers)
../var/run/docker.sock:/var/run/docker.sock:Allows Jenkins to communicate with the Docker daemon, enabling Jenkins to build, run, and manage Docker containers.(- Build: Create Docker images, Run: Start Docker containers, Manage: Control and configure Docker containers(e.g., stop, restart, delete).
..Gives Jenkins permission to control Docker.
..It will work only for Docker commands.
- docker ps
- docker run
- docker build
- docker stop

3. --/usr/bin/docker:/usr/bin/docker:Maps the Docker binary, enabling the container to run Docker commands.
1. Socket: Allows talking to the Docker daemon.
2. Binary: Provides the Docker command-line tool.( while the binary provides a direct command-line interface.)

examples-

Socket Examples

1. docker ps (lists running containers)
2. docker run -it ubuntu bash (runs a new container)
3. docker stop my-container (stops a running container)

Binary Examples

1. docker --version (displays Docker version)
2. docker info (displays Docker system information)
3. docker login (logs in to a Docker registry)

4. --./certs/jenkins.jks:/var/jenkins_home/ssl/jenkins.jks: allows Jenkins to use a custom SSL/TLS certificate for secure connections.
..This line maps a local file (./certs/jenkins.jks) to a file inside the container (/var/jenkins_home/ssl/jenkins.jks).
..A Java keystore (JKS) file is a secure file format used to hold certificate information for Java applications.

--Purpose:
..jenkins uses this certificate to establish secure connections (HTTPS) between the Jenkins server and clients (e.g., web browsers, API clients).
..Location: /var/jenkins_home/ssl/jenkins.jks
- /var/jenkins_home is the default home directory for the Jenkins user in the Docker image.
- ssl is a subdirectory within the Jenkins home directory, where SSL/TLS certificates and keys are stored.
- jenkins.jks is the default filename for the Java Keystore file that stores the SSL/TLS certificate and private key.
- jenkins.jks:
1. Server Certificate (server.crt.pem): Jenkins' SSL/TLS certificate.
2. Private Key (server.key.pem): Private key associated with the server certificate.
3. CA Certificate (ca.crt.pem): Certificate Authority (CA) certificate that signed the server certificate.

These three certificates are now bundled together in the jenkins.jks file, ready for use with Jenkins!



After mapping:
1. Jenkins container starts: The Jenkins Docker container starts, and the mapped volume is mounted.
2. Jenkins configures SSL/TLS: Jenkins detects the jenkins.jks file in the /var/jenkins_home/ssl directory and uses it to configure SSL/TLS encryption.
3. Custom certificate is used: Jenkins uses the custom SSL/TLS certificate stored in the jenkins.jks file to establish secure connections (HTTPS) with clients.
4. Jenkins is accessible via HTTPS: You can now access the Jenkins web interface using HTTPS (e.g., (jenkins.isrd.caird.drdo)).
5. Mapping ./certs/jenkins.jks to /var/jenkins_home/ssl/jenkins.jks allows Jenkins to use a custom SSL/TLS certificate for secure connections.


5. ./ca-certificates:/usr/local/share/ca-certificates: This maps a local directory (./ca-certificates) to a directory inside the container (/usr/local/share/ca-certificates).
Purpose:
--Updates the container's trusted Certificate Authorities (CAs) with custom certificates.
--It adds custom Certificate Authorities (CAs) to the container's trust store, so that Jenkins can trust and connect to other services that use those CAs.
- jenkins.jks is for Jenkins' own SSL/TLS certificate.
- ca-certificates is for trusting other services' SSL/TLS certificates.
- note:
--./ca-certificates:/usr/local/share/ca-certificates adds the CA certificate to the container's trust store.
--CA certificate file is actually named my_ca.crt, not ca.crt.pem.
So, the correct CA certificate being added to the container's trust store is indeed my_ca.crt.

- Finally, I define:
1. Mapping ./ca-certificates:/usr/local/share/ca-certificates adds the CA certificate (my_ca.crt) to the container's trust store, allowing it to trust the certificate chain and establish secure connections.

2. jenkins.jks contains Jenkins' SSL/TLS certificate and private key.



6. ./tuleap.crt:/etc/ssl/certs/tuleap.crt: Maps the local tuleap.crt file to the container's /etc/ssl/certs/tuleap.crt location.

- Purpose:
Adds the Tuleap certificate to the container's trusted certificates store.

- Effect:
The container will trust the Tuleap certificate and establish secure connections.


7. ./entrypoint.sh:/entrypoint.sh : 
host:
1. Updates CA certificates using update-ca-certificates.
2. Imports the Tuleap certificate into the Java truststore using keytool.
3. Starts Jenkins using exec /usr/local/bin/jenkins.sh.

composefile:
1. ./entrypoint.sh:/entrypoint.sh: Maps the local entrypoint.sh script to the container's /entrypoint.sh location.
2. entrypoint: ["/entrypoint.sh"]: Specifies that the container's entrypoint should be the /entrypoint.sh script.

#when the container starts, it will execute the entrypoint.sh script, which contains the commands to update CA certificates, import the Tuleap certificate, and start Jenkins.


9. tuleap-setup_shared-network: network is defined in the Jenkins Compose file, and its purpose is to enable communication between containers in the Jenkins setup.
--By connecting to this shared network, services in the Jenkins setup can communicate with each other, facilitating tasks like:

- Jenkins master-slave communication
- Service discovery
- Data exchange between services


10. networks:
  tuleap-setup_shared-network:
    external: true

purpose:
1.Networks Configuration

- networks: specifies the networks for the service
- tuleap-setup_shared-network: the name of the network
- external: true: indicates that the network is created and managed outside of this Docker Compose file

2.What it Means

- The service connects to the pre-existing tuleap-setup_shared-network network
- Docker Compose won't create the network; it assumes it already exists

3.Purpose

- Enables communication between services in the Jenkins setup
- Simplifies setup and management of the Jenkins environment


##jenkins.conf
Server Block 1
- Listens on port 80
- Redirects HTTP to HTTPS

Server Block 2
- Listens on port 8443 (HTTPS)
- Configures SSL/TLS certificates

SSL/TLS Configuration
- Specifies certificate, key, and client certificate locations

Proxy Configuration
- Proxies requests from Nginx to Jenkins on localhost:8083

WebSocket Configuration
- Configures WebSocket proxying for Jenkins





#https jenkins(java-keys)

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
















































