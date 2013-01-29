#!/bin/sh

# params : share_id guest_path user

USER_ID=`id -u $3`
mount | grep $1 | grep -v uid=$USER_ID
if [ $? -eq 0 ]
  then
  echo "remounting $2 as $3"
  umount $1 && mount -t vboxsf -o uid=$USER_ID,gid=`id -g $3` $1 $2
fi
