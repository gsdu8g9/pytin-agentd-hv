#!/usr/bin/env bash

# Change this parameters
# USER_NAME=<user_name>
# VMID=<id_of_the_vm>
# VMNAME=<name_of_the_vm>
#
# HDD size in Gb
# HDDGB=5
#
# RAM size in Gb
# MEMMB=1024
#
# CPU cores
# VCPU=1
#
# IPADDR=<ip_of_the_vm>
# GW=<gateway_of_the_vm>
# NETMASK=<netmask_of_the_vm>
#
# DNS1
# DNS2
#
# Optional
# ROOTPASS


# debian-7.0-x86
# ubuntu-14.04-x86
# ubuntu-14.04-x86_64
# centos-6-x86
# centos-6-x86_64
# centos-7-x86_64
# centos-6-x86_64-minimal


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

pvectl create ${VMID} /var/lib/vz/template/cache/${TEMPLATE}.tar.gz -disk ${HDDGB}
vzctl set ${VMID} --hostname ${VMNAME} --save
vzctl set ${VMID} --ipadd ${IPADDR} --save
vzctl set ${VMID} --swap 0 --ram ${MEMMB}M --save
vzctl set ${VMID} --nameserver 46.17.40.200 --nameserver 46.17.46.200 --searchdomain justhost.ru --save
vzctl set ${VMID} --onboot yes --save
vzctl set ${VMID} --cpus ${VCPU} --save
vzctl start ${VMID}
vzctl set ${VMID} --userpasswd root:${ROOTPASS} --save
set +e

if [[ ! -z ${USER_NAME} ]]; then
    pveum useradd ${USER_NAME}@pve -comment 'PyAgent created ${USER_NAME}'
    pveum aclmod /vms/${VMID} -users ${USER_NAME}@pve -roles PVEVMUser
fi

# After this delimiter all output will be stored in the separate result section - return.
echo ""
echo ":RETURN:"
echo "rootpass=${ROOTPASS}"
