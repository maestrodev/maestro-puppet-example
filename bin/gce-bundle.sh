#!/bin/sh

# Sample script to package a running GCE instance with maestro or agent and upload to storage as an image

IMAGE_NAME=$1
PROJECT=$2
TOKEN=$3

if /bin/ls -1 /usr/local/src/maestro-*.rpm &> /dev/null; then
  RPM=`/bin/ls -1 /usr/local/src/maestro-*.rpm`
else
  RPM=`/bin/ls -1 /usr/local/src/agent-*.rpm`
fi
echo RPM=$RPM

sudo gcimagebundle -d /dev/sda -o /tmp/ --log_file=/tmp/abc.log

IMAGE_NAME=$IMAGE_NAME-`echo $RPM | head -n 1 | sed -e 's/.*-\(.*\)\.rpm/\1/' | sed -e 's/\./-/g'`-`date +"%Y%m%d%H%M"`
echo IMAGE_NAME=$IMAGE_NAME
IMAGE_TAR=`/bin/ls -1 /tmp/*.image.tar.gz | sed -e 's/\/tmp\/\(.*\).image.tar.gz/\1/'`
echo IMAGE_TAR=$IMAGE_TAR

# gsutil credentials
cat << EOF > ~/.boto
[Credentials]
gs_oauth2_refresh_token = $TOKEN

[Boto]
https_validate_certificates = True

[GSUtil]
content_language = en
default_api_version = 2
default_project_id = $PROJECT

[OAuth2]
EOF

gsutil cp /tmp/$IMAGE_TAR.image.tar.gz gs://maestrodev-images/$IMAGE_NAME.image.tar.gz
