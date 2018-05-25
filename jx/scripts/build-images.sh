#!/usr/bin/env bash
set -e
set -u 

declare -A images

if [ "$VERSION" = "" ]
then
  echo "No VERSION env var so assuming a snapshot!"
  VERSION="SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
fi

if [ "$PUSH_LATEST" = "" ]
then
  echo "No PUSH_LATEST env var !"
  PUSH_LATEST="false"
fi

echo "Building images with version ${VERSION}"


PHP_IMAGE="php:7.2.5"
RUBY_IMAGE="ruby:2.5.1"
SWIFT_IMAGE="swift:4.0.3"

images=( ["ruby"]=$RUBY_IMAGE ["swift"]=$SWIFT_IMAGE )

# TODO
#images=( ["php"]=$PHP_IMAGE  )

echo "FROM centos:7" > Dockerfile
echo "" >> Dockerfile
cat Dockerfile.yum >> Dockerfile
cat Dockerfile.common >> Dockerfile

docker build --no-cache -t docker.io/jenkinsxio/builder-base:${VERSION} -f Dockerfile .

for name in "${!images[@]}"
do
echo "pack $name uses image: ${images[$name]}"

# generate a docker image
echo "FROM ${images[$name]}" > Dockerfile.$name
echo "" >> Dockerfile.$name
cat Dockerfile.apt >> Dockerfile.$name
cat Dockerfile.common >> Dockerfile.$name

docker build -t docker.io/jenkinsxio/builder-$name:${VERSION} -f Dockerfile.$name .

if [ "$PUSH" = "true" ]; then
  echo "Pushing the docker image"
  docker push docker.io/jenkinsxio/builder-$name:${VERSION}

  if [ "$PUSH_LATEST" = "true" ]; then
    docker tag docker.io/jenkinsxio/builder-$name:${VERSION} docker.io/jenkinsxio/builder-$name:latest
    docker push docker.io/jenkinsxio/builder-$name:latest
  else
    echo "Not pushing the latest docker image as PUSH_LATEST=$PUSH_LATEST"
  fi
else
  echo "Not pushing the docker image as PUSH=$PUSH"
fi
done
