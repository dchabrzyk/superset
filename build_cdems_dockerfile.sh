#!/bin/bash

docker buildx build --build-arg BUILD_TRANSLATIONS=true --tag masta.azurecr.io/superset:6.0.0rc3-masta-1 --platform=linux/amd64 --push -f ./CDEMS.Dockerfile .
