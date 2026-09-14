#!/bin/bash

# Define the image name
IMAGE_NAME="devfelixh/opencode-v1:latest"

# Build the Docker image
docker build -t $IMAGE_NAME -f Dockerfile.opencode .

# Verify the image was created successfully
docker images | grep $IMAGE_NAME

## docker push $IMAGE_NAME