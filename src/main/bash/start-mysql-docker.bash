#!/bin/bash
#set -xv

docker run --name perkonsmysql \
           -e MYSQL_USER=perkon \
           -e MYSQL_PASSWORD=perkon \
           -e MYSQL_DATABASE=perkons_db \
           -e MYSQL_ROOT_PASSWORD=root \
           -d \
           mysql:latest


