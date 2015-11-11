from __future__ import unicode_literals

import json
import os
import subprocess
import time

from celery.utils.log import get_task_logger

from agentd import app

logger = get_task_logger(__name__)


@app.task
def shell_hook(hook_name, options):
    assert hook_name
    assert options

    hooks_dir = os.path.join(os.path.dirname(__file__), 'hooks')
    hook_script = os.path.join(hooks_dir, hook_name + '.sh')

    if not os.path.exists(hook_script):
        raise Exception('Hook script not found: %s' % hook_name)

    runtime_dir = os.path.join(os.path.dirname(__file__), 'runtime')

    # save options as json
    json_options_file = os.path.join(runtime_dir, "%s.json" % int(time.time()))
    with open(json_options_file, mode='w') as json_options:
        json_options.write(json.dumps(options))

    cmd = 'cd %s && /bin/bash %s %s' % (hooks_dir, hook_script, json_options_file)

    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    command_output = []

    try:
        while True:
            out = process.stdout.readline()

            if out:
                out = out.decode(encoding='utf-8')

            if out == '' and process.poll() is not None:
                break
            if out != '':
                logger.info(out)
                shell_hook.update_state(state='PROGRESS', meta={'line': out.encode(encoding='utf-8')})
                command_output.append(out.strip().encode(encoding='utf-8'))
    except Exception, ex:
        process.kill()
        raise ex
    finally:
        if os.path.exists(json_options_file):
            os.remove(json_options_file)

    return {
        'output': command_output,
        'code': process.poll()
    }
