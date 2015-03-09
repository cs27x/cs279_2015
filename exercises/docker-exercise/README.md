
= Introduction to Docker

## Installing Docker

If you are running Windows or OS X, please install Boot2Docker: http://boot2docker.io/

If you are running Linux, please install Docker: https://docs.docker.com/installation/#installation

## Step 1: Running an Existing Container

1. Clone this repo
2. Create a new directory called "cs279mongo"
3. Run Boot2Docker on Windows/OSX or open a terminal on Linux and 
   and change to the cs279mongo directory that you created
4. Run the command "docker run --name some-mongo -d mongo"
   
   This command will download and launch a preconfigured MongoDB instance inside
   of a Docker container. There are 1,000s of preconfigured containers available on
   https://registry.hub.docker.com/. 
   
5. After the container launches, you can see it in the list of running containers by
   typing "docker ps"
   
   By default, Docker doesn't expose the container's ports to the host, so we can't
   access it. We need to relaunch the container and expose the container to the host
   (e.g., your computer) so that you can access it.
   
6. Stop the container by typing "docker kill <id\_of\_docker\_container\_from\_ps>

7. Relaunch the container with port forwarding "docker run -p 9200:27017 -d mongo"

   This command launches the container and forwards port 9200 from the host to port
   27017 on the container. 
   
8. [Boot2Docker Users] Run "boot2docker ip" to get the IP address of the virtual machine
   running Docker. You will also need to launch the VirtualBox console that was installed
   with Boot2Docker, select the boot2docker-vm, Network, Port Forwarding, and add the 
   following new rules:
   
   1. elk TCP 127.0.0.1 9200 <leave guest ip blank> 9201
   2. elk2 TCP 127.0.0.1 5000 <leave guest ip blank> 5000
   3. elk3 TCP 127.0.0.1 5601 <leave guest ip blank> 5601
   4. node TCP 127.0.0.1 3000 <leave guest ip blank> 3000
   
   [Linux Users] Docker runs natively and you will use localhost as the IP address of the
   Docker instance.
   
9. To access MongoDB, open a web browser and visit http://<ip\_from\_step\_8>:9200

   You should see a message about accessing MongoDB using HTTP on the native driver port
   
10. Stop the MongoDB container "docker kill <mongo\_container\_id>"



