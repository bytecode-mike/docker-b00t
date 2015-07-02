#!/bin/bash
#set -xv

docker stop $(docker ps -qa)
docker rm $(docker ps -qa)

