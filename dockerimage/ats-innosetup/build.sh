#!/bin/sh
#

DOCKERIMAGE=jotools/ats-innosetup
VERSION=$1

if [ -z "$VERSION" ]; then
	echo "ERROR: \$VERSION is empty."
	exit 1
fi

docker build --no-cache --platform=linux/amd64 -t ${DOCKERIMAGE}:${VERSION}-amd64 .
docker build --no-cache --platform=linux/arm64 -t ${DOCKERIMAGE}:${VERSION}-arm64 .

sleep 5

docker push ${DOCKERIMAGE}:${VERSION}-amd64
docker push ${DOCKERIMAGE}:${VERSION}-arm64

sleep 5

docker manifest create ${DOCKERIMAGE}:${VERSION} --amend ${DOCKERIMAGE}:${VERSION}-amd64 --amend ${DOCKERIMAGE}:${VERSION}-arm64
sleep 5
docker manifest push ${DOCKERIMAGE}:${VERSION}

sleep 5

docker buildx imagetools create -t ${DOCKERIMAGE} ${DOCKERIMAGE}:${VERSION}
