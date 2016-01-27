#!/usr/bin/env bash

DISTRIB_DIR=/root/pyagentd
APP_TARGET=/apps/pytin-agentd

cd

echo "Deploying only templates"
mkdir -p ${DISTRIB_DIR}
cd ${DISTRIB_DIR}
wget https://github.com/servancho/pytin-agentd-hv/archive/master.zip
unzip master.zip

rm -rf ${APP_TARGET}/bootrepo/templates
cp -rf ./pytin-agentd-hv-master/bootrepo/templates ${APP_TARGET}/bootrepo/

chown -R pyagentd:pyagentd ${APP_TARGET}

cd

echo "Cleanup"
rm -rf ${DISTRIB_DIR}/pytin-agentd-hv-master
rm -f ${DISTRIB_DIR}/*.zip
rm -rf ${APP_TARGET}/tests
rm -rf ${APP_TARGET}/deploy

echo "Done."

exit 0
