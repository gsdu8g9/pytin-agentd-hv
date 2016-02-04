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
# TEMPLATE
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

OVZ_TEMPLATE_FILE=/var/lib/vz/template/cache/${TEMPLATE}.tar.gz
if [[ ! -e ${OVZ_TEMPLATE_FILE} ]]; then
    wget --no-check-certificate -P /var/lib/vz/template/cache/ http://download.openvz.org/template/precreated/${TEMPLATE}.tar.gz
fi

set -e
NODENAME=$(hostname | cut -d'.' -f 1)
pvesh create /nodes/${NODENAME}/openvz -vmid ${VMID} -ostemplate "local:vztmpl/${TEMPLATE}.tar.gz" -password ${ROOTPASS} -hostname ${HOSTNAME} -disk ${HDD} -swap 0 -memory ${RAM} -cpus ${CPU} -onboot yes -ip_address ${IP} -nameserver "${DNS1}" -nameserver "${DNS2}"
pvesh create /nodes/${NODENAME}/openvz/${VMID}/status/start
set +e

RET_CODE=$?

if [[ ! -z ${USER} ]]; then
    pvesh create /access/users -userid "${USER}@pve" -password "${ROOTPASS}" -comment "PyAgent created ${USER}"
    pvesh set /access/acl -path /vms/${VMID} -users "${USER}@pve" -roles PVEVMUser
    pvesh set /access/password -userid "${USER}@pve" -password "${ROOTPASS}"
fi

# After this delimiter all output will be stored in the separate result section - return.
echo ""
echo ":RETURN:"
echo "VMID=${VMID}"
echo "USER=${USER}"
echo "ROOTPASS=${ROOTPASS}"
echo "IP=${IP}"

exit ${RET_CODE}
