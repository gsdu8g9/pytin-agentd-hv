from __future__ import unicode_literals

import unittest

from tasks.async import shell_hook


class TestAsyncTasks(unittest.TestCase):
    def test_shell_hook(self):
        """
        Test shell hook and results capture.
        :return:
        """
        result = shell_hook.apply(args=('test_exec', {'some': 'options'}))

        result_data = result.get()

        self.assertEqual(result.status, 'SUCCESS')
        self.assertEqual(5, len(result_data['return']))


if __name__ == '__main__':
    unittest.main()
