from __future__ import unicode_literals

import ConfigParser
import os
import socket
from datetime import timedelta

from kombu import Queue

AGENT_CONFIG = ConfigParser.SafeConfigParser({'heartbeat-interval-sec': 5, 'log-file': None})
AGENT_CONFIG.read(os.path.join(os.path.dirname(__file__), 'agentd.cfg'))
AGENT_NODE_ID = AGENT_CONFIG.get('agent', 'cmdb-node-id')

AGENT_NODE_QUEUE_TASKS = "%s.tasks" % socket.gethostname()
AGENT_NODE_QUEUE_HEARTBEAT = "%s.heartbeat" % socket.gethostname()

BROKER_URL = AGENT_CONFIG.get('agent', 'broker')
CELERY_RESULT_BACKEND = AGENT_CONFIG.get('agent', 'backend')

CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TIMEZONE = 'Europe/Moscow'
CELERY_ENABLE_UTC = True

CELERY_QUEUES = (
    Queue("default", routing_key="default"),
    Queue(AGENT_NODE_QUEUE_TASKS, routing_key=AGENT_NODE_QUEUE_TASKS),
    Queue(AGENT_NODE_QUEUE_HEARTBEAT, routing_key=AGENT_NODE_QUEUE_HEARTBEAT),
)

CELERY_DEFAULT_EXCHANGE_TYPE = 'topic'
CELERY_DEFAULT_QUEUE = "default"
CELERY_DEFAULT_ROUTING_KEY = "default"

CELERYBEAT_SCHEDULE = {
    'heartbeat': {
        'task': 'tasks.scheduled.heartbeat',
        'schedule': timedelta(seconds=int(AGENT_CONFIG.get('agent', 'heartbeat-interval-sec'))),
        'options': {'routing_key': AGENT_NODE_QUEUE_HEARTBEAT},
        'args': (
            AGENT_CONFIG.get('agent', 'cmdb-server'),
            AGENT_CONFIG.get('agent', 'cmdb-api-key'),
            AGENT_NODE_ID)
    },
}
