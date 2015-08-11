#!/bin/bash
#set -xv

docker run --name perk0nswebapp \
           --link perkonsmysql:localhost \
           -d \
           -p 8080:8080 \
           dockerboot/perk0ns:1.0
