
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
   
5. Stop the container by typing "docker kill id\_of\_docker\_container\_from\_ps

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
   
8. To access MongoDB, open a web browser and visit http://ip\_from\_step\_8:9200

   You should see a message about accessing MongoDB using HTTP on the native driver port
   
9. Stop the MongoDB container "docker kill mongo\_container\_id"

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

4. Now, we are going to build a container with this Dockerfile. Run "docker build -t cs279java ." The "-t" flag and "cs279java" tell Docker what to name the container. You can change the name of a container by changing the value passed with the "-t" flag.

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

7. Build the new container by running "docker build -t cs279base ."
8. Launch the new container with "docker run -i -t cs279base /bin/bash" and run "ls" to make sure that the logstash was downloaded and untarred. You should also see the Dockerfile that you created in the /cs279 directory. Type "exit" to leave the container.
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

10. Rebuild the container using the command "docker build -t cs279base ."
11. Launch the container again with "docker run -t -i cs279base /bin/bash" and then check that NodeJS was installed by running "npm". 
12. You have now built a new container called "cs279base" that has Java 8, Logstash, and NodeJS installed. 

## Step 3: Running a NodeJS App

Now that we have built a container with NodeJS and other frameworks, we can now run a simple NodeJS app inside of it. We are going to run a NodeJS / Express word finder app (see https://github.com/cs27x/word-finder). 

0. Open the cs279webapp directory
1. Open the Dockerfile and look at it:

```
FROM cs279base
WORKDIR /cs279
ADD . /cs279
RUN git clone https://github.com/cs27x/word-finder.git
RUN cd word-finder && npm install
CMD /cs279/start.sh
EXPOSE 3000
```

First, notice that we are building on top of the container that we built in the previous step. This new container
clones an existing NodeJS app from a Git repo and then downloads its NodeJS dependencies using npm. This Dockerfile includes two new concepts:

   1. CMD - specifies the default command that is run after the container starts. In the previous step, you provided    
     "/bin/bash" as the command to run inside of the container. By providing a CMD option, you can eliminate having to open a        shell and allow Docker to automatically start your app. 
   2. EXPOSE - opens the specified port on the container to receive incoming connections

2. Build the new container -- you should know how to do this now -- and name it "cs279logger". 
3. Run the container with "docker run -p 3000:3000 cs279logger &" 
4. Open a browser to http://docker\_ip:3000/ and you should see the word count application
5. Use "docker ps" to find the container ID and kill it
 
## Installing Docker-Compose

Install Docker-Compose as described here: https://docs.docker.com/compose/install/

## Coordinating Multiple Containers with Docker-Compose

Now, we are going to set up distributed log collection and a dashboard to track our nodes. To do this, we need to set up the Elasticsearch distributed database and search engine. We are also going to install Kibana, a web-base dashboard for Elasticsearch. This step will require creating two separate containers and configuring them so that they can talk to each other.

1. Edit the first line of the start.sh file so that it reads as follows (logstash.conf --> logstash.distributed.conf):

```
logstash-1.4.2/bin/logstash -f logstash.distributed.conf &
cd word-finder && /cs279/node-v0.12.0-linux-x64/bin/node server.js > word.log
```
2. Rebuild the container with "docker build -t cs279logger ." 
3. Change to parent directory
4. Open the docker-compose.yml file, which should look like this:

```
web:
  image: cs279logger
  links:
    - elk
  ports:
    - "5005:5005"
    - "3000:3000"
elk:
  image: sebp/elk
  ports:
    - "5601:5601"
    - "9200:9200"
    - "5000:5000"
```
Docker-Compose is a tool for launching and coordinating multiple containers. In the example above, we are launching two different container instances tagged "web" and "elk". The "web" instance is using our "cs279logger" container that we created in the previous step. The "elk" instance is using a preconfigured Elasticsearch and Kibana container from Docker Hub. The "links" section of the web instance tells Docker-Compose that the web instance needs to be able to see the "elk" instance and adds a "elk" host to the web instance's host file. This change allows the web instance to refer to the host "elk" and access the elk instance (this is how Logstash finds the Elasticsearch instance in the logstash.distributed.conf file).

5. Launch the entire set up by running "docker-compose up". Docker-Compose should launch and configure both containers. When you see a message like this:

```
web_1 | {:timestamp=>"2015-03-09T14:52:14.437000+0000", :message=>"Using milestone 2 input plugin 'file'. This plugin should be stable, but if you see strange behavior, please let us know! For more information on plugin milestones, see http://logstash.net/docs/1.4.2/plugin-milestones", :level=>:warn}
```
The entire stack should be running. 

6. Check that the word finder app is up by going to http://docker\_ip:3000/ and running a word search
7. We can now check that the distributed log management is running by going to http://docker\_ip:5601 and opening Kibana
8. Try creating a Kibana visualization of the top 10 search terms

