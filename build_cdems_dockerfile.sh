#!/bin/bash

docker build -t masta.azurecr.io/superset:6.0.0rc3-masta-1 -f ./CDEMS.Dockerfile .
