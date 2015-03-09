
Introduction to Docker 
----------------------


## Installing Docker

If you are running Windows or OS X, please install Boot2Docker: http://boot2docker.io/

If you are running Linux, please install Docker: https://docs.docker.com/installation/#installation

## Step 1: Running an Existing Container

A powerful part of Docker is the ability to reuse containers created by other people. For the first step, we are
going to run a MongoDB container from Docker Hub (GitHub for Docker containers). 

1. Clone this repo
2. Run Boot2Docker on Windows/OSX or open a terminal on Linux and 
   and change to the directory containing this repo
3. Run the command "docker run --name some-mongo -d mongo"
   
   This command will download and launch a preconfigured MongoDB instance inside
   of a Docker container. There are 1,000s of preconfigured containers available on
   https://registry.hub.docker.com/. 
   
4. After the container launches, you can see it in the list of running containers by
   typing "docker ps"
   
   By default, Docker doesn't expose the container's ports to the host, so we can't
   access it. We need to relaunch the container and expose the container to the host
   (e.g., your computer) so that you can access it.
   
5. Stop the container by typing "docker kill <id\_of\_docker\_container\_from\_ps>

6. Relaunch the container with port forwarding "docker run -p 9200:27017 -d mongo"

   This command launches the container and forwards port 9200 from the host to port
   27017 on the container. 
   
7. [Boot2Docker Users] Run "boot2docker ip" to get the IP address of the virtual machine
   running Docker. You will also need to launch the VirtualBox console that was installed
   with Boot2Docker, select the boot2docker-vm, Network, Port Forwarding, and add the 
   following new rules:
   
   1. elk TCP 127.0.0.1 9200 <leave guest ip blank> 9201
   2. elk2 TCP 127.0.0.1 5000 <leave guest ip blank> 5000
   3. elk3 TCP 127.0.0.1 5601 <leave guest ip blank> 5601
   4. node TCP 127.0.0.1 3000 <leave guest ip blank> 3000
   
   [Linux Users] Docker runs natively and you will use localhost as the IP address of the
   Docker instance.
   
8. To access MongoDB, open a web browser and visit http://<ip\_from\_step\_8>:9200

   You should see a message about accessing MongoDB using HTTP on the native driver port
   
9. Stop the MongoDB container "docker kill <mongo\_container\_id>"

## Step 2: Building Your First Container

Next, we are going to create our own container that has two useful tools: NodeJs and Logstash. 

Logstash is a log collection and processing framework. Logstash is commonly used to collect logs across a group of distributed
servers. In the next step, we are going to use Logstash to collect logs from NodeJS apps, insert them into an Elasticsearch
instance (an opensource distributed database/search engine), and then use Kibana to build a dashboard to track what is happening
on the nodes.

1. Create a mycontainer directory
2. Change to the mycontainer directory that you created
2. Create a new file called "Dockerfile"
3. Add the following lines to the file and save it:

```
FROM dockerfile/java:oracle-java8
WORKDIR /cs279
ADD . /cs279
```

The Dockerfile specifies how to build a new container. This container is based on an existing container "dockerfile/java:oracle-java8". The only new additions to the existing container are a new working directory "cs279"
and the inclusion of the contents of the current host directory's contents inside the /cs279 directory in the container.

4. Now, we are going to build a container with this Dockerfile. Run "docker build -t cs279java ."
5. We can now run and test our new container by running a shell inside of it with "docker run -i -t cs279java /bin/bash" 

   When you get to the shell, run "java" to make sure that it was properly set up. Then, type "exit" to leave the container.
   
6. Open the Dockerfile and update it as shown below to instruct Docker to download and install Logstash when it builds
   the container:

```
FROM dockerfile/java:oracle-java8
WORKDIR /cs279
ADD . /cs279

ADD https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz /logstash.tar.gz
RUN tar -xvf /logstash.tar.gz
```

7. Build the new container by running "docker build -t cs279logger ."
8. Launch the new container with "docker run -i -t cs279logger /bin/bash" and run "ls" to make sure that the logstash was downloaded and untarred. You should also see the Dockerfile that you created in the /cs279 directory. Type "exit" to leave the container.
9. Next, we are going to add NodeJS to the container as follows:

```
FROM dockerfile/java:oracle-java8
WORKDIR /cs279
ADD . /cs279

ADD https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz /logstash.tar.gz
RUN tar -xvf /logstash.tar.gz

ADD http://nodejs.org/dist/v0.12.0/node-v0.12.0-linux-x64.tar.gz node-v0.12.0-linux-x64.tar.gz
RUN tar -xvf node-v0.12.0-linux-x64.tar.gz
ENV PATH=$PATH:/cs279/node-v0.12.0-linux-x64/bin
```

This command downloads NodeJS, untars it, and then adds the NodeJS bin directory to the path. 

10. Rebuild the container using the command "docker build -t cs279logger ."
11. Launch the container again with "docker run -t -i cs279logger /bin/bash" and then check that NodeJS was installed by running "npm". 
12. You have now built a new container called "cs279logger" that has Java 8, Logstash, and NodeJS installed. 



