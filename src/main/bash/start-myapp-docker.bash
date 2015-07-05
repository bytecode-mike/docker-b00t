#!/bin/bash
#set -xv

docker run --name perk0nswebapp \
           --link perkonsmysql:localhost \
           -d \
           -p 8080:8080 \
           perk0ns-web
