#!/bin/sh

if [ -z "$CIRCLE_SHA1" ]; then
  KBPLACER_REVISION=master
else
  KBPLACER_REVISION=$CIRCLE_SHA1
fi
docker build --build-arg="KBPLACER_REVISION=$KBPLACER_REVISION" -t viper .
docker cp $(docker create --name viper viper:latest /bin/sh):/viper.zip .
docker rm viper
