from __future__ import unicode_literals

from celery import Celery

import celeryconfig

app = Celery('agentd',
             broker=celeryconfig.BROKER_URL,
             backend=celeryconfig.CELERY_RESULT_BACKEND,
             include=['tasks.scheduled', 'tasks.async'])
app.config_from_object('celeryconfig')
