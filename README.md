# docker-b00t

This projects puts together a simple SpringBoot / AngularJS application and it publish it as Docker image.
This is not a Spring Boot or Angular JS tutorial, the focus is on the Docker and on the possible way to use it (together with  a SpringBoot/ AngularJS/MySQL database).  

# Prerequisite

Fist of all you need to install the Docker container, this is depending on the underling operation system,
for mode detail about installation consider the [Docker](http://docs.docker.com/mac/started/) site.
The interaction with Docker can be done over a command line or if you prefer you can use the [Chrome Docker](https://chrome.google.com/webstore/detail/simple-docker-ui-beta/jfaelnolkgonnjdlkfokjadedkacbnib?hl=de) extension.

# Fast forward

If you are one of those fast (and I hope less furious) developers any your interests are only the running code here is what you need to do:

## Gradle

    gradle buildDocker
    
    docker run --name perkonsmysql \
               -e MYSQL_USER=perkon \
               -e MYSQL_PASSWORD=perkon \
               -e MYSQL_DATABASE=perkons_db \
               -e MYSQL_ROOT_PASSWORD=root \
               -d \
               -p 3306:3306 \
               mysql:latest
    
    docker run --name perk0ns \
               --link perkonsmysql:localhost \
               -d \
               -p 80:8080 \
               localhost:5000/perk0ns:1.0
 or

    docker run --name perkonsmysql \
               -e MYSQL_USER=perkon \
               -e MYSQL_PASSWORD=perkon \
               -e MYSQL_DATABASE=perkons_db \
               -e MYSQL_ROOT_PASSWORD=root \
               -d \
               -p 3306:3306 \
               mysql:latest

    gradle clean startDocker
 
## Maven

    mvn package docker:build
    
    docker run --name perkonsmysql \
               -e MYSQL_USER=perkon \
               -e MYSQL_PASSWORD=perkon \
               -e MYSQL_DATABASE=perkons_db \
               -e MYSQL_ROOT_PASSWORD=root \
               -d \
               -p 3306:3306 \
               mysql:latest
    
    docker run --name perk0ns \
               --link perkonsmysql:localhost \
               -d \
               -p 80:8080 \
               localhost:5000/perk0ns:1.0

# How the things really working ?

The application is simple; a spring JpaRepository exposes its CRULD functionality over a REST controller, an AngularJS based user interface provides user interaction; but this is nothing new, this is the state of the art.
The element of new is introduced with the Docker, each part (the application and the database) runs in isolated in Docker containers, the containers can communicate with each other. This is a primitive form of [PaaS](https://en.wikipedia.org/wiki/Platform_as_a_service).    
The proposed workflow is simple: the developer(s) create code; the code is packed in to a __application__, the application is encapsulated in to a __Docker image__ (together with all the required resources); the Docker image gets __tag__ and after this it is __pushed__ in to a docker registry. 
This project uses a local docker registry, more details in the sections below.

## Build and publish the Docker image

The project provides both Gradle and Maven support.

### Publish the Docker image with Gradle

The Gradle Docker support is provided with the [bmuschko / gradle-docker-plugin](https://github.com/bmuschko/gradle-docker-plugin).
If you use windows (or you use any boot2docker like environment) you need to call all the gradle commands from the
_docker terminal_.  

#### Reasons for bmuschko gradle-docker-plugin

Even if  the [spring boot docker tutorial](https://spring.io/guides/gs/spring-boot-docker/) uses the [Transmode/gradle-docker](https://github.com/Transmode/gradle-docker) I prefer to use the bmuschko gradle plugin because the _Transmode_ plugin encounters
some problems with the boot2Docker distributions. It seams that under Windows the docker build process generates a lot of output to standard out or/and standard err, then it will eventually fill a buffer of the executing process and the process will block indefinitely while trying to write to the stream. This is a know bug and it is documented [here](https://github.com/Transmode/gradle-docker/issues/37).

#### About the Gradle tasks

Following tasks are available:

* _buildDocker_ - it builds a docker image based on the current project state.
* _tagDocker_ - it builds a docker image based on the current project state and tag it. The tag information are obtained from the underlying (gradle) project. 
* _pushDocker_ - it builds a docker image, tag it and push it in to a Docker repository. A Docker Repository is required, consider this [article](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-14-04) for more details.
* _createDocker_ - it creates a docker container based on the (Docker) image originated from the above defined tasks. This task only __creates__ the Docker container __it does not run (start) it__.
* _startDocker_ - it creates and runs a docker container based on a given (Docker) image. 
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
* the _prepareDockerResources_ task copies all the required resources (for the Docker image) in the proper location. The Docker images can contain only files located under a certain directory; this directory is named context, only files and directories in the context can be added during (the image) build. For more information about the Docker context consider the [understanding context in Docker file](http://kimh.github.io/blog/en/docker/gotchas-in-writing-dockerfile-en/#add_and_understanding_context_in_dockerfile)  article.
* the new created image is tagged with a tag with the following syntax 'REPOSITORY/PROJECT:VERSION'. The tag syntax corresponds the [Docker needs](). The REPOSITORY is the URL for the docker repository where the image will be published, at this stage the image is still not published. 
* the image name is _"localhost:5000/perk0ns"_ with the tag _"1.0"_,  this information originates from gradle project. Consult [this article](https://docs.docker.com/userguide/dockerimages/) for more details related to the docker image name and tag.

This task __does not push (publish)__ the Docker image, it only creates it and make it available for the local docker container.

If the task run properly you must be able to see the docker new image by using the _docker images_ command, the result must be similar with the following output.

    gradlew buildDocker
    
    docker images

    REPOSITORY               TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    localhost:5000/perk0ns   1.0                 9e8cfe28fe93        37 hours ago        868.7 MB
    python                   latest              575cb3ad9b67        3 weeks ago         685.7 MB
    registry                 2                   2f1ef7702586        7 weeks ago         220.6 MB
    mysql                    latest              c45e4ba02f47        7 weeks ago         283.8 MB
    java                     8                   49ebfec495e1        11 weeks ago        816.4 MB


The _buildDocker_ only builds the _localhost:5000/perk0ns_ image. The rest of the images are just images that exist only on my local machine.

##### _tagDocker_ task

    task tagDocker(type: DockerTagImage) {
        dependsOn buildDocker
        force = true
        imageId = buildDocker.getTag()
        repository = repName
        tag = "latest"
    }

It builds and tags with the tag _latest_ a Docker image based on the underlying project. This task is similar with the _buildDocker_ task above defined, the only difference is that the tag name is in this case _latest_. 
If this task runs you will be able to see two different tags for your image (same image id but different tags), a _1.0_ (the actual project version) and a _latest_ tag. The _latest_ tag is a Docker convention, it is assigned to the image that corresponds to the latest project (image) version. The _latest_ tag is a Docker convention, if you try to run/pull an image without to specify the version information then the image tagged with _latest_ will be chosen. 

##### _pushDocker_ task

    task pushDocker(type: DockerPushImage ) {
        dependsOn tagDocker
        imageName = repName
        tag = project.version
    }

It builds, tags  with _latest_ and push the new created image into docker hub registry that runs local. This task __requires a docker hub repository__; for test purposes you can use the default file system based docker registry named _registry_ :). To run it you need the following command:

    docker run -d -p 5000:5000 --restart=always --name registry registry:2

or run the _start-local-registry.bash_ script located in the _.../src/main/bash_ directory. Please notice that this (docker) repository has only didactic purposes and it __does not provide the docker search__ function; the consequence, you can not the command _docker search localhost:5000/p_ against this repository.
If this task run properly you can pull now the new created image from the registry. In order to to this use the following command:

    docker pull localhost:5000/perk0ns:1.0
 
Eventually you need to remove the previous image, if this is still available on your local machine. In order to to this use the following command:
 
    docker rmi -f localhost:5000/perk0ns:1.0
    
You can browse the file based repository by using the the following command:

    docker run -d -p 5000:5000 --restart=always --name registry registry:2 

or run the _connect-to-local-registry.bash_ script located in the _.../src/main/bash_ directory. If this script runs properly you will be log in the _docker container_ that host the docker repository. Go on _/var/lib/registry/docker/registry/v2/repositories_ and you will be able to see your image, or at least the way how docker store it.

##### _createDocker_ task

    task createDocker(type: DockerCreateContainer) {
        dependsOn buildDocker
        imageId = buildDocker.getTag()
        links = ['perkonsmysql:localhost']
        exposedPorts =["tcp":8080]
        portBindings = '80:8080'
        containerName = "$project.name-$project.version"
    }

This task builds, tags and creates a Docker container based on the underlying project. At this point you need to be familiar with two docker terms: [image](https://docs.docker.com/userguide/dockerimages/) and [container](https://www.docker.com/whatisdocker); the _image_ is just a template and it does not run, when an _image_ runs it always run as a _container_.

This task __does not runs__ the docker container it only create it, in order to run it you need to consider the _startDocker_ task (below described).
This task depends on the _buildDocker_ task because it requires a valid docker image in order to to run a docker container. 

This task creates also a [docker link](https://docs.docker.com/userguide/dockerlinks/) with the container named _perkonsmysql_ under the alias _localhost_. The same value (_localhost_) is used in the jdbc driver (available in application.properties).

    spring.datasource.url=jdbc:mysql://localhost:3306/perkons_db

Under this circumstances (docker link), you __need to have a running MySQL instance__ under the name _perkonsmysql_; consult the _Start MySQL in to a Docker container_ section for mode details about the MySQL container.

Usually the docker containers are running isolated, our application is a web based application and it must be accessible so we need to create a container that expose to _8080_ port. If this (exposedPorts, portBindings) information is omitted then the container will be still running but no it will be not accessible.

If the task run properly you must be able to see the new docker container by using the _docker ps -a_ command, the result must be similar with the following output.

    gradlew createDocker
    
    docker ps -a

    CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS              PORTS               NAMES
    d9474adb7231        dockerboot/perk0ns:1.0   "java -Djava.securit   7 seconds ago                                               perk0ns

At this moment the container is not running, it is only created.

##### _startDocker_ task

It builds, tags, creates and runs a Docker container based on the underlying project.  If the task run properly you must be able to see the new docker container by using the _docker ps -a_ command, the result must be similar with the following output.

    gradlew startDocker
    
    docker ps -a

    CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS              PORTS                    NAMES
    1cb3fe1e9ff1        dockerboot/perk0ns:1.0   "java -Djava.securit   11 seconds ago      Up 8 seconds        0.0.0.0:8080->8080/tcp   perk0ns             
    b25cd2a876dc        mysql:latest             "/entrypoint.sh mysq   3 minutes ago       Up 3 minutes        0.0.0.0:3306->3306/tcp   perkonsmysql


This is the only task that you need to run in order to get a running container.

Now use your favorite browser on *localhost:8080* and you will be able to see the penultimate strophe from the [William Blake, The tiger](http://www.bartleby.com/101/489.html).
Each verse is stored as a entry in the database, you can add or remove them as you wish.

### Publish the Docker image with Maven

If you want to create a docker image for this project (using maven) you need to run the following command:

    mvn package docker:build
    
This implies that you have [maven](https://maven.apache.org/) installed on your machine.
As in the gradle case, if you run this command for the fist time then it may take a while, this because the docker will claim the required images from the [docker hub](https://hub.docker.com/account/signup/). 

This task uses the [Transmode/gradle-docker](https://github.com/Transmode/gradle-docker) gradle plugin.

__The maven section is still under development__

#### About the POM file


The Docker file location is described with the element:

    <dockerDirectory>src/main/docker</dockerDirectory>
    
this is only the directory, the file is/must named *Dockerfile*.    


This task uses the [docker-maven-plugin/com.spotify](https://github.com/spotify/docker-maven-plugin).

##Command Line support

###Start MySQL in to a Docker container

The application requires a MySQL database, in order to start if use the following command:
    
     docker run --name perkonsmysql \
                -e MYSQL_USER=perkon \
                -e MYSQL_PASSWORD=perkon \
                -e MYSQL_DATABASE=perkons_db \
                -e MYSQL_ROOT_PASSWORD=root \
                -d \
                mysql:latest
 
This command will claim and run as a daemon a MySQL database server.

As alternative you can use the bash script named *start-mysqlserver.bash* located in the *.../src/main/bash* directory.
The actual application requires a database so you __must__ to start the MySQL database.  

####The Database content

The database content is added via via [flyway](http://flywaydb.org/). The configuration is located in *.../resources/db/migration/V1_init.sql*.
I chose to use flyway because for is the default data migation solution for spring boot based applications.  

##Java OPTS

As of the most java application this docker container can be customized with the __JAVA_OPTS__ environment variable.
All the spring boot configuration (provided with the _application.properties_) can be overridden in this way. By example
if you wont to specify an other _URL_ for the database you need to use something like this:

    docker run --name perk0ns \
               -e JAVA_OPTS="-Dspring.datasource.url=jdbc:mysql://localhost:3306/perkons_db" \
               -d \
               -p 80:8080 \
               localhost:5000/perk0ns:1.0

### Start Application

Before you can run the application you need :
* to have a running MySQL docker container__ under the name _perkonsmysql; consult the _Start MySQL in to a Docker container_ section for mode details about the MySQL container.
* to have a docker image (for this application) on the local machine under the name _localhost:5000/perk0ns_ with the tag _1.0_. Consult the section above for more details.  

You can start the application (run the docker image in to a container) by using the following command:

    docker run --name perk0ns \
               --link perkonsmysql:localhost \
               -d \
               -p 80:8080 \
               localhost:5000/perk0ns:1.0

This command will start the application (as a daemon) and [link](https://docs.docker.com/userguide/dockerlinks/) it to other docker container named _perkonsmysql_ under the alias *localhost*.

Now use your favorite browser on *localhost:8080* and you will be able to see the penultimate strophe from the [William Blake, The tiger](http://www.bartleby.com/101/489.html).
Each verse is stored as a entry in the database, you can add or remove them as you wish.

As alternative to the command line you can use the bash script named *start-myapp.bash* located in the *.../src/main/bash* directory.

#### Start the application and database at once / docker-compose

Until now the we start the application and the database separately. This is not always wished, sometime is required start
everything at once with a single command, you can do this by using the [docker-compose](https://docs.docker.com/compose/) command with the docker-compose.yml file as in the next example.
 
    docker-compose -f src/docker/docker-compose.yml up

The above mentioned command must be call in the project root. A script that does something similar is available in the _.../bash_ directory under the name _start-all-docker-compose.bash_

#### Start the application and database at once / docker-compose

Until now the we start the application and the database separately. This is not always wished, sometime is required start
everything at once with a single command, you can do this by using the [docker-compose](https://docs.docker.com/compose/) command with the docker-compose.yml file as in the next example.
 
    docker-compose -f src/docker/docker-compose.yml up

The above mentioned command must be call in the project root. A script that does something similar is available in the _.../bash_ directory under the name _start-all-docker-compose.bash_

### NodeJS and Bower

The front-end uses [Node.js](https://nodejs.org) and [bower](http://bower.io/) to claim the java-script related resources. 
The javascript resources required in the user interface are declared in the _bower.json_ file.
This resources are claimed from the remote repositories and stored in the directory .../static/bower_components, the bower is instructed to do this with the file .bower.json. You can use  "bower update" command if you want to update the javascript dependencies.
The the directory .../static/bower_components contains already all the requires resources, so the "bower update" command is optional.

# Scripts

The directory *.../src/main/bash* contains a set of useful scripts:

* connet-to-local-repository.bash - it connect to the file-based docker registry. Use it to inspect the way how the docker images get stored in a repository. The image is located on _/var/lib/registry/docker/registry/v2/repositories_.  
* connet-to-mysql.bash - it connects to the MySQL running docker container. Use it to login in to the MySQl container, you can use the [mysql cli](https://dev.mysql.com/doc/refman/5.5/en/mysql.html) to inspect the database content.
* connet-to-mywebapp.bash - it connects to the docker image that run the webapp.
* purge-all-containers.bash - will stop and remove all the running docker containers.
* show-logs-myapp.bash - display the standard output for the docker image that run the webapp.
* show-logs-mysql.bash - display the standard output for the docker image that run the MySQL.
* start-myapp.bash - starts the docker container with the webapp, it requires a running MySQL.
* start-mysql.bash - starts the docker container with the MySQL.

If you start the container with the upper described scripts you will associate them with a name, the name is unique, so you can not run the scripts twice. In order to re-run the scripts you need to purge the containers (_purge-all-containers.bash_)
