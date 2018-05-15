#!/usr/bin/env bash
set -e
set -u 

declare -A images

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


for name in "${!images[@]}"
do
echo "pack $name uses image: ${images[$name]}"

# generate a docker image
echo "FROM ${images[$name]}" > Dockerfile.$name
echo "" >> Dockerfile.$name
cat Dockerfile.apt >> Dockerfile.$name
cat Dockerfile.common >> Dockerfile.$name

docker build -t docker.io/jenkinsxio/builder-$name:${VERSION} -f Dockerfile.$name .

if [ "$PUSH" = "true" ]
then
  echo "Pushing the docker image"
  docker tagdocker.io/jenkinsxio/builder-$name:${VERSION} docker.io/jenkinsxio/builder-$name:latest

  docker push docker.io/jenkinsxio/builder-$name:${VERSION}
  docker push docker.io/jenkinsxio/builder-$name:latest
else
  echo "Not pushing the docker image as PUSH=$PUSH"
fi
done
