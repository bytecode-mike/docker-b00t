#!/bin/bash
#set -xv

#This scripts start the database and the application container with at once.
# You need docker-compose for this.

docker-compose -f ././../docker/docker-compose.yml up
