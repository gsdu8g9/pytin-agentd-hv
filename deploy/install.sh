#!/usr/bin/env bash

DISTRIB_DIR=/root/pyagentd
APP_TARGET=/apps/pytin-agentd

cd

echo "Stopping services"
/etc/init.d/celeryd stop
/etc/init.d/celerybeat stop

echo "Deploying app"
mkdir -p ${DISTRIB_DIR}
cd ${DISTRIB_DIR}
wget https://github.com/servancho/pytin-agentd-hv/archive/master.zip
unzip master.zip

# reinit app files
mv ${APP_TARGET} ${APP_TARGET}.$(date +"%s")
cp -rf ./pytin-agentd-hv-master/* ${APP_TARGET}

echo "Copy production agentd.cfg config"
cp -f ${DISTRIB_DIR}/agentd.cfg ${APP_TARGET}

chown -R pyagentd:pyagentd ${APP_TARGET}

echo "Deploying app dependencies"
sudo -u pyagentd /bin/bash - << venvpart
id
cd ${APP_TARGET}
virtualenv /apps/pytin-agentd/venv
source ./venv/bin/activate

echo "Update dependencies"
pip install --upgrade pip
pip install -r requirements.txt

echo "Exit virtual environment"
deactivate
venvpart

echo "Copy init.d scripts"
cp -f ${APP_TARGET}/deploy/conf/celery* /etc/init.d/
cp -f ${APP_TARGET}/deploy/conf/celeryd.config /etc/default/celeryd
rm -f /etc/init.d/celeryd.config

chown root:root /etc/default/celeryd
chown root:root /etc/init.d/celery*
chmod +x /etc/init.d/celery*

echo "Install sudoer"
cp -f ${APP_TARGET}/deploy/conf/pyagentd.sudo /etc/sudoers.d/pyagentd
chmod 0440 /etc/sudoers.d/pyagentd
chown root:root /etc/sudoers.d/*

echo "Update ipxe.lkrn"
wget -O ${DISTRIB_DIR}/ipxe.lkrn http://boot.ipxe.org/ipxe.lkrn
chmod 0600 ${DISTRIB_DIR}/ipxe.lkrn

cd

echo "Cleanup"
rm -rf ${DISTRIB_DIR}/pytin-agentd-hv-master
rm -f ${DISTRIB_DIR}/*.zip
rm -rf ${APP_TARGET}/tests
rm -rf ${APP_TARGET}/deploy

echo "Starting services"
/etc/init.d/celeryd start
/etc/init.d/celerybeat start


echo "Done."

exit 0
