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


echo "Passed $1"

if [[ -z $1 ]]; then
    echo "Config file must be specified."
    exit 1
fi

VPS_CONFIG_FILE=$1

echo "Loading config from " ${VPS_CONFIG_FILE}
. "${VPS_CONFIG_FILE}"


# results are captured after this line
echo ""
echo ":RETURN:"
cat ${VPS_CONFIG_FILE}
echo ""
ROOTPASS_GEN=`perl -le'print map+(A..Z,a..z,0..9)[rand 62],0..15'`
ROOTPASS=${ROOTPASS:-"${ROOTPASS_GEN}"}
echo "ROOTPASS=${ROOTPASS}"

inc=5
while (( inc > 0 )); do
    echo "date${inc}=$(date)"
    sleep 1
    inc=$((inc-1))
done

exit 0
