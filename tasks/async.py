from __future__ import unicode_literals

import os
import subprocess
import time

from agentd import app


@app.task
def shell_hook(hook_name, options):
    assert hook_name
    assert options

    hooks_dir = os.path.join(os.path.dirname(__file__), 'hooks')
    hook_script = os.path.join(hooks_dir, hook_name + '.sh')

    if not os.path.exists(hook_script):
        raise Exception('Hook script not found: %s' % hook_name)

    runtime_dir = os.path.join(os.path.dirname(__file__), 'runtime')
    json_options_file = os.path.join(runtime_dir, "%s.json" % int(time.time()))

    cmd = '/bin/bash %s %s' % (hook_script, json_options_file)

    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)

    command_output = []

    try:
        while True:
            out = process.stdout.readline()

            if out == '' and process.poll() is not None:
                break
            if out != '':
                shell_hook.update_state(state='PROGRESS', meta={'line': out})
                command_output.append(out.strip())
    except Exception, ex:
        process.kill()
        raise ex

    return {
        'output': command_output,
        'code': process.poll()
    }
