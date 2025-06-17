#!/bin/bash

docker buildx build --tag masta.azurecr.io/superset:5.0.0-rc3-masta-2 --platform=linux/amd64 --push -f ./CDEMS.Dockerfile .
