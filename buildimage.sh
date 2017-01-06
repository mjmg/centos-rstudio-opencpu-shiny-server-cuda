#!/bin/sh

NV_DOCKER='sudo docker -D' sudo nvidia-docker build -t mjmg/centos-rstudio-opencpu-shiny-server-cuda .
#sudo docker -t `curl -s http://localhost:3476/docker/cli` build mjmg/centos-opencpu-server-cuda .

#sudo docker build -t  `curl -s http://localhost:3476/docker/cli` mjmg/centos-opencpu-server-cuda .