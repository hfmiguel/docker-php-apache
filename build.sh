#!/bin/bash

# Define the image name
IMAGE_NAME="devfelixh/php-8.2-apache:latest"

# Navigate to the Dockerfile directory
cd /home/felix/projetos/pessoal/docker/php-base

# Build the Docker image
docker build -t $IMAGE_NAME .

# Verify the image was created successfully
docker images | grep $IMAGE_NAME

docker push $IMAGE_NAME
