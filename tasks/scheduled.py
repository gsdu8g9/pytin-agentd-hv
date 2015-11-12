from __future__ import unicode_literals

from agentd import app
from celeryconfig import AGENT_NODE_QUEUE_TASKS
from vendor.cmdb import CmdbClient


@app.task
def heartbeat(cmdb_server, api_key, node_id):
    assert cmdb_server
    assert api_key
    assert node_id

    cmdb_client = CmdbClient(cmdb_server, api_key)
    hb_value = cmdb_client.heartbeat(node_id, {'taskqueue': AGENT_NODE_QUEUE_TASKS})

    return hb_value
