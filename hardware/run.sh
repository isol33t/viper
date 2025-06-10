#!/bin/sh

if [ -z "$CIRCLE_SHA1" ]; then
  KBPLACER_REVISION=master
else
  KBPLACER_REVISION=$CIRCLE_SHA1
fi
docker build --build-arg="KBPLACER_REVISION=$KBPLACER_REVISION" -t viper-split-hhkb .
docker cp $(docker create --name viper-split-hhkb viper-split-hhkb:latest /bin/sh):/viper-split-hhkb.zip .
docker rm viper-split-hhkb
