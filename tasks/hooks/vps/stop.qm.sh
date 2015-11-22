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
#   Stop KVM virtual machine
#


if [[ -z $1 ]]; then
    echo "Config file must be specified."
    exit 1
fi

VPS_CONFIG_FILE=$1

echo "Loading config from " ${VPS_CONFIG_FILE}
. "${VPS_CONFIG_FILE}"

qm set ${VMID} --onboot no
qm stop ${VMID}

if [[ ! -z ${USER_NAME} ]]; then
    role_name=$(cat /etc/pve/user.cfg | grep ${USER_NAME} | grep "acl:" | cut -d':' -f 5)
    pveum acldel /vms/${VMID} -users ${USER_NAME}@pve -roles ${role_name}
fi
