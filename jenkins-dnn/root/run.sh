#!/bin/bash

nvidia-docker run -P --name jenkins-dnn -v /data/docker:/root/shared -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 -p 50000:50000 -d -it jenkins-dnn