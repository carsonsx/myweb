#!/usr/bin/env bash

PROJECT_NAME=myweb

# Get the git commit
GIT_COMMIT="$(git rev-parse --short HEAD)"
GIT_DIRTY="$(test -n "`git status --porcelain`" && echo "+CHANGES" || true)"
GIT_DESCRIBE="$(git describe --tags --always)"

echo "git commit: ${GIT_COMMIT}"
echo "git dirty: ${GIT_DIRTY}"
echo "git describe: ${GIT_DESCRIBE}"

CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -a -ldflags "-s -w" -o bin/${PROJECT_NAME}_darwin_amd64
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags "-s -w" -o bin/${PROJECT_NAME}_linux_amd64