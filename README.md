# docker-b00t

This projects puts together a simple SpringBoot / AngularJS application and it publish it as Docker image.

Usage
=====

Fist of all you need to install the Docker container, this is depending on the underling operation system,
for mode detail about installation consider the [Docker](http://docs.docker.com/mac/started/) site.
The interaction with Docker can be done over a command line or if you prefer you can use the [Chrome Docker](https://chrome.google.com/webstore/detail/simple-docker-ui-beta/jfaelnolkgonnjdlkfokjadedkacbnib?hl=de) extension.
The application uses MySQL as storage but you don't need to install it on your machine this will be provided as Docker image.
The project contains some bash scripts (located in the *.../src/main/bash*) yuo can use them for various docker related actions.
  
Build and publish the docker image
----------------------------------

The project provides both Gradle and Maven support.

### Gradle

The gradle task is named *buildDocker* and it is related to the *build* task, it run after it.
If you want to create a docker image for this project (using gradle) you need to run the following command:

    gradle buildDocker

This implies that you have [gradle](https://gradle.org/) installed on your machine.
If you run this command for the fist time then it may take a while, this because the docker will claim the required
images from the [docker hub](https://hub.docker.com/account/signup/). 

#### About the gradle script

The task definition:

    ....
    task buildDocker(type: Docker, dependsOn: build) {
    ....

take cares that to run it after the *gradle build*, the *gradle build* compiles and pack the entire project. 

The *push* flag:

    ....
    push = false
    ....
    
Is used to indicate that created image can be pushed to a [docker hub](https://hub.docker.com/account/signup/) (repository).
By default the official hub is used but you can create your own [private docker repository](https://hub.docker.com/account/signup/).  


The Docker file location is described with the line:

    ....
    dockerfile = file('src/main/docker/Dockerfile')
    ....

 
This task uses the [Transmode/gradle-docker](https://github.com/Transmode/gradle-docker) gradle plugin.
 
### Maven

If you want to create a docker image for this project (using maven) you need to run the following command:

    mvn package docker:build
    
This implies that you have [maven](https://maven.apache.org/) installed on your machine.
As in the gradle case, if you run this command for the fist time then it may take a while, this because the docker
will claim the required images from the [docker hub](https://hub.docker.com/account/signup/). 

This task uses the [Transmode/gradle-docker](https://github.com/Transmode/gradle-docker) gradle plugin.

#### About the POM file


The Docker file location is described with the element:

    <dockerDirectory>src/main/docker</dockerDirectory>
    
this is only the directory, the file is/must named *Dockerfile*.    


This task uses the [docker-maven-plugin/com.spotify](https://github.com/spotify/docker-maven-plugin).

#### About the Docker file

Run the image
-------------

If the image was successfully published, then the gradle/maven must provide the following output:

    Sending build context to Docker daemon 26.16 MB
    Sending build context to Docker daemon 
    Step 0 : FROM java:8
     ---> 99631e385332
    Step 1 : VOLUME /tmp
     ---> Running in 8afe0c54416b
     ---> 70edf8fa107c
    Removing intermediate container 8afe0c54416b
    Step 2 : ADD perk0ns-web-0.0.1-SNAPSHOT.jar app.jar
     ---> cbe130d9b835
    Removing intermediate container 07c8ccd63a3c
    Step 3 : RUN bash -c 'touch /app.jar'
     ---> Running in d355e7e6ee12
     ---> ebe0ec88811b
    Removing intermediate container d355e7e6ee12
    Step 4 : ENTRYPOINT java -Djava.security.egd=file:/dev/./urandom -jar /app.jar
     ---> Running in 3b81c76401f3
     ---> 927846415cb2
    Removing intermediate container 3b81c76401f3
    Successfully built 927846415cb2

the *927846415cb2* represents the docker image id. You can see all the available images by running the following command:
    
    docker images

This will produce a output like this one:

    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    perk0ns-web         latest              927846415cb2        4 minutes ago       868.6 MB
    mysql               5.6                 d63d4723d715        2 weeks ago         283.5 MB
    java                8                   99631e385332        2 weeks ago         816.3 MB
    ubuntu              14.04               6d4946999d4f        2 weeks ago         188.3 MB
    mysql               latest              e0db8fe06e30        4 weeks ago         283.5 MB

As you can see the *perk0ns-web* is present in the fist position. The image has a unique id (927846415cb2)
and a human readable name, if the name is not provided then a new name will be generated.
You can delete any imaged with :
  
    docker rmi <image name> / <ID>

#### Start MySQL

The application requires a MySQL database, in order to start if use the following command:
    
     docker run --name perkonsmysql \
                -e MYSQL_USER=perkon \
                -e MYSQL_PASSWORD=perkon \
                -e MYSQL_DATABASE=perkons_db \
                -e MYSQL_ROOT_PASSWORD=root \
                -d \
                mysql:latest
 
This command will claim and run as a daemon a MySQL database server with a given user, database and superuser.
As alternative you can use the bash script named *start-mysqlserver.bash* located in the *.../src/main/bash* directory.

#### Start Application

You can start the application by using the following command:

    docker run --name perk0nswebapp \
               --link perkonsmysql:mysql \
               -d \
               -p 8080:8080 \
               perk0ns-web

This command will start the application (as a daemon) and link it to the mysql container previous started ( *--link perkonsmysql:mysql* ). 

Use your favorite browser on *localhost:8080* and you will be able to see the penultimate strophe from the [William Blake, The tiger](http://www.bartleby.com/101/489.html).
Each verse is stored as a entry in the database, you can add or remove them as you wish.

As alternative you can use the bash script named *start-myapp.bash* located in the *.../src/main/bash* directory.

Scripts
-------

The directory *.../src/main/bash* contains a set of useful scripts:
 
* connet-to-mysql.bash - it connects to the MySQL running docker image.
* connet-to-mywebapp.bash - it connects to the docker image that run the webapp.
* purge-all-containers.bash - will stop and remove all the running docker containers.
* show-logs-myapp.bash - display the standard output for the docker image that run the webapp.
* show-logs-mysql.bash - display the standard output for the docker image that run the MySQL.
* start-myapp.bash - starts the docker container with the webapp, it requires a running MySQL.
* start-mysql.bash - starts the docker container with the MySQL.

If you start the container with the upper described scripts you will associate them with a name, the name is unique,
so you can not run the scripts twice. In order to re-run the scripts you need to purge the containers ( *purge-all-containers.bash* )
 
