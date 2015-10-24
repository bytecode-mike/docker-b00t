#!/bin/bash
#set -xv
docker inspect -f '{{ .NetworkSettings.IPAddress }}' sys_db
