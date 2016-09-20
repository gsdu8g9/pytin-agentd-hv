Agent for the Pytin Project
===========================

Installation
------------

root$ python -V
If Python 2.7.x is not available, you must install it first.

Prerequisites
root$ apt-get -y update
root$ apt-get -y install unzip sudo wget mc

Time sync
root$ apt-get -y install ntpdate ntp
root$ ntpdate -d ntp1.vniiftri.ru
root$ service ntp restart

Install pip for the Python 2.7.x
root$ cd
root$ wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
root$ python2.7 get-pip.py

Install virtualenv to separate environments
root$ pip2.7 install virtualenv

Create App root
root$ mkdir -p /apps/pytin-agentd
root$ cd /apps/pytin-agentd

Create user
root$ useradd -m -s /bin/bash pyagentd
root$ chown -R pyagentd:pyagentd /apps/pytin-agentd
root$ su pyagentd

Create environment
pyagentd$ virtualenv /apps/pytin-agentd/venv
pyagentd$ exit

Under root, create /root/pyagentd to store production configs.
root$ mkdir -p /root/pyagentd
root$ chmod 0700 /root/pyagentd
root$ cd /root/pyagentd

Create config file agentd.cfg based on agentd.sample.cfg. This file will be used during production process.
root$ mcedit /root/pyagentd/agentd.cfg

Download deployment script to /root/pyagentd
root$ cd /root/pyagentd && wget --no-check-certificate https://raw.githubusercontent.com/servancho/pytin-agentd-hv/master/deploy/install.sh

Perform install
root$ bash install.sh

This script will install:
* celery
* init.d scripts to control celery-daemons
* Set directory and files settings
* Will install dependencies to the environment, listed in requirements.txt.

!!! Open access to redis server for the agent host.


agentd.cfg
----------

Transport for the messages
broker = redis://127.0.0.1:8888/1

Store results and track task states
backend = redis://127.0.0.1:8888/2

Pytin CMDB host with running API-server
cmdb-server=http://127.0.0.1:8080
cmdb-api-key=ksfakashfkgasddhjfgashjfgajhsgf

ID of the current hypervisor node in CMDB
cmdb-node-id=1

Heartbeat update interval of the Hypervisor node
heartbeat-interval-sec=30


Install Python 2.7.9
--------------------

root$ wget http://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz
root$ tar -xzf Python-2.7.9.tgz
root$ cd Python-2.7.9
root$ apt-get -y update
root$ apt-get -y install build-essential libsqlite3-dev zlib1g-dev libncurses5-dev libgdbm-dev libbz2-dev libreadline5-dev libssl-dev libdb-dev
root$ ./configure --prefix=/usr --enable-shared
root$ make && make install
root$ update-alternatives --install /usr/bin/python python /usr/bin/python2.6 20
root$ update-alternatives --install /usr/bin/python python /usr/bin/python2.7 10
root$ update-alternatives --set python /usr/bin/python2.6


Templates config
----------------

template: template name used to create VPS.
          It is in form: <driver>.param1.param2..paramN (kvm.centos.6.64.directadmin)
            driver: method of provisioning. Different drivers supports
                    different templates and provisioning depth.
                    Drivers can work with different virtualization technologies.


Supported drivers and templates
-------------------------------

Driver: kvm
-----------
kvm.manual
kvm.centos.6.64
kvm.centos.6.64.vesta
kvm.centos.7.64
kvm.debian.7.64
kvm.debian.8.64
kvm.ubuntu.14.04.64


Driver: openvz
--------------
openvz.centos-6-x86
openvz.centos-6-x86_64
openvz.centos-6-x86_64-minimal
openvz.centos-7-x86_64
openvz.debian-7.0-x86
openvz.ubuntu-14.04-x86
openvz.ubuntu-14.04-x86_64


Testing new templates
---------------------

* KVM
sudo /bin/bash ./vps/kvm.pvesh.create.sh config-name.shell

* OpenVZ
sudo /bin/bash ./vps/openvz.pvesh.create.sh config-name.shell

