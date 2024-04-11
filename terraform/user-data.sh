#!/bin/bash
sudo service docker start
sudo chkconfig docker on
sudo usermod -a -G docker ec2-user
newgrp docker

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 046354001990.dkr.ecr.eu-central-1.amazonaws.com

docker pull 046354001990.dkr.ecr.eu-central-1.amazonaws.com/webui:latest

docker run -p 80:80 -d 046354001990.dkr.ecr.eu-central-1.amazonaws.com/webui:latest