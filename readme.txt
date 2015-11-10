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
$ useradd -s /bin/bash pyagentd
$ chown -R pyagentd:pyagentd /apps/pytin-agentd
$ su pyagentd

Создаем окружение
$ virtualenv /apps/pytin-agentd/venv

Активация окружения
$ source venv/bin/activate

# Ставим зависимости внутри окружения
$ pip install -r requirements.txt

выход из окружения
$ deactivate



wget https://raw.githubusercontent.com/celery/celery/3.1/extra/generic-init.d/celeryd
wget https://raw.githubusercontent.com/celery/celery/3.1/extra/generic-init.d/celerybeat

/etc/default/celeryd:

# Names of nodes to start
#   most people will only start one node:
CELERYD_NODES="worker1"
#   but you can also start multiple and configure settings
#   for each in CELERYD_OPTS (see `celery multi --help` for examples):
#CELERYD_NODES="worker1 worker2 worker3"
#   alternatively, you can specify the number of nodes to start:
#CELERYD_NODES=10

# Absolute or relative path to the 'celery' command:
CELERY_BIN="/usr/local/bin/celery"
#CELERY_BIN="/virtualenvs/def/bin/celery"

# App instance to use
# comment out this line if you don't use an app
CELERY_APP="proj"
# or fully qualified:
#CELERY_APP="proj.tasks:app"

# Where to chdir at start.
CELERYD_CHDIR="/opt/Myproject/"

# Extra command-line arguments to the worker
CELERYD_OPTS="--time-limit=300 --concurrency=8"

# %N will be replaced with the first part of the nodename.
CELERYD_LOG_FILE="/var/log/celery/%N.log"
CELERYD_PID_FILE="/var/run/celery/%N.pid"

# Workers should run as an unprivileged user.
#   You need to create this user manually (or you can choose
#   a user/group combination that already exists, e.g. nobody).
CELERYD_USER="celery"
CELERYD_GROUP="celery"

# If enabled pid and log directories will be created if missing,
# and owned by the userid/group configured.
CELERY_CREATE_DIRS=1
