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

echo "Loading config from ${VPS_CONFIG_FILE}"
. "${VPS_CONFIG_FILE}"

################## do not change #################

# step into working dir
SCRIPTDIR=$(pwd)
WORKDIR=${SCRIPTDIR}/${VMID}-$(date +"%s")

trap "{ rm -rf ${WORKDIR}; }" EXIT

mkdir -p ${WORKDIR}
cd ${WORKDIR}

# gen root password
ROOTPASS_GEN=`perl -le'print map+(A..Z,a..z,0..9)[rand 62],0..15'`
ROOTPASS=${ROOTPASS:-"${ROOTPASS_GEN}"}

set -e
NODENAME=$(hostname | cut -d'.' -f 1)
PXEHOST=$(hostname -i)
DISK_FILE_NAME=vm-${VMID}-disk-1.qcow2


echo "Create storage"
HDD=$((HDD + 5))
pvesh create /nodes/${NODENAME}/storage/local/content -filename "${DISK_FILE_NAME}" -format qcow2 -size "${HDD}G" -vmid ${VMID}

echo ""
echo "Create VPS with SETUP only config"
pvesh create /nodes/${NODENAME}/qemu -vmid ${VMID} -name "${HOSTNAME}" -storage 'local' -memory 4096 -sockets 1 -cores 4 -net0 'rtl8139,rate=12,bridge=vmbr0' -virtio0 "local:${VMID}/${DISK_FILE_NAME},cache=writeback" -cdrom "none" -onboot yes

echo ""
echo "Testing boot KS"
wget -q "http://${PXEHOST}:5000/static/${VMID}.boot.pxe"

echo ""
echo "Set args config"
pvesh set /nodes/${NODENAME}/qemu/${VMID}/config -args "-kernel /root/pyagentd/ipxe.lkrn -append 'set net0/ip ${IP} && set net0/netmask ${NETMASK} && set net0/gateway ${GATEWAY} && set dns ${DNS1} && ifopen net0 && chain http://${PXEHOST}:5000/static/${VMID}.boot.pxe'"

echo ""
echo "Start VPS install"
pvesh create /nodes/${NODENAME}/qemu/${VMID}/status/start

set +e

# waiting for the VPS to shutdown
echo ""
echo "Waiting for ${VMID} to finish processing."
qm wait ${VMID} -timeout 7200
if [ $? -ne 0 ]; then
    echo "Too long VPS creation, check the VPS console. Creation failed."
    pvesh create /nodes/${NODENAME}/qemu/${VMID}/status/stop

    RET_CODE=111
else
    # unmount cd, remove args
    pvesh set /nodes/${NODENAME}/qemu/${VMID}/config -delete args

    echo ""
    echo "Setting real config for the VPS ${VMID}"
    pvesh set /nodes/${NODENAME}/qemu/${VMID}/config -balloon 0 -memory ${RAM} -sockets 1 -cores ${CPU} -virtio0 "local:${VMID}/${DISK_FILE_NAME},cache=writeback,mbps_rd=5,mbps_wr=5" -cdrom "none" -onboot yes

    echo "Starting VPS"
    pvesh create /nodes/${NODENAME}/qemu/${VMID}/status/start

    if [[ ! -z "${USER}" ]]; then
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
    cat /etc/pve/local/qemu-server/${VMID}.conf | grep net

    RET_CODE=0
fi

exit ${RET_CODE}
