#!/bin/bash
#set -xv

docker run --name sys_db \
           -e MYSQL_USER=sisyphus \
           -e MYSQL_PASSWORD=sisyphus \
           -e MYSQL_DATABASE=sys_db \
           -e MYSQL_ROOT_PASSWORD=root \
           -d \
           -p 3306:3306 \
           mysql:latest


