from __future__ import unicode_literals

import unittest

from tasks.async import vps_create, vps_start, vps_stop
from tasks.drivers.shell import ShellKVMDriver


class TestAsyncTasks(unittest.TestCase):
    def test_vps_create(self):
        """
        Test parameters passing to create.
        """
        options = dict(debug=1,
                       vmid=2,
                       template='kvm.testing',
                       user='testuser',
                       ram=1024,
                       hdd=50,
                       cpu=2,
                       ip='46.17.17.17',
                       gateway='46.17.17.1',
                       netmask='255.255.254.0',
                       hostname='hostname.host')

        result = vps_create.apply(args=(options,), throw=True)

        result_data = result.get()

        self.assertEqual(result.status, 'SUCCESS')
        self.assertEqual(0, result_data['code'])
        self.assertEqual(19, len(result_data['return']))

        self.assertEqual(options['ip'], result_data['return']['ip'])
        self.assertEqual(options['gateway'], result_data['return']['gateway'])
        self.assertEqual(options['netmask'], result_data['return']['netmask'])
        self.assertEqual(options['hostname'], result_data['return']['hostname'])
        self.assertEqual(options['user'], result_data['return']['user'])
        self.assertEqual(unicode(options['hdd']), result_data['return']['hdd'])
        self.assertEqual(unicode(options['cpu']), result_data['return']['cpu'])
        self.assertEqual(options['template'], result_data['return']['template'])
        self.assertEqual(True, 'rootpass' in result_data['return'])

    def test_vps_start(self):
        """
        Test parameters passing to start.
        """
        ShellKVMDriver.START_CMD = 'kvm.testing'
        ShellKVMDriver.STOP_CMD = 'kvm.testing'

        options = dict(driver='kvm',
                       vmid=2,
                       user='testuser',
                       debug=1)

        result = vps_start.apply(args=(options,), throw=True)

        result_data = result.get()

        self.assertEqual(result.status, 'SUCCESS')
        self.assertEqual(0, result_data['code'])
        self.assertEqual(11, len(result_data['return']))

        self.assertEqual(unicode(options['vmid']), result_data['return']['vmid'])
        self.assertEqual(options['user'], result_data['return']['user'])

    def test_vps_stop(self):
        """
        Test parameters passing to stop.
        """
        ShellKVMDriver.START_CMD = 'kvm.testing'
        ShellKVMDriver.STOP_CMD = 'kvm.testing'

        options = dict(driver='kvm',
                       vmid=2,
                       user='testuser',
                       debug=1)

        result = vps_stop.apply(args=(options,), throw=True)

        result_data = result.get()

        self.assertEqual(result.status, 'SUCCESS')
        self.assertEqual(0, result_data['code'])
        self.assertEqual(11, len(result_data['return']))

        self.assertEqual(unicode(options['vmid']), result_data['return']['vmid'])
        self.assertEqual(options['user'], result_data['return']['user'])


if __name__ == '__main__':
    unittest.main()
