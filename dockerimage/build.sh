#!/bin/sh
#

DOCKERIMAGE=jotools/ats-codesign
VERSION=$1

if [ -z "$VERSION" ]; then
	echo "ERROR: \$VERSION is empty."
	exit 1
fi

docker build --no-cache --platform=linux/amd64    --build-arg ARCH=amd64   -t ${DOCKERIMAGE}:${VERSION}-amd64 .
docker build --no-cache --platform=linux/arm64/v8 --build-arg ARCH=arm64v8 -t ${DOCKERIMAGE}:${VERSION}-arm64v8 .

docker push ${DOCKERIMAGE}:${VERSION}-amd64
docker push ${DOCKERIMAGE}:${VERSION}-arm64v8

docker manifest create ${DOCKERIMAGE}:${VERSION} --amend ${DOCKERIMAGE}:${VERSION}-amd64 --amend ${DOCKERIMAGE}:${VERSION}-arm64v8
docker manifest push ${DOCKERIMAGE}:${VERSION}

docker buildx imagetools create -t ${DOCKERIMAGE} ${DOCKERIMAGE}:${VERSION}
