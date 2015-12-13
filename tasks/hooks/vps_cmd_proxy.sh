#!/usr/bin/env bash

# Shell Hook для создания VPS. Может служить для преобразования параметров и передачи управления
# специализированному скрипту.
#
# Параметры передаются в этот скрипт через файл $1, где они находятся в формате JSON.
# После этого параметры преобразуются и передаются специальным скриптам для создания VPS.
# После строки :RETURN: в stdout весь вывод скрипта возвратится с ответом для последующего парсинга.

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

# execute task with config
echo "Running subcommand: ${SUBCOMMAND}"

if [ -z ${DEBUG} ]; then
    sudo /bin/bash ./vps/${SUBCOMMAND}.sh ${ARCHIVED_CONFIG}
else
    /bin/bash ./vps/${SUBCOMMAND}.sh ${ARCHIVED_CONFIG}
fi

set +e

exit 0
