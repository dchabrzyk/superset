#!/bin/bash

# Build Superset with translations enabled
# BUILD_TRANSLATIONS is already set to "true" in CDEMS.Dockerfile
docker buildx build \
  --tag masta.azurecr.io/superset:6.1.0-masta-1 \
  --platform=linux/amd64 \
  --push \
  -f ./CDEMS.Dockerfile \
  .
