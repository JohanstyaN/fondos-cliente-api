from datetime import datetime, timezone
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
relation_table = dynamodb.Table('ClientFundRelation')

def is_subscribed(user_id: str, fund_id: str) -> bool:
    response = relation_table.get_item(
        Key={
            'user_id': user_id,
            'id_fund': fund_id
        }
    )
    return 'Item' in response


def create_subscription_record(user_id: str, fund_id: str):
    relation_table.put_item(
        Item={
            'user_id': user_id,
            'id_fund': fund_id,
            'subscribed_at': datetime.now(timezone.utc).isoformat()
        }
    )
    print(f"Subscription record created for user {user_id} and fund {fund_id}.")
    

def delete_subscription_record(user_id: str, fund_id: str):
    relation_table.delete_item(
        Key={
            'user_id': user_id,
            'id_fund': fund_id
        }
    )
    print(f"Subscription record deleted for user {user_id} and fund {fund_id}.")
