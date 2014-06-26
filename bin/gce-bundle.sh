#!/bin/sh

# Sample script to package a running GCE instance with maestro or agent and upload to storage as an image

IMAGE_NAME=$1

RPM=`(rpm -q maestro || rpm -q maestro-agent) | tail -n 1`
echo RPM=$RPM

sudo gcimagebundle -d /dev/sda -o /tmp/ --log_file=/tmp/abc.log

IMAGE_NAME=$IMAGE_NAME-`echo $RPM | sed -e 's/.*-\(.*\)-[0-9]\.noarch/\1/' | sed -e 's/\./-/g'`-`date +"%Y%m%d%H%M"`
echo IMAGE_NAME=$IMAGE_NAME
IMAGE_TAR=`/bin/ls -1 /tmp/*.image.tar.gz | sed -e 's/\/tmp\/\(.*\).image.tar.gz/\1/'`
echo IMAGE_TAR=$IMAGE_TAR

gsutil cp /tmp/$IMAGE_TAR.image.tar.gz gs://maestrodev-images/$IMAGE_NAME.image.tar.gz
