from __future__ import unicode_literals

import os
import unittest

import bootrepo
import tasks
from tasks.async import vps_create
from tasks.drivers.pvesh import PveshKVMDriver, PveshOpenVZDriver


def mock_shell_hook(caller_task, hook_name, options):
    return {
        'return': options,
        'code': 0
    }


# replace shell_hook method
tasks.drivers.pvesh.shell_hook = mock_shell_hook


class TestPveshDriver(unittest.TestCase):
    def test_vps_kvm_create(self):
        """
        Test parameters passing to create.
        """
        options = dict(debug=1,
                       vmid=2,
                       template='kvm.centos.6.64',
                       user='testuser',
                       ram=1024,
                       hdd=50,
                       cpu=2,
                       dns1='46.17.46.200',
                       dns2='46.17.40.200',
                       ip='46.17.17.17',
                       gateway='46.17.17.1',
                       netmask='255.255.254.0',
                       hostname='hostname.host')

        driver = PveshKVMDriver()
        result = driver.create(vps_create, options)

        self.assertTrue(os.path.exists(os.path.join(bootrepo.STATIC_FILES_DIR, '2.boot.pxe')))
        self.assertTrue(os.path.exists(os.path.join(bootrepo.STATIC_FILES_DIR, '2.pxe')))

        self.assertEqual('kvm.pvesh.create', result['return']['SUBCOMMAND'])
        self.assertEqual('centos.6.64', result['return']['TEMPLATE'])

    def test_vps_openvz_create(self):
        """
        Test parameters passing to create.
        """
        options = dict(debug=1,
                       vmid=2,
                       template='kvm.centos.6.64',
                       user='testuser',
                       ram=1024,
                       hdd=50,
                       cpu=2,
                       ip='46.17.17.17',
                       dns1='46.17.46.200',
                       dns2='46.17.40.200',
                       gateway='46.17.17.1',
                       netmask='255.255.254.0',
                       hostname='hostname.host')

        driver = PveshOpenVZDriver()
        result = driver.create(vps_create, options)

        self.assertEqual('openvz.pvesh.create', result['return']['SUBCOMMAND'])
        self.assertEqual('centos.6.64', result['return']['TEMPLATE'])
