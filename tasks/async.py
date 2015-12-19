from __future__ import unicode_literals

from celery.utils.log import get_task_logger

from agentd import app
from tasks.drivers.shell import ShellKVMDriver, ShellOpenVZDriver

logger = get_task_logger(__name__)

DRIVERS = {
    'kvm': ShellKVMDriver(),
    'openvz': ShellOpenVZDriver()
}


def _get_driver_impl(options):
    """
    Returns the requested driver implementation.
    :param options: request options
    :return: driver implementation
    """
    assert options
    assert 'driver' in options

    driver = options['driver']

    if driver not in DRIVERS:
        raise Exception("Unknown driver %s." % driver)

    return DRIVERS[driver]


@app.task
def vps_create(options):
    assert options
    assert 'template' in options

    if 'driver' not in options:
        (driver, tpl_name) = options['template'].split('.', 1)
        options['driver'] = driver

    return _get_driver_impl(options).create(vps_create, options)


@app.task
def vps_start(options):
    assert options
    assert 'driver' in options

    return _get_driver_impl(options).start(vps_start, options)


@app.task
def vps_stop(options):
    assert options
    assert 'driver' in options

    return _get_driver_impl(options).stop(vps_stop, options)
