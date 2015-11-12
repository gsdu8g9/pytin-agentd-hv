from __future__ import unicode_literals

import time

import requests


class CmdbClient(object):
    """
    Client bind for the Pytin CMDB API.
    """

    def __init__(self, server_url, api_key):
        assert server_url
        assert api_key

        self.server_url = server_url
        self.api_key = api_key

    def heartbeat(self, cmdb_node_id, extra_options=None):
        """
        Send heartbeat to the CMDB host by setting agentd_heartbeat (tick time) property.
        :param cmdb_node_id: CMDB node ID (server).
        :param extra_options: Extra options to set on CMDB node, prefixed with agentd_*.
        :return: heartbeat value (time ticks)
        """
        assert cmdb_node_id > 0

        heartbeat_value = int(time.time())

        headers = {
            "Authorization": "Token %s" % self.api_key,
            "Charset": "utf-8",
            "Accept": "application/json"
        }

        payload = {
            'options': [
                {'name': 'agentd_heartbeat', 'value': heartbeat_value},
            ]
        }

        if extra_options:
            for extra_option_name in extra_options:
                opt_name = "agentd_%s" % extra_option_name
                payload['options'].append({'name': opt_name, 'value': extra_options['extra_option_name']})

        http_response = requests.patch('%s/v1/resources/%s/' % (self.server_url, cmdb_node_id),
                                       json=payload,
                                       headers=headers)

        if http_response.status_code >= 500:
            raise Exception("HTTP error %s. Service unavailable." % http_response.status_code)

        return heartbeat_value
