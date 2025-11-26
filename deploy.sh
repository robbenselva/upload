#!/bin/bash
set -e
IMAGE=$1

export IMAGE=$IMAGE
docker-compose pull
docker-compose up -d