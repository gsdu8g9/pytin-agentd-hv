#!/usr/bin/env bash

# Shell Hook для создания VPS. Может служить для преобразования параметров и передачи управления
# специализированному скрипту.
#
# Параметры передаются в этот скрипт через файл $1, где они находятся в формате JSON.
# После этого параметры преобразуются и передаются специальным скриптам для создания VPS.
# После строки :RETURN: в stdout весь вывод скрипта возвратится с ответом для последующего парсинга.

# convert task config parameters to shell config
CONFIG_ID=$(date +"%s")
CONFIG_FILE_NAME="vps/${CONFIG_ID}.shell"

set -e
python optconv.py $1 ${CONFIG_FILE_NAME}

. "${CONFIG_FILE_NAME}"

if [[ -z ${SUBCOMMAND} ]]; then
    echo "Missing SUBCOMMAND"
    exit 101
fi

PROCESSED_CONFIG=vps/vps_cmd_proxy/${SUBCOMMAND}.${VMID}.$(date +"%s").shell

echo "Process config ${CONFIG_FILE_NAME} -> ${PROCESSED_CONFIG}"
if [[ ! -e vps/vps_cmd_proxy ]]; then
    mkdir -p vps/vps_cmd_proxy
fi

mv ${CONFIG_FILE_NAME} ${PROCESSED_CONFIG}

# execute task with config
echo "Running subcommand: ${SUBCOMMAND}"
sudo /bin/bash ./vps/${SUBCOMMAND}.sh ${PROCESSED_CONFIG}

set +e

exit 0
