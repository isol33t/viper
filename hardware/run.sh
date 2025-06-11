#!/bin/sh

if [ -z "$CIRCLE_SHA1" ]; then
  KBPLACER_REVISION=master
else
  KBPLACER_REVISION=$CIRCLE_SHA1
fi
docker build --build-arg="KBPLACER_REVISION=$KBPLACER_REVISION" -t viper-10u .
docker cp $(docker create --name viper-10u viper-10u:latest /bin/sh):/viper-10u.zip "viper-10u-$(date '+%Y-%m-%d_%H-%M-%S').zip"
docker rm viper-10u
