#!/bin/bash
set -e
IMAGE=$1
docker build -t $IMAGE .