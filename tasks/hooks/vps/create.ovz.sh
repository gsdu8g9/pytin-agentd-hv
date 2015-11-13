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
# Optional
# ROOTPASS
#
# IP_ADDRS=(ip1 ip2)

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

DNS1=46.17.40.200
DNS2=46.17.46.200

################## do not change #################
ROOTPASS_GEN=`perl -le'print map+(A..Z,a..z,0..9)[rand 62],0..15'`
ROOTPASS=${ROOTPASS:-"${ROOTPASS_GEN}"}

pvectl create ${VMID} /var/lib/vz/template/cache/${TEMPLATE}.tar.gz -disk ${HDDGB}
vzctl set ${VMID} --hostname ${USER_NAME}.users.justhost.ru --save

for IP in ${IP_ADDRS[*]}
do
    vzctl set ${VMID} --ipadd ${IP} --save
done

vzctl set ${VMID} --swap 0 --ram ${MEMMB}M --save
vzctl set ${VMID} --nameserver 46.17.40.200 --nameserver 46.17.46.200 --searchdomain justhost.ru --save
vzctl set ${VMID} --onboot yes --save
vzctl set ${VMID} --cpus ${VCPU} --save
vzctl start ${VMID}
vzctl set ${VMID} --userpasswd root:${ROOTPASS} --save

if [[ ! -z ${USER_NAME} ]]; then
    pveum roleadd PVE_KVM_User -privs "VM.PowerMgmt VM.Audit VM.Console VM.Snapshot VM.Backup"
    pveum useradd ${USER_NAME}@pve -comment 'PyAgent created ${USER_NAME}'
    pveum aclmod /vms/${VMID} -users ${USER_NAME}@pve -roles PVE_KVM_User
fi

# After this delimiter all output will be stored in the separate result section - return.
echo ""
echo ":RETURN:"
echo "rootpass=${ROOTPASS}"
