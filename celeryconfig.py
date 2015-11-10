from __future__ import unicode_literals

import ConfigParser
from datetime import timedelta
import os

AGENT_CONFIG = ConfigParser.SafeConfigParser({'heartbeat-interval-sec': 5, 'log-file': None})
AGENT_CONFIG.read(os.path.join(os.path.dirname(__file__), 'agentd.cfg'))

AGENT_HEARTBEAT_INTERVAL = int(AGENT_CONFIG.get('agent', 'heartbeat-interval-sec'))

BROKER_URL = AGENT_CONFIG.get('agent', 'broker')
CELERY_RESULT_BACKEND = AGENT_CONFIG.get('agent', 'backend')

CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TIMEZONE = 'Europe/Moscow'
CELERY_ENABLE_UTC = True

CELERYBEAT_SCHEDULE = {
    'heartbeat': {
        'task': 'tasks.scheduled.heartbeat',
        'schedule': timedelta(seconds=AGENT_HEARTBEAT_INTERVAL),
        'args': (
            AGENT_CONFIG.get('agent', 'cmdb-server'),
            AGENT_CONFIG.get('agent', 'cmdb-api-key'),
            AGENT_CONFIG.get('agent', 'cmdb-node-id'))
    },
}
