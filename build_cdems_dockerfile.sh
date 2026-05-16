#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_REPOSITORY="${IMAGE_REPOSITORY:-masta.azurecr.io/superset}"
IMAGE_TAG="${IMAGE_TAG:-6.1.0-masta-1}"
SUPERSET_VERSION="${SUPERSET_VERSION:-6.1.0}"

docker buildx build \
  --tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" \
  --platform=linux/amd64 \
  --build-arg "SUPERSET_VERSION=${SUPERSET_VERSION}" \
  --push \
  -f "${SCRIPT_DIR}/CDEMS.Dockerfile" \
  "${SCRIPT_DIR}"
