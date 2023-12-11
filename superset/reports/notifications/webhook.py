import types
import requests
import json
import logging

from datetime import datetime, timezone
from superset import app
from superset.reports.models import ReportRecipientType
from superset.reports.notifications.base import BaseNotification
from superset.reports.notifications.exceptions import NotificationUnprocessableException
from superset.utils.decorators import statsd_gauge

logger = logging.getLogger(__name__)


class WebhookNotification(BaseNotification):
    """
    Sends a notification via webhook
    """

    type = ReportRecipientType.WEBHOOK

    def _get_utc_timestamp(self):
        return round(datetime.now(timezone.utc).timestamp() * 1000, 0)

    def _get_endpoint(self):
        return json.loads(self._recipient.recipient_config_json)["target"]

    @statsd_gauge("reports.webhook.send")
    def send(self) -> None:
        logger.info("Sending report notification via webhook...")

        try:
            webhook_endpoint = self._get_endpoint()

            notification_json = {
                'name': self._content.name,
                'time': self._get_utc_timestamp(),
                'description': self._content.description,
                'url': self._content.url,
                'text': self._content.text
            }

            webhook_headers = self._get_webhook_headers(webhook_endpoint)

            response = requests.post(self._get_endpoint(), json=notification_json,
                                     headers=webhook_headers)
            response.raise_for_status()
            logger.info(f'Report sent via webhook ("{self._get_endpoint()}")'
                        f' with payload: "{json.dumps(notification_json)}"')

        except Exception as ex:
            logger.error(f'Error when sending report via webhook: {ex}')
            raise NotificationUnprocessableException(str(ex)) from ex

    def _get_webhook_headers(self, webhook_endpoint):
        config_key = "WEBHOOK_CUSTOM_HEADERS"
        if config_key not in app.config:
            return {}

        webhook_headers_config = app.config[config_key]
        if isinstance(webhook_headers_config, types.FunctionType):
            return webhook_headers_config(webhook_endpoint)
        if isinstance(webhook_headers_config, dict):
            return webhook_headers_config
        return {}
