from __future__ import unicode_literals

import os

from celery.utils.log import get_task_logger
from jinja2 import Environment, FileSystemLoader

import bootrepo
from tasks.drivers import CommandDriver, shell_hook, VpsTemplate

logger = get_task_logger(__name__)


class PveshDriver(CommandDriver):
    CREATE_CMD = ''
    START_CMD = ''
    STOP_CMD = ''

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

        shell_proxy_options['SUBCOMMAND'] = self.CREATE_CMD

        vps_tpl = VpsTemplate(options['template'])

        shell_proxy_options['TEMPLATE'] = vps_tpl.template

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)

    def start(self, caller_task, options):
        assert caller_task
        assert options
        assert 'vmid' in options

        options['SUBCOMMAND'] = self.START_CMD

        shell_proxy_options = {}
        for option in options:
            shell_proxy_options[option.upper()] = options[option]

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)

    def stop(self, caller_task, options):
        assert caller_task
        assert options

        options['SUBCOMMAND'] = self.STOP_CMD

        shell_proxy_options = {}
        for option in options:
            shell_proxy_options[option.upper()] = options[option]

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)


class PveshKVMDriver(PveshDriver):
    """
    KVM driver used to provision KVM VPS instances. It uses Flash web server to pass
    kickstart files. All templates are stored in bootrepo folder.
    """
    CREATE_CMD = 'kvm.pvesh.create'
    START_CMD = 'kvm.pvesh.start'
    STOP_CMD = 'kvm.pvesh.stop'

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

        shell_proxy_options['SUBCOMMAND'] = self.CREATE_CMD

        vps_tpl = VpsTemplate(options['template'])
        shell_proxy_options['TEMPLATE'] = vps_tpl.template

        logger.info("Create KVM using template %s (%s)" % (options['template'], vps_tpl.template))

        self._render_template('%s.boot.template' % vps_tpl.template, '%s.boot.pxe' % options['vmid'], options)
        self._render_template('%s.template' % vps_tpl.template, '%s.pxe' % options['vmid'], options)

        return shell_hook(caller_task, 'vps_cmd_proxy', shell_proxy_options)

    def _render_template(self, template_name, rendered_name, options):
        assert template_name

        fs_template_path = os.path.join(bootrepo.TEMPLATES_DIR, template_name)
        if not os.path.exists(fs_template_path):
            raise IOError('Template %s does not exists.' % fs_template_path)

        rendered_fs_template_path = os.path.join(bootrepo.STATIC_FILES_DIR, rendered_name)
        j2_env = Environment(loader=FileSystemLoader(bootrepo.TEMPLATES_DIR), trim_blocks=True)
        template = j2_env.get_template(template_name).render(data=options)
        with open(rendered_fs_template_path, 'w') as rendered_tpl:
            rendered_tpl.write(template.encode('utf-8'))


class PveshOpenVZDriver(PveshDriver):
    CREATE_CMD = 'openvz.pvesh.create'
    START_CMD = 'openvz.pvesh.start'
    STOP_CMD = 'openvz.pvesh.stop'
