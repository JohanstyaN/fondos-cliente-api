import os
import boto3
import logging

from dotenv import load_dotenv
load_dotenv()

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def send_fund_notification(user_id: str, id_fund: str, transaction_type: str, notification_type: str):
    if not notification_type:
        logger.info("[NOTIFICATION] No notification type provided, skipping notification.")
        return

    topic_arn = None
    if notification_type == "email":
        topic_arn = os.environ.get("SNS_EMAIL_TOPIC_ARN")
    elif notification_type == "sms":
        topic_arn = os.environ.get("SNS_SMS_TOPIC_ARN")

    if not topic_arn:
        logger.warning(f"[NOTIFICATION] SNS topic ARN for '{notification_type}' not configured. Notification skipped.")
        return

    sns = boto3.client("sns")

    message = (
        f"Usuario {user_id} ha realizado una operación de tipo '{transaction_type}' en el fondo {id_fund}."
    )

    attributes = {}
    if notification_type == "sms":
        attributes["AWS.SNS.SMS.SMSType"] = {
            'DataType': 'String',
            'StringValue': 'Transactional'
        }

    try:
        response = sns.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject="Notificación de Fondos",
            MessageAttributes=attributes if notification_type == "sms" else {}
        )
        logger.info(f"[NOTIFICATION] Notification sent via {notification_type.upper()}: {response['MessageId']}")
    except Exception as e:
        logger.error(f"[NOTIFICATION] Error sending notification: {e}")
        raise RuntimeError(f"Failed to send notification: {str(e)}")

