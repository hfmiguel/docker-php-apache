#!/bin/bash

# Define the image name
IMAGE_NAME="devfelixh/php-8.5-apache:latest"

# Build the Docker image
docker build -t $IMAGE_NAME -f Dockerfile.apache .

# Verify the image was created successfully
docker images | grep $IMAGE_NAME

docker push $IMAGE_NAME


# Define the image name
IMAGE_NAME="devfelixh/php-8.5-fpm:latest"

# Build the Docker image
docker build -t $IMAGE_NAME -f Dockerfile.fpm .

# Verify the image was created successfully
docker images | grep $IMAGE_NAME

docker push $IMAGE_NAME
