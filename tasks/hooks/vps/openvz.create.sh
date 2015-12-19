#!/usr/bin/env bash

# Change this parameters
# USER=<USER>
# VMID=<id_of_the_vm>
# HOSTNAME=<name_of_the_vm>
#
# HDD size in Gb
# HDD=5
#
# RAM size in Gb
# MEM=1024
#
# CPU cores
# CPU=1
#
# IP=<ip_of_the_vm>
# GATEWAY=<gateway_of_the_vm>
# NETMASK=<netmask_of_the_vm>
#
# DNS1
# DNS2
#
# Optional
# ROOTPASS


if [[ -z $1 ]]; then
    echo "Config file must be specified."
    exit 1
fi

VPS_CONFIG_FILE=$1

echo "Loading config from " ${VPS_CONFIG_FILE}
. "${VPS_CONFIG_FILE}"

################## do not change #################
ROOTPASS_GEN=`perl -le'print map+(A..Z,a..z,0..9)[rand 62],0..15'`
ROOTPASS=${ROOTPASS:-"${ROOTPASS_GEN}"}

set -e
OVZ_TEMPLATE_FILE=/var/lib/vz/template/cache/${TEMPLATE}.tar.gz
if [[ ! -e ${OVZ_TEMPLATE_FILE} ]]; then
    wget --no-check-certificate -P /var/lib/vz/template/cache/ http://download.openvz.org/template/precreated/${TEMPLATE}.tar.gz
fi

pvectl create ${VMID} /var/lib/vz/template/cache/${TEMPLATE}.tar.gz -disk ${HDD}
vzctl set ${VMID} --hostname ${HOSTNAME} --save
vzctl set ${VMID} --ipadd ${IP} --save
vzctl set ${VMID} --swap 0 --ram ${RAM}M --save
vzctl set ${VMID} --nameserver ${DNS1} --nameserver ${DNS2} --searchdomain justhost.ru --save
vzctl set ${VMID} --onboot yes --save
vzctl set ${VMID} --cpus ${CPU} --save
vzctl start ${VMID}
vzctl set ${VMID} --userpasswd root:${ROOTPASS} --save
set +e

RET_CODE=$?

if [[ ! -z ${USER} ]]; then
    pveum useradd ${USER}@pve -comment "PyAgent created ${USER}"
    pveum aclmod /vms/${VMID} -users ${USER}@pve -roles PVEVMUser
fi

# After this delimiter all output will be stored in the separate result section - return.
echo ""
echo ":RETURN:"
echo "ROOTPASS=${ROOTPASS}"

exit ${RET_CODE}
