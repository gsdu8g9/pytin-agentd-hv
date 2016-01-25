from __future__ import unicode_literals

import unittest

from tasks.drivers import VpsTemplate


class TestVpsTemplate(unittest.TestCase):
    def test_parse_template(self):
        vps_tpl_name = 'kvm.centos.6.directadmin'
        vps_tpl = VpsTemplate(vps_tpl_name)

        self.assertEqual('kvm', vps_tpl.driver)
        self.assertEqual('centos.6.directadmin', vps_tpl.template)
