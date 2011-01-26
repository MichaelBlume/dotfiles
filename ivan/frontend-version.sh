#!/bin/bash

FRONTENDS="frontend1.prod.loggly.net frontend2.prod.loggly.net frontend1.hoover.loggly.net"
SSH_OPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

echo 
for FRONT in $FRONTENDS
do
    echo "================ $FRONT ================"
    ssh -q $SSH_OPTS $FRONT '/usr/bin/dpkg -l | grep loggly'
    echo
    echo
done
