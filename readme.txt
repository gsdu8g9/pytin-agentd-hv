Agent for the Pytin Project
===========================

Установка
---------

Ставим pip
$ cd
$ wget https://bootstrap.pypa.io/get-pip.py
$ python get-pip.py

Ставим virtualenv для управления окружениями
$ pip install virtualenv

Создаем корень проекта
$ mkdir -p /apps/pytin-agentd
$ cd /apps/pytin-agentd

Создать пользователя
$ useradd -m -s /bin/bash pyagentd
$ chown -R pyagentd:pyagentd /apps/pytin-agentd
$ su pyagentd

Создаем окружение
$ virtualenv /apps/pytin-agentd/venv

$ exit

Под root выполнить скрипт, который установит/обновит агента
$ bash < (curl https://raw.githubusercontent.com/servancho/pytin-agentd-hv/master/deploy/install.sh)

либо так
$ wget https://raw.githubusercontent.com/servancho/pytin-agentd-hv/master/deploy/install.sh
$ bash install.sh

Скрипт ставит celery, init.d скрипты запуска celery-демонов, проставляет права на файлы и директории.
Так же внутри виртуального окружения обновляются зависимости, указанные в requirements.txt.


Конфигурация
------------

Конфигурация агента находится в файле agentd.cfg.

Транспорт для сообщений
broker = redis://127.0.0.1:8888/1

Хранение результатов и отслеживание статусов задач
backend = redis://127.0.0.1:8888/2

Хост Pytin CMDB с запущенным API-сервером
cmdb-server=http://127.0.0.1:8080
cmdb-api-key=ksfakashfkgasddhjfgashjfgajhsgf

ID ноды в CMDB, соответствующей текущему хосту, на котором установлен агент
cmdb-node-id=1

Период обновления параметра хоста agentd_heartbeat в CMDB
heartbeat-interval-sec=30


