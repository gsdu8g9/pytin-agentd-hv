Agent for the Pytin Project
===========================

Установка
---------

Ставим pip
root$ cd
root$ wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
root$ python get-pip.py

Ставим virtualenv для управления окружениями
root$ pip install virtualenv

Создаем корень проекта
root$ mkdir -p /apps/pytin-agentd
root$ cd /apps/pytin-agentd

Создать пользователя
root$ useradd -m -s /bin/bash pyagentd
root$ chown -R pyagentd:pyagentd /apps/pytin-agentd
root$ su pyagentd

Создаем окружение
pyagentd$ virtualenv /apps/pytin-agentd/venv
pyagentd$ exit

Под root, создать папку /root/pyagentd
root$ mkdir -p /root/pyagentd
root$ chmod 0700 /root/pyagentd
root$ cd /root/pyagentd

Создать файл конфигурации. За основу взять agentd.sample.cfg из дистрибутива. Этот файл
будет копироваться по месту установки агента при обновлении.
root$ touch /root/pyagentd/agentd.cfg

Загрузить установочный скрипт в /root/pyagentd
root$ cd /root/pyagentd && wget --no-check-certificate https://raw.githubusercontent.com/servancho/pytin-agentd-hv/master/deploy/install.sh

Выполнить установку
root$ bash install.sh

Скрипт ставит celery, init.d скрипты запуска celery-демонов, проставляет права на файлы и директории.
Так же внутри виртуального окружения обновляются зависимости, указанные в requirements.txt.

Открыть ноде доступ на redis.


Конфигурация agentd.cfg
-----------------------

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
