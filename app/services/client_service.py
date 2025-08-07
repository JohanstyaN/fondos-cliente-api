from decimal import Decimal
import boto3
import os
from botocore.exceptions import ClientError

from app.models.fund import ClientModel

dynamodb_endpoint = os.getenv('DYNAMODB_ENDPOINT_URL')
if dynamodb_endpoint:
    dynamodb = boto3.resource('dynamodb', endpoint_url=dynamodb_endpoint)
else:
    dynamodb = boto3.resource('dynamodb')

client_table = dynamodb.Table('Clients')

def get_client(user_id: str) -> dict:
    try:
        response = client_table.get_item(Key={'user_id': user_id})
        if 'Item' not in response:
            raise ValueError(f"Client {user_id} does not exist.")
        return ClientModel.model_validate(response["Item"]).model_dump()
    except ClientError as e:
        raise RuntimeError(f"Error accessing Clients table: {e.response['Error']['Message']}")

def update_client_balance(user_id: str, new_balance: float):
    try:
        client_table.update_item(
            Key={'user_id': user_id},
            UpdateExpression="SET balance = :balance",
            ExpressionAttributeValues={':balance': Decimal(str(new_balance))}
        )
        return {"message": "Balance updated successfully."}
    except ClientError as e:
        raise RuntimeError(f"Failed to update balance: {e.response['Error']['Message']}")