#!/bin/bash

docker buildx build --tag masta.azurecr.io/superset:4.1.1-masta-1 --platform=linux/amd64 --push -f ./CDEMS.Dockerfile .
