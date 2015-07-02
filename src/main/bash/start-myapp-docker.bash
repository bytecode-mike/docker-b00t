#!/bin/bash
#set -xv

docker run --name perk0nswebapp --link perkonsmysql:mysql -d -p 8080:8080 perk0ns-web
 

#docker run -p 8080:8080 --name demo-app --link demo-mysql:mysql -d jiwhiz/spring-boot-docker-mysql
