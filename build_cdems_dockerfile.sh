#!/bin/bash

docker buildx build --tag masta.azurecr.io/superset:superset:6.0.0rc3-masta-1 --platform=linux/amd64 --push -f ./CDEMS.Dockerfile .
