sudo apt install docker.io docker-compose



docker info
sudo docker info
sudo getent group (put your user to docker group to 
sudo usermod -aG docker <username>
docker image pull fedora:latest
docker image ls
docker image ls -a
docker container create -it fedora bash
docker container ls
docker container ls -a
docker container start -i 985 
docker exec -it <container_id_or_name> /bin/bash
cat etc/os-release
ctrl+d / exit (stop the container)
docker image pull python
docker image ls -a
docker container run -it python (run=pull+create+start+exec) (cont1)
docker container run -it python /bin/bash (cont2)
docker container rm 097 660 
docker image rm a4c 985
ps -elf | grep docker
ps -elf | grep containerd

* get docker images from dockerhub

docker container run -it --name "AnyName" -h <hostname> RepoOwnerName/repo:tag bash
-c<commandExecutedWhenRunContainer> "/usr/local/bootstrap.sh; bash"

docker image inspect <id> (json file)


# docker in vsc
mkdir docker-work
cd docker-work/
code .
* Install docker extension
ctrl+shift+telda (open a new terminal)

*remove all stopped containers/images in one command
docker image/container rm $(docker image/container ls -q -a) (remove all ids)

* detachedMode and portMapping
docker container run -d --name webserver -p 80:80 nginx:latest

* MSSQL
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=P@ssw0rd" -e "MSSQL_PID=Express" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest

*info
server-name=.
database-name=master
username=sa
password=P@ssw0rd
new query and create database

* copy files from host to container
docker container run -it --name pythonc python:latest
* send
docker container cp ./file.py 7e0:/tmp/file.py
* check
import os
os.listdir()
os.listdir('/tmp')
exec(open('/tmp/file.py').read())

* Containers connectivity (ping+curl)
docker container run -it --name client --add-host web:172.17.0.2 centos:latest (web:ip of nginx you can check them by inspect container)
addManual/verify -> /etc/hosts

* container networking revision (theo)
docker installed with 3 networks by default per single host -> bridge, host, none.
bridge -> docker0 and 172.17.x.x by default (ip addr show)

docker container run -dit --name alpinec1 alpine
docker container run -it --name alpinec2 alpine
ctrl+p + ctrl+q (exit container without stop it)
each container has virtual adapter (vethx) 
docker container run -it --name alpinec3 --network none alpine (isolated 100%)
docker container run -d --name web --network host nginx (like: no need for portMapping) -> localhost:80


docker network drivers -> bridge, macvlan, overlay
bridge -> single host containers (default)
macvlan -> act as physical device in network but requires promiscous mode in host.
overlay -> multi host containers

docker network ls
docker network create mynet1 -d bridge , docker network create --subnet 10.0.0.0/16 mynet2 -d bridge
docker network connect mynet1 aplinec2
docker network disconnect mynet1 aplinec2

docker network create --internal mynet3 (testing environment sees each other but no internet access)


*docker storage
( Non Persistent data )
root access required

cd /var/lib/docker
overlay2 is the storage driver
cd overlay2/

docker image pull alpine (check overlay2 you will find image id cd to it)
cd diff (ls -> image file system)


docker container run -dit --name alpinec1 alpine /bin/sh
** check overlay2/ you will find the container id and any changes in the container will be logged in diff/ 


(Mounting (I call it as file system directory mapping (unusual method) -> host file system mounting
docker container run -dit -v /home/hussam/docker-work/code:/app/code --name alpinec1 alpine 
-v -> volume 

any changes here in host (/home/hussam/docker-work/code) will mapped to there in container (/app/code)

(Persistent data) -> (usual method)-> Create a volume
docker volume create myvol1
cd /var/lib/docker/volumes/<hereAllVolumes> (check them here)
docker container run -it -v myvol1:/app/code --name alpinec2 apline
 docker container run -it -v vol1:/PersistentData --name alpinec1 alpine ( i try this also)
** myvol1 -> volume in host
** : -> map to 
** /app/code -> create if not exist and here are presistent data because that volume is existed in host and the container is enable connecting/mapping that volume to somewhere in container file system (understand?yes)
check any changes here: /var/lib/docker/volumes/vol1/_data


* Build an image from custom container
docker container run -it --name pyflask python bash
update&upgrade system repositories 
apt install vim
create a file called hello.py
pip install flask
python hello.py
code:
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Flask Hello world!'

@app.route('/HussamIsWorking')
def test():
    return 'Everything is working ok with hussam'

if __name__=='__main__':
    app.run(debug=False,host='0.0.0.0', port=5000)

*create an image from this container
docker commit pyflask HussamQreie/pyflask:v1.0 (accountname/repo:tag)
*run a container from this image
docker container run -d -p 5000:5000 --name pyflaskc HussamQreie/pyflask:v1.0 python /app/hello.py 


* more efficient way to build image which is : Dockerfile

code:

# Customize an image as I want using Dockerfile 

# Image
FROM python:latest

# create this dir if not exist and cd to it
WORKDIR /app

# copy from build context directory (Dockerfile directory) anything you want, if you don't use absolute path -> to currect dir which is /app as above
# why do you import Flask from requirments.txt instead of install it directly and include it into image? modularization and recommended approach
COPY requirements.txt .

# install packages in the text file line by line
RUN pip install -r requirements.txt

# move source code there
COPY code/hello.py .

# expose in container after that we can mapping port 5000:5000
EXPOSE 5000

# this considered as an element of image structure not as metadata
CMD python hello.py

# last 2 was metadata (means it effects the container)



docker build -t HussamQreie/pyflask:v1.1 .
. -> search for dockerfile in current directory then build the image based on it
or i can give him github location to build an image based on dockerfile there.

docker container run -d -p 5000:5000 --name pyflask HussamQreie/pyflask:v1.1

# Now if i want to edit just build the image then run a container like
docker build -t HussamQreie/pyflask:v1.2 .
docker container run -d -p 5000:5000 --name pyflask HussamQreie/pyflask:v1.2


## Deep Dive in Dockerfile
FROM <Img>
Img: from offical docker repo (dockerhub), specify version, repo, scratch(kernalOnly-No layers)
, id, private registry, etc.

WORKDIR <dir> # mkdir if not exist and cd
#if i do this it means i now 2 in 1 -> (/app/subdir/) I am here
WORKDIR /app
WORKDIR subdir

COPY <src> <dest> - it by default copy from build context (dockerfile dir)
COPY hello.py /app/hello.py - it will touch if not exist and cp
COPY hello.py hi.py /app/ - copy multiple files to that dir and make sure / after /app to let docker understand it is dir not rename a file
COPY *.py /app/ - you can also use wildcards
COPY . /app/ - copy all dir but i can create file to ignore some files by .dockerignore and ! for except in it
COPY ["name with spaces", "/app"] - if the file name has spaces (exec way (like instructions) and above called shell way)

ADD - used to copy files don't exist in build context(Dockerfile Directory) like:
ADD <url> /app
ADD <tar archive> /app

SHELL - no i don't use /bin/sh by default, command behavior is diff like pipping for example
SHELL ["/bin/bash/","-c"] - in the buildtime in dockerfile use /bin/bash
SHELL ["/usr/local/bin/python", "-c"] - python shell

RUN - execute commands based on /bin/sh by default if not specified like above. in build time to become template then this template based in it run a container (executed and closed)
RUN <command> <arg1> <arg2-Optional>
RUN ["command", "arg1", "arg2"] - better and recommended - exec mode
RUN echo "This is a line" > /tmp/file
RUN echo "This is a line" >> /tmp/file
RUN cat /tmp/file
RUN find / -name "python*" | wc -l
RUN pip install flask numpy
RUN apt update && apt upgrade -y -- simple debug build of image to make sure error in build not in the container itself and this command is not exclusive all commands same thing
RUN apt install vim openssh-server wget -y

Metadata - no edit in image no edit in runtime it is destrictive to know something. info you will find it when you do inspection of image (give you information like comments) like LABEL
but there are metadata effect inside the image like ENV

LABEL maintainer="Hussam Qrai"
LABEL description="Flask Web Application Container"

ENV <name> <value> - To Configure environment variables
like we use: export <var>=<value> - associated with the terminal
ENV SQL_SA "sa" - i don't need = if it is one arg
ENV SQL_USER=sa SQL_PASSWORD="P@ssw0rd"
ENV PATH $PATH:/app - add /app to PATH why? instead of absolute path to run a script i just do it via its name (e.g. /app/hello.py -> hello.py from shell immediatly i shouldn't be in the dir of hello.py)
ENV PATH="/usr/local/hadoop/bin:${PATH}" -- add hadoop bins to current PATH like append or insert bins in the current PATH var
ENV EMPTY "" - overwrite on it after create the container


Users - We did all our work using root but this is not recommended we need to use superuser
but we face a problem with many images doesn't have subsystem of user authentication that means we need to install packages before move to that use. so the solution is USER 


RUN groupadd hadoop && useradd -g hadoop hduser
USER hduser - like su - hduser
RUN id


ENTRYPOINT & CMD - Execute commands when run a container (runtime) , while RUN exec commands when build an image (buildtime) for example when run python container why it gives me python interpreter to execute python commands not shell so it execute a task check it via inspection and see cmd section (CMD <command>)

diff EP & CMD? - I can use this or this  ( no one understand it no worries)
but when i do -> docker container run -it python bash
bash overwrites on CMD and ENTRYPOINT so like I bypass them when write bash
I can also do this
docker container run -it --entry-point --cmd python bash 

examples:
ENTRYPOINT ["/bin/bash","-c"]
CMD ["./src/start-hadoop.sh]

but that is not recommended -> 1 container = 1 application (this is recommended)
but I can run more than one process but this conflict with the main goal of container 

AGR Instruction - Environment Variable in docker file level.
ARG <arg>=<value>
ARG PYTHON_IMAGE_NAME=python
ARG PYTHON_IMAGE_TAG=3.8.17
ARG SQL_SA=sa
ARG SQL_PASSWORD=P@ssw0rd



Image Registries
Create an account in dockerhub hub.docker.com
docker login
docker tag <imgName>:tag repoOwner/repoName:v1.1
docker image push repoOwner/repoName:v1.1



docker-compose -> python package automate deploying containers,networks,volumes.
use docker-compose.yml declaration file which is (yaml syntax -> key value format)
top components/keys: version (requierd/mandatory other than that nah), services, networks, and volumes


networks:
    counter-net:
(same as) -> docker network create counter-net
code:

version: "3.7"
services: (continers creation space)
    web-fe: -> name(icanNameItAsIWant)
        build: . -> build from build context specifically from docker file (which will build flask and redis)
        command: python app.py -> from build context run app.py file
        ports:
            -   target:5000
                published:5000
        networks:
            -   counter-net
        volumes:
            -   type: volume
                source: counter-vol
                target: /code
    redis:
        image:  "redis:alpine" -> image:tag
        networks: -> attach it to counter-net network
            counter-net:
networks:
    counter-net:

volumes:
    counter-vol


docker-compose up & -> run in the background
docker exec <ContainerID> ping google.com -c 1 -> execute command from the containr
docker-compose <ServiceName> ping google.com -c 1 -> serviceName and ContainerID used interchangably.
docker-compose exec redis ping web-fe -c 1 -> from redis ping web-fe
docker-compose exec redis ping google.com -c 1 -> from redis ping google


docker-compose down -> will delete containers+networks but images+volumes stay



docker-compose down ami -> same with del images
docker exec <containerIDFirst3> ping -c




مجموعة من الحشرات swarm
docker swarm -> service in docker to cluster docker hosts and orchestration of services on swarm network
host -> node either manager(service manager, and conf everything, it could work as manager and worker (take a load)) recommended-> 1,3,5, or 7, or worker 


docker swarm init --advertise-addr 192.168.1.128:2377 --listen-addr 192.168.1.128:2377
docker swarm join-token worker -> how to add w (copy the command is it is output in the diff host to add it as  m/w
docker swarm join-token manager -> how to add m
docker info -> see swarm is active and other info 
* if you see warning in m it should be odd number as we said
docker node ls -> view nodes in swarm
* deploy on swarm via docker service
* replicas -> number of containers like 5 copies to load balance
docker service create -name web -p 80:80 --replicas 5 nginx:latest
* service converged -> all containers up and running and I can request a service from all nodes
* ingress network created-> overlay network it comes with docker swarm which is a network seen by multiple hosts
* docker-gwbridge network created
docker service ls -> shows info about created service
docker service ps <servicename> -> info about replicas
docker container ls -> in a node
docker service rm web -> del everything about service (replicas, container) but networks stays if i do it again it will take less time of creation
docker service create -name web -p 80:80 --replicas 2 nginx:latest -> the scenario is 5,  3 m + 2 w -> in this case load will distributes to work nodes but if i go to manger node and check accessability it will work! because they are within the network and it forward service to manager from work and vice versa in other cases

docker service scale web=9 -> 9 containers for 1 service and distributed to all 5 nodes 
docker service ps web
* help tools -> visualizor which will create web user interface to control and manage docker swarm operations
docker service create --name=viz --publish=8080:8080/tcp --constraint=node.role==manager --mount=type=bind.src=/var/run/docker.sock.dst=/var/run/docker.sock dockersamples/visualizer

* create a new service now
docker service create --name web --replicas 6 nginx:1.21
docker node ls
docker service ls 
sudo service docker stop -> in a w nodes 
docker node ls -> in manager node you will find its status down
docker service ps web
docker service update --image nginx:1.2 --update-parallelism 2 --update-delay 5s web

docker service create --name ubuntu --replicas 2 ubuntu:latest -> failure!, it will retry so rm it
docker service rm ubuntu
*solution: docker service create --name ubuntu --replicas 2 ubuntu:latest bash -c "while true; do echo hello; sleep2; done"
