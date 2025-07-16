from typing import Optional
import uuid
import logging
from datetime import datetime, timezone
from decimal import Decimal

import boto3
from botocore.exceptions import ClientError

from app.models.fund import TransactionHistoryModel
from app.utils.relations import is_subscribed, create_subscription_record, delete_subscription_record
from app.services.client_service import get_client, update_client_balance
from app.utils.notifier import send_fund_notification

logger = logging.getLogger("funds-service")
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
transactions_table = dynamodb.Table('TransactionHistory')
funds_table = dynamodb.Table('Funds')


def get_fund_minimum_amount(id_fund: str) -> float:
    logger.info(f"Fetching minimum amount for fund {id_fund}")
    try:
        response = funds_table.get_item(Key={'id_fund': id_fund})
        if 'Item' not in response:
            logger.error(f"Fund {id_fund} not found in table.")
            raise ValueError(f"Fund {id_fund} not found")
        amount = float(response['Item']['minimum_amount'])
        logger.info(f"Minimum amount for fund {id_fund}: {amount}")
        return amount
    except ClientError as e:
        logger.exception("DynamoDB client error when retrieving fund.")
        raise RuntimeError(f"Error retrieving fund: {e.response['Error']['Message']}")


def create_transaction(user_id: str, id_fund: str, transaction_type: str, notification_type: Optional[str] = None) -> dict:
    logger.info(f"Transaction request: user_id={user_id}, id_fund={id_fund}, type={transaction_type}")

    client = get_client(user_id)
    balance = float(client["balance"])
    logger.info(f"Client balance: {balance}")

    fund_minimum = get_fund_minimum_amount(id_fund)

    if transaction_type == "subscribe":
        logger.info("Processing subscription...")
        if is_subscribed(user_id, id_fund):
            logger.warning("User already subscribed.")
            raise ValueError("User is already subscribed to this fund.")
        if balance < fund_minimum:
            logger.warning("Insufficient balance.")
            raise ValueError("Insufficient balance to subscribe to fund {id_fund}.")
        new_balance = balance - fund_minimum
        amount = fund_minimum
        create_subscription_record(user_id, id_fund)
        logger.info("Subscription record created.")

    elif transaction_type == "cancel":
        logger.info("Processing cancellation...")
        if not is_subscribed(user_id, id_fund):
            logger.warning("User not subscribed.")
            raise ValueError("User is not subscribed to this fund.")
        new_balance = balance + fund_minimum
        amount = fund_minimum
        delete_subscription_record(user_id, id_fund)
        logger.info("Subscription record deleted.")

    else:
        logger.error(f"Unsupported transaction type: {transaction_type}")
        raise ValueError(f"Unsupported transaction type: {transaction_type}")

    update_client_balance(user_id, new_balance)
    logger.info(f"Client balance updated to {new_balance}")
    send_fund_notification(user_id, id_fund, transaction_type, notification_type)

    transaction_id = str(uuid.uuid4())
    timestamp = datetime.now(timezone.utc).isoformat()
    logger.info(f"Transaction ID: {transaction_id}, Timestamp: {timestamp}")

    transaction_data = {
        "transaction_id": transaction_id,
        "user_id": user_id,
        "id_fund": id_fund,
        "timestamp": timestamp,
        "transaction_type": transaction_type,
        "amount": Decimal(str(amount)),
        "notification": False
    }

    validated_transaction = TransactionHistoryModel(**transaction_data)

    item_data = validated_transaction.model_dump()
    item_data["timestamp"] = validated_transaction.timestamp.isoformat()

    transaction_item = {
        "id_transaction": f"trans#{validated_transaction.transaction_id}",
        "user_id#fund_id#timestamp": f"{validated_transaction.user_id}#{validated_transaction.id_fund}#{item_data['timestamp']}",
        **item_data
    }

    try:
        transactions_table.put_item(Item=transaction_item)
        logger.info(f"Transaction {transaction_id} recorded successfully.")
    except ClientError as e:
        logger.exception("Error writing transaction to DynamoDB.")
        raise RuntimeError(f"Error writing transaction: {e.response['Error']['Message']}")

    return {
        'transaction_id': transaction_id,
        'user_id': user_id,
        'id_fund': id_fund,
        'transaction_type': transaction_type,
        'new_balance': new_balance,
        'timestamp': validated_transaction.timestamp
    }
