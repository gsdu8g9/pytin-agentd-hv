#!/usr/bin/env bash

# Shell command proxy. Used to call specialized scripts.
#
# Parameters are passed to this scripts via JSON file $1. Then this file is parsed
# and all parameters are passed to the shell.
#
# Output data is passes as key=value strings to the stdout after the ":RETURN:" placeholder.

# convert task config parameters to shell config
CONFIG_ID=$(date +"%s")
TMP_CONFIG_FILE_NAME="runtime/${CONFIG_ID}.shell"

set -e
python optconv.py $1 ${TMP_CONFIG_FILE_NAME}

. "${TMP_CONFIG_FILE_NAME}"

if [[ -z ${SUBCOMMAND} ]]; then
    echo "Missing SUBCOMMAND"
    exit 101
fi

ARCHIVED_CONFIG=runtime/vps_cmd_proxy/${VMID}.${SUBCOMMAND}.$(date +"%s").shell

echo "Process config ${TMP_CONFIG_FILE_NAME} -> ${ARCHIVED_CONFIG}"
if [[ ! -e runtime/vps_cmd_proxy ]]; then
    mkdir -p runtime/vps_cmd_proxy
fi

mv ${TMP_CONFIG_FILE_NAME} ${ARCHIVED_CONFIG}

echo "Restarting Flask for local PXE"
flask_pid=$(ps x | grep webrepo | grep -v grep | head -n 1 | cut -d' ' -f 1)
if [ ! -z ${flask_pid} ]; then
    kill -KILL ${flask_pid}
fi
python ../../bootrepo/webrepo.py &

# execute task with config
echo "Running subcommand: ${SUBCOMMAND}"

if [ -z ${DEBUG} ]; then
    sudo /bin/bash ./vps/${SUBCOMMAND}.sh ${ARCHIVED_CONFIG}
else
    /bin/bash ./vps/${SUBCOMMAND}.sh ${ARCHIVED_CONFIG}
fi

flask_pid=$(ps x | grep webrepo | grep -v grep | head -n 1 | cut -d' ' -f 1)
if [ ! -z ${flask_pid} ]; then
    echo "Killing Flask"
    kill -KILL ${flask_pid}
fi
set +e

exit 0
