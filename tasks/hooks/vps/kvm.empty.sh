#!/bin/bash

# Copyright (C) 2015 JustHost.ru, Dmitry Shilyaev
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# Description:
#   Create KVM virtual machine with kickstarter file from the command line.
#
# Requirements:
#   genisoimage, qemu
#
# Required options:
# CentOS version
#
# Change this parameters
# USER=<USER>
# VMID=<id_of_the_vm>
# HOSTNAME=<name_of_the_vm>
#
# HDD size in Gb
# HDD=5
#
# RAM size in Gb
# RAM=1024
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
SCRIPTDIR=$(pwd)
WORKDIR=${SCRIPTDIR}/${VMID}-$(date +"%s")

mkdir -p ${WORKDIR}
cd ${WORKDIR}

ROOTPASS_GEN=`perl -le'print map+(A..Z,a..z,0..9)[rand 62],0..15'`
ROOTPASS=${ROOTPASS:-"${ROOTPASS_GEN}"}

qm create ${VMID} --ide2 none,media=cdrom --name ${HOSTNAME} --net0 rtl8139,rate=50,bridge=vmbr0 --virtio0 local:${HDD},format=qcow2,cache=writeback,mbps_rd=5,mbps_wr=5 --bootdisk virtio0 --ostype l26 --memory ${RAM} --onboot yes --cores ${CPU} --sockets 1

RET_CODE=0

if [[ ! -z ${USER} ]]; then
    pveum useradd ${USER}@pve -comment "PyAgent created ${USER}"
    pveum aclmod /vms/${VMID} -users ${USER}@pve -roles PVEVMUser
fi

# After this delimiter all output will be stored in the separate result section - return.
echo ""
echo ":RETURN:"
echo "ROOTPASS=${ROOTPASS}"
cat /etc/pve/local/qemu-server/${VMID}.conf | grep net

RET_CODE=0

echo "Remove working dir: " ${WORKDIR}
rm -rf ${WORKDIR}

exit ${RET_CODE}
