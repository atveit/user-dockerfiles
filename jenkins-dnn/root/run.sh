#!/bin/bash

nvidia-docker run -P --name jenkins-dnn -v /data/docker:/root/shared -d -it jenkins-dnn