#!/usr/bin/env bash

#
# This script is meant for quick & easy run latest image via:
#   'curl -sSL https://raw.githubusercontent.com/carsonsx/myweb/master/docker/run.sh | sh'
# or:
#   'wget -qO- https://raw.githubusercontent.com/carsonsx/myweb/master/docker/run.sh | sh'
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

docker rmi carsonsx/${PROJECT_NAME}

set -e

# Build image
docker build -t carsonsx/${PROJECT_NAME} .

# Run
docker run -itd --name ${PROJECT_NAME} -p 8012:8012 carsonsx/${PROJECT_NAME}
docker logs -f ${PROJECT_NAME}