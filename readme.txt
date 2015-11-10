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
