#!/usr/bin/env bash

# convert task config parameters to shell config
CONFIG_ID=$(date +"%s")
CONFIG_FILE_NAME="kvm/${CONFIG_ID}.shell"

set -e
python optconv.py $1 ${CONFIG_FILE_NAME}

. "${CONFIG_FILE_NAME}"

PROCESSED_CONFIG=kvm/create_vps_qm/${VMID}.create.$(date +"%s").shell

echo "Process config ${CONFIG_FILE_NAME} -> ${PROCESSED_CONFIG}"
if [[ ! -e kvm/create_vps_qm ]]; then
    mkdir -p kvm/create_vps_qm
fi

mv ${CONFIG_FILE_NAME} ${PROCESSED_CONFIG}

# execute task with config
sudo /bin/bash ./kvm/centos.qm.sh ${PROCESSED_CONFIG}

set +e

exit 0
