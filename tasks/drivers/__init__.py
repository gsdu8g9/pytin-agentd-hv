from __future__ import unicode_literals

import json
import os
import subprocess
import time

from celery.utils.log import get_task_logger

logger = get_task_logger(__name__)


class VpsTemplate(object):
    """
    Represents VPS template name. Consists of driver.options.
    """

    def __init__(self, template_name):
        assert template_name

        (self._driver, self._tpl_name) = template_name.lower().split('.', 1)

    @property
    def driver(self):
        return self._driver

    @property
    def template(self):
        return self._tpl_name


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
                caller_task.update_state(state='PROGRESS', meta={'stdout': out_line})

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

    logger.info("Process finished. Next we check for errors and return.")

    error_code = process.poll()
    if error_code > 0:
        raise Exception("Shell script error code: %s. Check logs." % error_code)

    logger.info("No errors. Return: %s" % command_output)

    return {
        'return': command_output,
        'code': error_code
    }


class CommandDriver(object):
    def create(self, caller_task, options):
        pass

    def start(self, caller_task, options):
        pass

    def stop(self, caller_task, options):
        pass
