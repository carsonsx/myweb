#!/usr/bin/env bash

#
# This script is meant for quick & easy build and push myweb image via:
#   'curl -sSL https://raw.githubusercontent.com/carsonsx/myweb/master/docker/build.sh | sh'
# or:
#   'wget -qO- https://raw.githubusercontent.com/carsonsx/myweb/master/docker/build.sh | sh'
#

set -x
set -o pipefail

PROJECT_NAME=myweb

# Download Dockerfile
rm -f Dockerfile
curl -sSLO "https://raw.githubusercontent.com/carsonsx/${PROJECT_NAME}/master/docker/Dockerfile"

# Stop and remove image if exists
docker rm -f ${PROJECT_NAME}

mv -f ${PROJECT_NAME}_linux_amd64 ${PROJECT_NAME}

set -e

#VERSION="$(git describe --tags --always)"
VERSION=0.1

# Build image
docker build -t carsonsx/${PROJECT_NAME} .
docker tag carsonsx/${PROJECT_NAME} carsonsx/${PROJECT_NAME}:${VERSION}

# Push image
# Please run docker login first
docker push carsonsx/${PROJECT_NAME}
docker push carsonsx/${PROJECT_NAME}:${VERSION}

# Clean
docker rmi carsonsx/${PROJECT_NAME}
docker rmi carsonsx/${PROJECT_NAME}:${VERSION}
rm -f Dockerfile ${PROJECT_NAME}