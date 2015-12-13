from __future__ import unicode_literals

import json
import os
import subprocess
import time

from celery.utils.log import get_task_logger

from tasks.drivers import CommandDriver

logger = get_task_logger(__name__)


def shell_hook(caller_task, hook_name, options):
    assert caller_task
    assert hook_name
    assert options

    hooks_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'hooks')
    runtime_dir = os.path.join(hooks_dir, 'runtime')
    hook_script = os.path.join(hooks_dir, hook_name + '.sh')

    if not os.path.exists(hook_script):
        raise Exception('Hook script not found: %s (%s)' % (hook_name, hook_script))

    # save options as json
    json_options_file = os.path.join(runtime_dir, "%s.json" % int(time.time()))
    with open(json_options_file, mode='w') as json_options:
        json_options.write(json.dumps(options))

    cmd = 'cd %s && /bin/bash %s %s' % (hooks_dir, hook_script, json_options_file)

    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    command_output = {}
    store_return = False
    try:
        while True:
            out = process.stdout.readline()

            if out:
                out = out.decode(encoding='utf-8').strip()

            if out == '' and process.poll() is not None:
                break
            if out != '':
                logger.info(out)

                out_line = out.strip().encode(encoding='utf-8')
                caller_task.update_state(state='PROGRESS', meta={'line': out_line})

                if store_return:
                    parts = out_line.split('=', 1)
                    if len(parts) > 1:
                        command_output[parts[0].strip().lower()] = parts[1].strip()

            if out == ':RETURN:':
                store_return = True

    except Exception, ex:
        process.kill()
        raise ex
    finally:
        if os.path.exists(json_options_file):
            os.remove(json_options_file)

    error_code = process.poll()
    if error_code > 0:
        raise Exception("Shell script error code: %s. Check logs." % error_code)

    return {
        'return': command_output,
        'code': error_code
    }


class ShellKVMDriver(CommandDriver):
    START_CMD = 'start.qm'
    STOP_CMD = 'stop.qm'

    def create(self, caller_task, options):
        assert caller_task
        assert options
        assert 'template' in options
        assert 'vmid' in options
        assert 'hdd' in options
        assert 'ram' in options
        assert 'cpu' in options
        assert 'user' in options
        assert 'ip' in options
        assert 'gateway' in options
        assert 'netmask' in options
        assert 'hostname' in options

        shell_proxy_options = {}
        for option in options:
            shell_proxy_options[option.upper()] = options[option]

        shell_proxy_options['SUBCOMMAND'] = options['template']

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)

    def start(self, caller_task, options):
        assert caller_task
        assert options
        assert 'vmid' in options

        options['SUBCOMMAND'] = ShellKVMDriver.START_CMD

        shell_proxy_options = {}
        for option in options:
            shell_proxy_options[option.upper()] = options[option]

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)

    def stop(self, caller_task, options):
        assert caller_task
        assert options

        options['SUBCOMMAND'] = ShellKVMDriver.STOP_CMD

        shell_proxy_options = {}
        for option in options:
            shell_proxy_options[option.upper()] = options[option]

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)


class ShellOpenVZDriver(CommandDriver):
    CREATE_CMD = 'create.ovz'
    START_CMD = 'start.ovz'
    STOP_CMD = 'stop.ovz'

    def create(self, caller_task, options):
        assert caller_task
        assert options
        assert 'template' in options
        assert 'vmid' in options
        assert 'hdd' in options
        assert 'ram' in options
        assert 'cpu' in options
        assert 'user' in options
        assert 'ip' in options
        assert 'gateway' in options
        assert 'netmask' in options
        assert 'hostname' in options

        shell_proxy_options = {}
        for option in options:
            shell_proxy_options[option.upper()] = options[option]

        shell_proxy_options['SUBCOMMAND'] = ShellOpenVZDriver.CREATE_CMD
        shell_proxy_options['TEMPLATE'] = options['template']

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)

    def start(self, caller_task, options):
        assert caller_task
        assert options
        assert 'vmid' in options

        options['SUBCOMMAND'] = ShellOpenVZDriver.START_CMD

        shell_proxy_options = {}
        for option in options:
            shell_proxy_options[option.upper()] = options[option]

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)

    def stop(self, caller_task, options):
        assert caller_task
        assert options

        options['SUBCOMMAND'] = ShellOpenVZDriver.STOP_CMD

        shell_proxy_options = {}
        for option in options:
            shell_proxy_options[option.upper()] = options[option]

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)
