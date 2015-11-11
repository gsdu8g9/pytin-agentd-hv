#!/usr/bin/env bash

# convert task config parameters to shell config
CONFIG_ID=$(date +"%S")
CONFIG_FILE_NAME="kvm/${CONFIG_ID}.shell"

python optconv.py $1 ${CONFIG_FILE_NAME}

# execute task with config
bash ./kvm/centos.qm.sh ${CONFIG_FILE_NAME}
