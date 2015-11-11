#!/usr/bin/env bash

# convert task config parameters to shell config
CONFIG_ID=$(date +"%s")
CONFIG_FILE_NAME="kvm/${CONFIG_ID}.shell"

set -e
python optconv.py $1 ${CONFIG_FILE_NAME}

# execute task with config
sudo /bin/bash ./kvm/centos.qm.sh ${CONFIG_FILE_NAME}

rm -f ${CONFIG_FILE_NAME}
set +e
