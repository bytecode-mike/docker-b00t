#!/bin/bash
#set -xv

docker run --name systoto \
           --link sys_db:localhost \
           -d \
           -p 80:8080 \
           localhost:5000/systodo:latest
