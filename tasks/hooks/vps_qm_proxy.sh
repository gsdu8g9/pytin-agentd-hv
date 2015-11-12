#!/usr/bin/env bash

# Shell Hook для создания VPS. Может служить для преобразования параметров и передачи управления
# специализированному скрипту.
#
# Параметры передаются в этот скрипт через файл $1, где они находятся в формате JSON.
# После этого параметры преобразуются и передаются специальным скриптам для создания VPS.
# После строки :RETURN: в stdout весь вывод скрипта возвратится с ответом для последующего парсинга.

# convert task config parameters to shell config
CONFIG_ID=$(date +"%s")
CONFIG_FILE_NAME="kvm/${CONFIG_ID}.shell"

set -e
python optconv.py $1 ${CONFIG_FILE_NAME}

. "${CONFIG_FILE_NAME}"

if [[ -z ${SUBCOMMAND} ]]; then
    echo "Missing SUBCOMMAND"
    exit 101
fi

PROCESSED_CONFIG=kvm/create_vps_qm/${VMID}.create.$(date +"%s").shell

echo "Process config ${CONFIG_FILE_NAME} -> ${PROCESSED_CONFIG}"
if [[ ! -e kvm/create_vps_qm ]]; then
    mkdir -p kvm/create_vps_qm
fi

mv ${CONFIG_FILE_NAME} ${PROCESSED_CONFIG}

# execute task with config
echo "Running subcommand: ${SUBCOMMAND}"
sudo /bin/bash ./kvm/${SUBCOMMAND}.sh ${PROCESSED_CONFIG}

set +e

exit 0
