# docker-b00t

This projects puts together a simple SpringBoot / AngularJS application and it publish it as Docker image.

# Prerequisite


Fist of all you need to install the Docker container, this is depending on the underling operation system,
for mode detail about installation consider the [Docker](http://docs.docker.com/mac/started/) site.
The interaction with Docker can be done over a command line or if you prefer you can use the [Chrome Docker](https://chrome.google.com/webstore/detail/simple-docker-ui-beta/jfaelnolkgonnjdlkfokjadedkacbnib?hl=de) extension.

# Fast forward

If you are one of those fast (and I hope less furious) developers any your interests are only the running code here is what you need to do:

## Gradle

    gradle buildDocker
    
    docker run --name perkonsmysql -e MYSQL_USER=perkon -e MYSQL_PASSWORD=perkon -e MYSQL_DATABASE=perkons_db -e MYSQL_ROOT_PASSWORD=root -d mysql:latest
    
    docker run --name perkonsmysql -e MYSQL_USER=perkon -e MYSQL_PASSWORD=perkon -e MYSQL_DATABASE=perkons_db -e MYSQL_ROOT_PASSWORD=root -d mysql:latest
 
 
## Maven

    mvn package docker:build
    
    docker run --name perkonsmysql -e MYSQL_USER=perkon -e MYSQL_PASSWORD=perkon -e MYSQL_DATABASE=perkons_db -e MYSQL_ROOT_PASSWORD=root -d mysql:latest
    
    docker run --name perkonsmysql -e MYSQL_USER=perkon -e MYSQL_PASSWORD=perkon -e MYSQL_DATABASE=perkons_db -e MYSQL_ROOT_PASSWORD=root -d mysql:latest
intract

# How the things really working

The application is simple, a spring JpaRepository exposes its CRULD functionality over a REST controller, an AngularJS based user interface provides user interaction; but this is nothing new, this is the state of the art.
The element of new is introduced with the Docker, each part (the application and the database) runs in isolated in Docker containers, the containers can communicate with each other. This is a primitive form of [PaaS](https://en.wikipedia.org/wiki/Platform_as_a_service).    

## Build and publish the Docker image

The project provides both Gradle and Maven support.

### Publish the Docker image with Gradle

The Gradle Docker support is provided with the [bmuschko / gradle-docker-plugin](https://github.com/bmuschko/gradle-docker-plugin).

#### Reasons for bmuschko gradle-docker-plugin

Even if  the [spring boot docker tutorial](https://spring.io/guides/gs/spring-boot-docker/) uses the [Transmode/gradle-docker](https://github.com/Transmode/gradle-docker) I prefer to use the bmuschko gradle plugin because the _Transmode_ plugin encounters
some problems with the boot2Docker distributions. It seams that under Windows the docker build process generates a lot of output to standard out or/and standard err, then it will eventually fill a buffer of the executing process and the process will block indefinitely while trying to write to the stream. This is a know bug and it is documented [here](https://github.com/Transmode/gradle-docker/issues/37).

#### About the Gradle tasks

Following tasks are available:

* _buildDocker_ - it builds a docker image based on the current project state.
* _tagDocker_ - it builds a docker image based on the current project state and tag it. The tag information are obtained from the underlying (gradle) project. 
* _pushDocker_ - it builds a docker image, tag it and push it in to a Docker repository. A Docker Repository is required, consider this [article](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-14-04) for more details.
* _createDocker_ - it creates a docker container based on the (Docker) image originated from the above defined tasks. This task only __creates__ the Docker container __it does not run (start) it__.
* _runDocker_ - it creates and runs a docker container based on a given (Docker) image. 
* _stopDocker_ - it stops a docker container.

Consults the next sections for more details related with the above listed (gradle) tasks.  

##### _buildDocker_ task

    task buildDocker(type: DockerBuildImage) {
        dependsOn build
        dependsOn prepareDockerResources
        quiet = true
        noCache = true
        inputDir = prepareDockerResources.destinationDir
        tag = "$repName:$project.version"
    }

The _buildDocker_ Gradle task does the following :

* runs the _build_ and the _prepareDockerResources_ before the Docker image is build
* the _build_ task builds the application war file, required by the docker image
* the _prepareDockerResources_ copies all the required resources (for the Docker image) in the proper location. The Docker images can contain only files located under a certain directory; this directory is named context, only files and directories in the context can be added during (the image) build. For more information about the Docker context consider the [understanding context in Docker file](http://kimh.github.io/blog/en/docker/gotchas-in-writing-dockerfile-en/#add_and_understanding_context_in_dockerfile)  article.
* the image name is _"dockerboot/perk0ns"_ with the tag _"1.0"_,  this information originates from gradle project. Consult [this article](https://docs.docker.com/userguide/dockerimages/) for more details related to the docker image name and tag.

This task __does not push (publish)__ the Docker image, it only creates it and make it available for the local docker container.

If the task run properly you must be able to see the docker new image by using the _docker images_ command, the result must be similar with the following output.

    gradlew buildDocker

    docker images

    REPOSITORY           TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    dockerboot/perk0ns   1.0                 f9ea8a2d1c4d        4 minutes ago       868.6 MB
    mysql                5.6                 d63d4723d715        7 weeks ago         283.5 MB
    java                 8                   99631e385332        8 weeks ago         816.3 MB
    ubuntu               14.04               6d4946999d4f        8 weeks ago         188.3 MB
    mysql                latest              e0db8fe06e30        9 weeks ago         283.5 MB

##### _tagDocker_ task

    task tagDocker(type: DockerTagImage) {
        dependsOn buildDocker
        force = true
        imageId = buildDocker.getTag()
        repository = repName
        tag = "$project.version"
    }

It builds and tags a Docker image based on the underlying project. This task is similar with the _buildDocker_ task upper defined.

##### _createDocker_ task

    task createDocker(type: DockerCreateContainer) {
        dependsOn buildDocker
        imageId = buildDocker.getTag()
        links = ['perkonsmysql:localhost']
        portBindings = '8080:8080'
        containerName = "$project.name"
    }

This task builds, tags and creates a Docker container based on the underlying project.
This task __does not runs__ the docker container it only create it, in order to run it you need to consider the _runDocker_ task (below described).
This task depends on the _buildDocker_ task because it requires a valid docker image in order to to run a docker container. This task creates a [docker link](https://docs.docker.com/userguide/dockerlinks/) with the container named _perkonsmysql_ under the alias _localhost_. The same value (_localhost_) is used in the jdbc driver (available in application.properties).

    spring.datasource.url=jdbc:mysql://localhost:3306/perkons_db

Under this circumstances (docker link), you __need to have a running MySQL instance__ under the name _perkonsmysql_; consult the _Start MySQL in to a Docker container_ section for mode details about the MySQL container.

If the task run properly you must be able to see the docker new image by using the _docker ps -a_ command, the result must be similar with the following output.

    docker ps -a

    CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS              PORTS               NAMES
    d9474adb7231        dockerboot/perk0ns:1.0   "java -Djava.securit   7 seconds ago                                               perk0ns

At this moment the container is not running, it is only created.

##### _runDocker_ task

It builds, tags, creates and runs a Docker container based on the underlying project.  If the task run properly you must be able to see the docker new image by using the _docker ps -a_ command, the result must be similar with the following output. 


    CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS              PORTS               NAMES     
    9a692196017a        dockerboot/perk0ns:1.0   "java -Djava.securit   11 seconds ago      Up 7 seconds                            perk0ns   
    ab34b9600622        mysql:latest             "/entrypoint.sh mysq   3 minutes ago       Up 3 minutes        3306/tcp            perkonsmys


This is the only task that you need to run in order to get a running container.

### Publish the Docker image with Maven

If you want to create a docker image for this project (using maven) you need to run the following command:

    mvn package docker:build
    
This implies that you have [maven](https://maven.apache.org/) installed on your machine.
As in the gradle case, if you run this command for the fist time then it may take a while, this because the docker will claim the required images from the [docker hub](https://hub.docker.com/account/signup/). 

This task uses the [Transmode/gradle-docker](https://github.com/Transmode/gradle-docker) gradle plugin.

#### About the POM file


The Docker file location is described with the element:

    <dockerDirectory>src/main/docker</dockerDirectory>
    
this is only the directory, the file is/must named *Dockerfile*.    


This task uses the [docker-maven-plugin/com.spotify](https://github.com/spotify/docker-maven-plugin).

### About the Docker file

TODO: finish this


### Run the image

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

REPOSITORY           TAG                 IMAGE ID            CREATED             VIRTUAL SIZE                                                                                                        
dockerboot/perk0ns   1.0                 8ee496891e94        18 seconds ago      868.6 MB                                                                                                            
mysql                5.6                 d63d4723d715        7 weeks ago         283.5 MB                                                                                                            
java                 8                   99631e385332        8 weeks ago         816.3 MB                                                                                                            
ubuntu               14.04               6d4946999d4f        8 weeks ago         188.3 MB                                                                                                            
mysql                latest              e0db8fe06e30        9 weeks ago         283.5 MB

As you can see the *perk0ns-web* is present in the fist position. The image has a unique id (927846415cb2)
and a human readable name, if the name is not provided then a new name will be generated.
You can delete any imaged with :
  
    docker rmi <image name> / <ID>

##Start MySQL in to a Docker container##

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
The actual application requires a database so you __must__ to start the MySQL database.  

###The Database content###

The database content is added via via [flyway](http://flywaydb.org/). The configuration is located in *.../resources/db/migration/V1_init.sql*.

##Command Line support##

### Start Application

You can start the application by using the following command:

    docker run --name perk0nswebapp \
               --link perkonsmysql:localhost \
               -d \
               -p 8080:8080 \
               dockerboot/perk0ns:1.0

This command will start the application (as a daemon) and link it (make it available in the docker container) under the alias *localhost*. The *localhost* is used by the JPA JDBC driver connector, configured with the *application.properties* file (located in the *.../src/resources/application.properties*), here the data-source URL is configured as follow:


    spring.datasource.url=jdbc:mysql://localhost:3306/perkons_db

note, the *localhost* in the URL, is the same as the docker alias. 

Now use your favorite browser on *localhost:8080* and you will be able to see the penultimate strophe from the [William Blake, The tiger](http://www.bartleby.com/101/489.html).
Each verse is stored as a entry in the database, you can add or remove them as you wish.

As alternative to the command line you can use the bash script named *start-myapp.bash* located in the *.../src/main/bash* directory.

# Scripts

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
 
